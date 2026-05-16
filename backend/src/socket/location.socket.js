const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Location = require('../models/Location');

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
      })));
    }

    // Client uploads its location
    socket.on('location:update', async (data) => {
      const { latitude, longitude, speed, heading, accuracy, address } = data;
      if (latitude == null || longitude == null) return;
      if (!user.familyId) return;

      const locationData = {
        userId: user._id,
        familyId: user.familyId,
        latitude,
        longitude,
        speed: speed ?? 0,
        heading: heading ?? 0,
        accuracy: accuracy ?? 0,
        address: address ?? '',
        updatedAt: new Date(),
      };

      await Location.findOneAndUpdate(
        { userId: user._id },
        locationData,
        { upsert: true, new: true }
      );

      // Broadcast to all family members (including sender to confirm)
      const roomId = `family:${user.familyId}`;
      io.to(roomId).emit('location:updated', {
        userId: user._id.toString(),
        latitude,
        longitude,
        speed: speed ?? 0,
        heading: heading ?? 0,
        accuracy: accuracy ?? 0,
        address: address ?? '',
        updatedAt: locationData.updatedAt,
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
