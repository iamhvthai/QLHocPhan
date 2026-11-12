require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const app = express();
app.use(cors());
app.use(express.json({ limit: '5mb' }));

app.get('/api/health', (_req, res) => res.json({ ok: true }));
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/giangvien', require('./routes/giangvien.routes'));

app.use((req, res) => res.status(404).json({ message: 'Không tìm thấy đường dẫn' }));
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error(err.message);
  if (err.type === 'entity.parse.failed') return res.status(400).json({ message: 'Dữ liệu JSON không hợp lệ' });
  if (err.type === 'entity.too.large') return res.status(400).json({ message: 'Ảnh quá lớn' });
  if (err.name === 'ValidationError') return res.status(400).json({ message: err.message });
  res.status(500).json({ message: 'Lỗi máy chủ' });
});

const PORT = process.env.PORT || 3000;
connectDB().then(() => {
  app.listen(PORT, '0.0.0.0', () => console.log(`Server chạy cổng ${PORT}`));
});
