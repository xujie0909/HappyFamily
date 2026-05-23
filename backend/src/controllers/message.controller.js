const FamilyMessage = require('../models/FamilyMessage');

exports.getMessages = async (req, res) => {
  try {
    const user = req.user;
    if (!user.familyId) {
      return res.status(400).json({ message: '未加入家庭' });
    }

    const messages = await FamilyMessage.find({ familyId: user.familyId })
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({ messages });
  } catch (err) {
    res.status(500).json({ message: '获取消息失败' });
  }
};
