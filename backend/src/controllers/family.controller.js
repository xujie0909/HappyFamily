const Family = require('../models/Family');
const User = require('../models/User');
const Location = require('../models/Location');

const generateInviteCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
};

exports.createFamily = async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: '家庭名称不能为空' });

    if (req.user.familyId) {
      return res.status(400).json({ message: '您已加入家庭，请先退出当前家庭' });
    }

    let inviteCode;
    let exists = true;
    while (exists) {
      inviteCode = generateInviteCode();
      exists = await Family.findOne({ inviteCode });
    }

    const family = await Family.create({
      name,
      inviteCode,
      creatorId: req.user._id,
      members: [req.user._id],
    });

    await User.findByIdAndUpdate(req.user._id, { familyId: family._id });

    const populated = await Family.findById(family._id)
      .populate('members', 'nickname avatar phone isOnline lastSeen');

    res.status(201).json({ family: populated });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};

exports.joinFamily = async (req, res) => {
  try {
    const { inviteCode } = req.body;
    if (!inviteCode) return res.status(400).json({ message: '邀请码不能为空' });

    if (req.user.familyId) {
      return res.status(400).json({ message: '您已加入家庭，请先退出当前家庭' });
    }

    const family = await Family.findOne({ inviteCode: inviteCode.toUpperCase() });
    if (!family) return res.status(404).json({ message: '邀请码无效' });

    const alreadyMember = family.members.some(id => id.equals(req.user._id));
    if (alreadyMember) return res.status(400).json({ message: '您已在该家庭中' });

    family.members.push(req.user._id);
    await family.save();
    await User.findByIdAndUpdate(req.user._id, { familyId: family._id });

    const populated = await Family.findById(family._id)
      .populate('members', 'nickname avatar phone isOnline lastSeen');

    res.json({ family: populated });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};

exports.getMyFamily = async (req, res) => {
  try {
    if (!req.user.familyId) {
      return res.status(404).json({ message: '您尚未加入任何家庭' });
    }

    const family = await Family.findById(req.user.familyId)
      .populate('members', 'nickname avatar phone isOnline lastSeen');

    if (!family) return res.status(404).json({ message: '家庭不存在' });

    // attach latest location to each member
    const locations = await Location.find({ familyId: family._id });
    const locationMap = {};
    locations.forEach(loc => {
      locationMap[loc.userId.toString()] = loc;
    });

    const membersWithLocation = family.members.map(member => {
      const loc = locationMap[member._id.toString()];
      return {
        ...member.toObject(),
        location: loc ? {
          latitude: loc.latitude,
          longitude: loc.longitude,
          speed: loc.speed,
          heading: loc.heading,
          address: loc.address,
          updatedAt: loc.updatedAt,
        } : null,
      };
    });

    res.json({ family: { ...family.toObject(), members: membersWithLocation } });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};

exports.leaveFamily = async (req, res) => {
  try {
    if (!req.user.familyId) {
      return res.status(400).json({ message: '您未加入任何家庭' });
    }

    const family = await Family.findById(req.user.familyId);
    if (!family) return res.status(404).json({ message: '家庭不存在' });

    family.members = family.members.filter(id => !id.equals(req.user._id));

    if (family.members.length === 0) {
      await family.deleteOne();
    } else {
      if (family.creatorId.equals(req.user._id)) {
        family.creatorId = family.members[0];
      }
      await family.save();
    }

    await User.findByIdAndUpdate(req.user._id, { familyId: null });
    await Location.deleteOne({ userId: req.user._id });

    res.json({ message: '已退出家庭' });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};
