const mongoose = require('mongoose');

const giangVienSchema = new mongoose.Schema(
  {
    IDGV: { type: String, required: true, unique: true, trim: true, uppercase: true },
    Fullname: { type: String, required: true, trim: true },
    Image: { type: String, default: '' }, // data URI base64
    SumClass: {
      type: Number,
      required: true,
      default: 0,
      min: 0,
      validate: { validator: Number.isInteger, message: 'SumClass phải là số nguyên' },
    },
  },
  {
    versionKey: false,
    timestamps: false,
    strict: true,
    collection: 'GiangVien',
  }
);

module.exports = mongoose.model('GiangVien', giangVienSchema);

