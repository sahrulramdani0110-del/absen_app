const express = require('express');
const app = express();
require('dotenv').config();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.json({ message: 'API Absensi Digital berjalan.' });
});

app.use('/api/auth',        require('./routes/auth'));
app.use('/api/organisasi',  require('./routes/organisasi'));
app.use('/api/kelas',       require('./routes/kelas'));
app.use('/api/absensi',     require('./routes/absensi'));

app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint tidak ditemukan.' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});
