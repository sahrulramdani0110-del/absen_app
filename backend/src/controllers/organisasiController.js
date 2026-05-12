const pool = require('../config/db');

exports.buatOrganisasi = async (req, res) => {
  const { name, address } = req.body;

  if (!name) {
    return res.status(400).json({ message: 'Nama organisasi wajib diisi.' });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO organizations (name, address) VALUES (?, ?)',
      [name, address || null]
    );
    res.status(201).json({
      message: 'Organisasi berhasil dibuat.',
      orgId: result.insertId,
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.listOrganisasi = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM organizations ORDER BY created_at DESC'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.detailOrganisasi = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM organizations WHERE id = ?',
      [req.params.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Organisasi tidak ditemukan.' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};
