const express = require('express');
const mongoose = require('mongoose');
const GiangVien = require('../models/GiangVien');
const auth = require('../middleware/auth');
const pub = require('../utils/publicGiangVien');

const router = express.Router();
router.use(auth);

const escapeRegex = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const MAX_IMAGE = 2000000;

// Trả về { error } hoặc { value } chỉ gồm đúng 4 trường
function validate(body) {
  const { IDGV, Fullname, Image, SumClass } = body || {};
  const id = String(IDGV ?? '').trim();
  const name = String(Fullname ?? '').trim();
  const img = Image == null ? '' : String(Image);
  if (!id) return { error: 'Mã giảng viên không được để trống' };
  if (!name) return { error: 'Họ và tên không được để trống' };
  const sc = SumClass === '' || SumClass == null ? 0 : Number(SumClass);
  if (!Number.isInteger(sc) || sc < 0) return { error: 'Tổng số lớp phải là số nguyên >= 0' };
  if (img && !img.startsWith('data:image/')) return { error: 'Ảnh không hợp lệ' };
  if (img.length > MAX_IMAGE) return { error: 'Ảnh quá lớn' };
  return { value: { IDGV: id, Fullname: name, Image: img, SumClass: sc } };
}

const validId = (id) => mongoose.Types.ObjectId.isValid(id);

function handleError(err, res, next) {
  if (err && err.code === 11000) {
    return res.status(409).json({ message: 'Mã giảng viên đã tồn tại' });
  }
  next(err);
}

router.get('/', async (req, res, next) => {
  try {
    const search = String(req.query.search || '').trim();
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const filter = {};
    if (search) {
      const re = new RegExp(escapeRegex(search), 'i');
      filter.$or = [{ IDGV: re }, { Fullname: re }];
    }
    const [items, total, agg] = await Promise.all([
      GiangVien.find(filter).sort({ IDGV: 1 }).skip((page - 1) * limit).limit(limit),
      GiangVien.countDocuments(filter),
      GiangVien.aggregate([{ $match: filter }, { $group: { _id: null, s: { $sum: '$SumClass' } } }]),
    ]);
    res.json({
      data: items.map(pub),
      page,
      limit,
      total,
      totalPages: Math.max(1, Math.ceil(total / limit)),
      totalSumClass: agg[0] ? agg[0].s : 0,
    });
  } catch (e) { next(e); }
});

router.get('/:id', async (req, res, next) => {
  try {
    if (!validId(req.params.id)) return res.status(404).json({ message: 'Không tìm thấy giảng viên' });
    const g = await GiangVien.findById(req.params.id);
    if (!g) return res.status(404).json({ message: 'Không tìm thấy giảng viên' });
    res.json(pub(g));
  } catch (e) { next(e); }
});

router.post('/', async (req, res, next) => {
  try {
    const { error, value } = validate(req.body);
    if (error) return res.status(400).json({ message: error });
    const g = await GiangVien.create(value);
    res.status(201).json(pub(g));
  } catch (e) { handleError(e, res, next); }
});

router.put('/:id', async (req, res, next) => {
  try {
    if (!validId(req.params.id)) return res.status(404).json({ message: 'Không tìm thấy giảng viên' });
    const { error, value } = validate(req.body);
    if (error) return res.status(400).json({ message: error });
    const g = await GiangVien.findByIdAndUpdate(req.params.id, value, { new: true, runValidators: true });
    if (!g) return res.status(404).json({ message: 'Không tìm thấy giảng viên' });
    res.json(pub(g));
  } catch (e) { handleError(e, res, next); }
});

router.delete('/:id', async (req, res, next) => {
  try {
    if (!validId(req.params.id)) return res.status(404).json({ message: 'Không tìm thấy giảng viên' });
    const g = await GiangVien.findByIdAndDelete(req.params.id);
    if (!g) return res.status(404).json({ message: 'Không tìm thấy giảng viên' });
    res.json({ message: 'Đã xóa' });
  } catch (e) { next(e); }
});

module.exports = router;

