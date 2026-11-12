require('dotenv').config();
const mongoose = require('mongoose');
const GiangVien = require('../src/models/GiangVien');

const data = [
  { IDGV: 'GV001', Fullname: 'Nguyễn Văn An', Image: '', SumClass: 3 },
  { IDGV: 'GV002', Fullname: 'Trần Thị Bình', Image: '', SumClass: 4 },
  { IDGV: 'GV003', Fullname: 'Lê Minh Chi', Image: '', SumClass: 2 },
  { IDGV: 'GV004', Fullname: 'Phạm Quốc Dũng', Image: '', SumClass: 5 },
  { IDGV: 'GV005', Fullname: 'Hoàng Thu Hà', Image: '', SumClass: 1 },
];

(async () => {
  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });
  console.log('Database:', mongoose.connection.name);
  if (process.argv.includes('--reset')) {
    await GiangVien.deleteMany({});
    console.log('Đã xóa dữ liệu cũ');
  }
  for (const d of data) {
    await GiangVien.updateOne({ IDGV: d.IDGV }, { $setOnInsert: d }, { upsert: true });
  }
  console.log(`Seed xong ${data.length} giảng viên`);
  console.log(`Tài khoản admin: ${process.env.ADMIN_USERNAME} / ${process.env.ADMIN_PASSWORD}`);
  await mongoose.disconnect();
})().catch((e) => { console.error(e.message); process.exit(1); });

