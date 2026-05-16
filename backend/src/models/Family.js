const mongoose = require('mongoose');

const familySchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true, maxlength: 30 },
  inviteCode: { type: String, required: true, unique: true, length: 6 },
  creatorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
}, { timestamps: true });

module.exports = mongoose.model('Family', familySchema);
