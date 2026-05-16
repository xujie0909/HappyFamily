const jwt = require('jsonwebtoken');
const User = require('../models/User');

const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

exports.register = async (req, res) => {
  try {
    const { phone, password, nickname } = req.body;
    if (!phone || !password || !nickname) {
      return res.status(400).json({ message: '手机号、密码和昵称不能为空' });
    }
    if (!/^1[3-9]\d{9}$/.test(phone)) {
      return res.status(400).json({ message: '手机号格式不正确' });
    }
    if (password.length < 6) {
      return res.status(400).json({ message: '密码至少6位' });
    }

    const existing = await User.findOne({ phone });
    if (existing) return res.status(409).json({ message: '该手机号已注册' });

    const user = await User.create({ phone, password, nickname });
    const token = signToken(user._id);

    res.status(201).json({ token, user: user.toSafeObject() });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { phone, password } = req.body;
    if (!phone || !password) {
      return res.status(400).json({ message: '手机号和密码不能为空' });
    }

    const user = await User.findOne({ phone });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ message: '手机号或密码错误' });
    }

    const token = signToken(user._id);
    res.json({ token, user: user.toSafeObject() });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};

exports.getMe = async (req, res) => {
  res.json({ user: req.user.toSafeObject() });
};

exports.updateProfile = async (req, res) => {
  try {
    const { nickname, avatar } = req.body;
    const updates = {};
    if (nickname) updates.nickname = nickname;
    if (avatar !== undefined) updates.avatar = avatar;

    const user = await User.findByIdAndUpdate(req.user._id, updates, { new: true }).select('-password');
    res.json({ user });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
};
