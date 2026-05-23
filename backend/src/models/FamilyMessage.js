const mongoose = require('mongoose');

const familyMessageSchema = new mongoose.Schema({
  familyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Family', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  nickname: { type: String, required: true },
  content: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// TTL index: auto-delete after 7 days
familyMessageSchema.index({ createdAt: 1 }, { expireAfterSeconds: 7 * 24 * 3600 });
familyMessageSchema.index({ familyId: 1, createdAt: -1 });

module.exports = mongoose.model('FamilyMessage', familyMessageSchema);
