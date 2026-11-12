const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const header = req.headers.authorization || '';
  const [type, token] = header.split(' ');
  if (type !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Chưa đăng nhập' });
  }
  try {
    const p = jwt.verify(token, process.env.JWT_SECRET);
    req.auth = { username: p.username };
    next();
  } catch (_) {
    res.status(401).json({ message: 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn' });
  }
};

