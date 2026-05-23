const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Location = require('../models/Location');
const FamilyMessage = require('../models/FamilyMessage');
const { haversineDistance, formatDuration } = require('../utils/geo');
const { reverseGeocode } = require('../utils/amap');

const MOVE_THRESHOLD_METERS = 100;

// socketId -> userId mapping
const socketUserMap = new Map();

module.exports = (io) => {
  // JWT auth handshake
  io.use(async (socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('未授权'));

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id).select('-password');
      if (!user) return next(new Error('用户不存在'));
      socket.user = user;
      next();
    } catch {
      next(new Error('Token无效'));
    }
  });

  io.on('connection', async (socket) => {
    const user = socket.user;
    socketUserMap.set(socket.id, user._id.toString());

    // Mark online and join family room
    await User.findByIdAndUpdate(user._id, { isOnline: true, lastSeen: new Date() });

    if (user.familyId) {
      const roomId = `family:${user.familyId}`;
      socket.join(roomId);

      // Notify other members
      socket.to(roomId).emit('member:online', { userId: user._id.toString(), isOnline: true });

      // Send current positions of all family members to newly connected user
      const locations = await Location.find({ familyId: user.familyId });
      socket.emit('locations:init', locations.map(loc => ({
        userId: loc.userId.toString(),
        latitude: loc.latitude,
        longitude: loc.longitude,
        speed: loc.speed,
        heading: loc.heading,
        accuracy: loc.accuracy,
        address: loc.address,
        updatedAt: loc.updatedAt,
        stayStartTime: loc.stayStartTime,
      })));
    }

    // Client uploads its location
    socket.on('location:update', async (data) => {
      const { latitude, longitude, speed, heading, accuracy, address } = data;
      if (latitude == null || longitude == null) return;
      if (!user.familyId) return;

      const now = new Date();
      const roomId = `family:${user.familyId}`;

      // Load existing location record (with anchor info)
      const existing = await Location.findOne({ userId: user._id });

      let stayStartTime = now;
      let newAnchorLat = latitude;
      let newAnchorLng = longitude;

      if (existing) {
        const hasAnchor = existing.anchorLat != null && existing.anchorLng != null;

        if (!hasAnchor) {
          // First time: initialize anchor at current position
          stayStartTime = existing.stayStartTime || existing.updatedAt || now;
        } else {
          const dist = haversineDistance(existing.anchorLat, existing.anchorLng, latitude, longitude);

          if (dist >= MOVE_THRESHOLD_METERS) {
            // User has moved — create a family message
            const dwellMs = now - (existing.stayStartTime || existing.updatedAt || now);
            const durationText = formatDuration(dwellMs);

            // Reverse geocode the old anchor position
            const oldAddress = await reverseGeocode(existing.anchorLat, existing.anchorLng);
            const content = `${user.nickname} 离开了 ${oldAddress}，已停留 ${durationText}`;

            const msg = await FamilyMessage.create({
              familyId: user.familyId,
              userId: user._id,
              nickname: user.nickname,
              content,
            });

            // Push to all family members
            io.to(roomId).emit('family:message', {
              id: msg._id.toString(),
              userId: user._id.toString(),
              nickname: user.nickname,
              content,
              createdAt: msg.createdAt,
            });

            // New anchor = current position
            newAnchorLat = latitude;
            newAnchorLng = longitude;
            stayStartTime = now;
          } else {
            // Still at same place — keep existing anchor and stayStartTime
            newAnchorLat = existing.anchorLat;
            newAnchorLng = existing.anchorLng;
            stayStartTime = existing.stayStartTime || existing.updatedAt || now;
          }
        }
      }

      const locationData = {
        userId: user._id,
        familyId: user.familyId,
        latitude,
        longitude,
        speed: speed ?? 0,
        heading: heading ?? 0,
        accuracy: accuracy ?? 0,
        address: address ?? '',
        updatedAt: now,
        anchorLat: newAnchorLat,
        anchorLng: newAnchorLng,
        stayStartTime,
      };

      await Location.findOneAndUpdate(
        { userId: user._id },
        locationData,
        { upsert: true, new: true }
      );

      // Broadcast to all family members (including sender to confirm)
      io.to(roomId).emit('location:updated', {
        userId: user._id.toString(),
        latitude,
        longitude,
        speed: speed ?? 0,
        heading: heading ?? 0,
        accuracy: accuracy ?? 0,
        address: address ?? '',
        updatedAt: now,
        stayStartTime,
      });
    });

    socket.on('disconnect', async () => {
      socketUserMap.delete(socket.id);
      await User.findByIdAndUpdate(user._id, { isOnline: false, lastSeen: new Date() });

      if (user.familyId) {
        const roomId = `family:${user.familyId}`;
        socket.to(roomId).emit('member:online', {
          userId: user._id.toString(),
          isOnline: false,
          lastSeen: new Date(),
        });
      }
    });
  });
};
