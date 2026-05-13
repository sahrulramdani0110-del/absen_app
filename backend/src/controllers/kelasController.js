const pool = require('../config/db');

exports.buatKelas = async (req, res) => {
  const { org_id, name, description } = req.body;

  if (!org_id || !name) {
    return res.status(400).json({ message: 'org_id dan name wajib diisi.' });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO kelas (org_id, name, description) VALUES (?, ?, ?)',
      [org_id, name, description || null]
    );
    res.status(201).json({
      message: 'Kelas berhasil dibuat.',
      kelasId: result.insertId,
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.listKelas = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT k.*, o.name AS org_name
       FROM kelas k
       JOIN organizations o ON k.org_id = o.id
       ORDER BY k.created_at DESC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.detailKelas = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT k.*, o.name AS org_name
       FROM kelas k
       JOIN organizations o ON k.org_id = o.id
       WHERE k.id = ?`,
      [req.params.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Kelas tidak ditemukan.' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.tambahAnggota = async (req, res) => {
  const { user_id, role } = req.body;
  const kelas_id = req.params.id;

  if (!user_id) {
    return res.status(400).json({ message: 'user_id wajib diisi.' });
  }

  try {
    await pool.query(
      'INSERT INTO kelas_members (kelas_id, user_id, role) VALUES (?, ?, ?)',
      [kelas_id, user_id, role || 'member']
    );
    res.status(201).json({ message: 'Anggota berhasil ditambahkan.' });
  } catch (err) {
    console.error('ERROR TAMBAH ANGGOTA:', err);  // ← TAMBAH INI
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ message: 'User sudah menjadi anggota kelas ini.' });
    }
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.listAnggota = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT u.id, u.name, u.email, u.avatar_url, km.role, km.joined_at
       FROM kelas_members km
       JOIN users u ON km.user_id = u.id
       WHERE km.kelas_id = ?
       ORDER BY km.joined_at ASC`,
      [req.params.id]
    );
    res.json({ total: rows.length, data: rows });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.hapusAnggota = async (req, res) => {
  const { kelas_id, user_id } = req.params;
  try {
    const [result] = await pool.query(
      'DELETE FROM kelas_members WHERE kelas_id = ? AND user_id = ?',
      [kelas_id, user_id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Anggota tidak ditemukan.' });
    }
    res.json({ message: 'Anggota berhasil dihapus.' });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};
