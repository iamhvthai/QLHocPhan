require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

(async () => {
  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });
  const docs = await mongoose.connection.db.collection('GiangVien').find().sort({ IDGV: 1 }).toArray();
  const out = docs.map((d) => ({
    _id: d._id.toString(),
    IDGV: d.IDGV,
    Fullname: d.Fullname,
    Image: d.Image,
    SumClass: d.SumClass,
  }));
  const dir = path.join(__dirname, '..', '..', 'database');
  fs.mkdirSync(dir, { recursive: true });
  const file = path.join(dir, 'GiangVien.json');
  fs.writeFileSync(file, JSON.stringify(out, null, 2), 'utf8');
  console.log(`Đã xuất ${out.length} bản ghi ra ${file}`);
  await mongoose.disconnect();
})().catch((e) => { console.error(e.message); process.exit(1); });

