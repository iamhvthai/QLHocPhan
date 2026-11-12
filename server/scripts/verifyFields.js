require('dotenv').config();
const mongoose = require('mongoose');

const EXPECTED = ['IDGV', 'Fullname', 'Image', 'SumClass', '_id'].sort().join(',');

(async () => {
  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });
  const docs = await mongoose.connection.db.collection('GiangVien').find().toArray();
  let ok = 0;
  let bad = 0;
  for (const d of docs) {
    const keys = Object.keys(d).sort();
    if (keys.join(',') === EXPECTED) ok++;
    else {
      bad++;
      const extra = keys.filter((k) => !EXPECTED.split(',').includes(k));
      const missing = EXPECTED.split(',').filter((k) => !keys.includes(k));
      console.log(`Sai: ${d.IDGV || d._id} | thừa: [${extra}] | thiếu: [${missing}]`);
    }
  }
  console.log(`Database ${mongoose.connection.name}: ${ok} hợp lệ, ${bad} sai (tổng ${docs.length})`);
  await mongoose.disconnect();
  process.exit(bad ? 1 : 0);
})().catch((e) => { console.error(e.message); process.exit(1); });

