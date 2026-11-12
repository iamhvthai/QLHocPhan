const express = require('express');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const auth = require('../middleware/auth');

const router = express.Router();

function safeEqual(a, b) {
  const ha = crypto.createHash('sha256').update(String(a)).digest();
  const hb = crypto.createHash('sha256').update(String(b)).digest();
  return crypto.timingSafeEqual(ha, hb);
}

router.post('/login', (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập tên đăng nhập và mật khẩu' });
  }
  const okUser = safeEqual(username, process.env.ADMIN_USERNAME || '');
  const okPass = safeEqual(password, process.env.ADMIN_PASSWORD || '');
  if (!(okUser && okPass)) {
    return res.status(401).json({ message: 'Tên đăng nhập hoặc mật khẩu không đúng' });
  }
  const token = jwt.sign({ username }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  res.json({ token, username });
});

router.get('/me', auth, (req, res) => {
  res.json({ username: req.auth.username });
});

module.exports = router;

