const mongoose = require('mongoose');

const locationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  familyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Family', required: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  speed: { type: Number, default: 0 },       // m/s
  heading: { type: Number, default: 0 },     // degrees 0-360
  accuracy: { type: Number, default: 0 },    // meters
  address: { type: String, default: '' },
  updatedAt: { type: Date, default: Date.now },
}, { timestamps: false });

locationSchema.index({ familyId: 1 });

module.exports = mongoose.model('Location', locationSchema);
