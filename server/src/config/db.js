const mongoose = require('mongoose');

async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });
    console.log(`Đã kết nối MongoDB, database: ${mongoose.connection.name}`);
  } catch (err) {
    const m = String(err.message || err);
    console.error('Kết nối MongoDB thất bại:', m);
    if (/bad auth|Authentication failed/i.test(m)) {
      console.error('Gợi ý: sai user hoặc mật khẩu trong MONGODB_URI.');
    } else if (/ENOTFOUND|querySrv|Server selection timed out/i.test(m)) {
      console.error('Gợi ý: thêm IP vào Network Access của Atlas (0.0.0.0/0), đổi DNS 8.8.8.8 hoặc thử mạng khác.');
    }
    process.exit(1);
  }
}

module.exports = connectDB;

