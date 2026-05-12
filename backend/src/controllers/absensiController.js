const pool = require('../config/db');

function hitungJarak(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * (Math.PI / 180)) *
    Math.cos(lat2 * (Math.PI / 180)) *
    Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

exports.bukaSesi = async (req, res) => {
  const { kelas_id, title, start_time, latitude, longitude, radius_meters } = req.body;

  if (!kelas_id || !title || !start_time) {
    return res.status(400).json({ message: 'kelas_id, title, dan start_time wajib diisi.' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO sessions (kelas_id, created_by, title, start_time, latitude, longitude, radius_meters)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [kelas_id, req.user.id, title, start_time, latitude || null, longitude || null, radius_meters || 100]
    );
    res.status(201).json({
      message: 'Sesi absensi berhasil dibuka.',
      sessionId: result.insertId,
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.listSesi = async (req, res) => {
  const { kelas_id } = req.query;
  try {
    let query = `
      SELECT s.*, u.name AS created_by_name, k.name AS kelas_name
      FROM sessions s
      JOIN users u ON s.created_by = u.id
      JOIN kelas k ON s.kelas_id = k.id
    `;
    const params = [];
    if (kelas_id) {
      query += ' WHERE s.kelas_id = ?';
      params.push(kelas_id);
    }
    query += ' ORDER BY s.created_at DESC';

    const [rows] = await pool.query(query, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.tutupSesi = async (req, res) => {
  try {
    const [result] = await pool.query(
      'UPDATE sessions SET status = "closed", end_time = NOW() WHERE id = ? AND created_by = ?',
      [req.params.id, req.user.id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Sesi tidak ditemukan atau kamu bukan pembuatnya.' });
    }
    res.json({ message: 'Sesi berhasil ditutup.' });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.checkIn = async (req, res) => {
  const { session_id, latitude, longitude, photo_url, device_type } = req.body;

  if (!session_id) {
    return res.status(400).json({ message: 'session_id wajib diisi.' });
  }

  try {
    const [sesi] = await pool.query(
      'SELECT * FROM sessions WHERE id = ? AND status = "open"',
      [session_id]
    );
    if (sesi.length === 0) {
      return res.status(400).json({ message: 'Sesi tidak ditemukan atau sudah ditutup.' });
    }

    const s = sesi[0];

    if (s.latitude && s.longitude && latitude && longitude) {
      const jarak = hitungJarak(s.latitude, s.longitude, latitude, longitude);
      if (jarak > s.radius_meters) {
        return res.status(400).json({
          message: `Kamu berada di luar jangkauan lokasi. Jarak kamu: ${Math.round(jarak)}m, batas: ${s.radius_meters}m.`,
        });
      }
    }

    const sekarang = new Date();
    const mulai = new Date(s.start_time);
    const batasTerlambat = new Date(mulai.getTime() + 15 * 60 * 1000);
    const status = sekarang > batasTerlambat ? 'terlambat' : 'hadir';

    await pool.query(
      `INSERT INTO attendances (session_id, user_id, latitude, longitude, photo_url, status, device_type)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [session_id, req.user.id, latitude || null, longitude || null, photo_url || null, status, device_type || 'web']
    );

    res.status(201).json({
      message: `Absensi berhasil dicatat.`,
      status,
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ message: 'Kamu sudah melakukan absensi di sesi ini.' });
    }
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.rekapSesi = async (req, res) => {
  try {
    const [sesi] = await pool.query('SELECT * FROM sessions WHERE id = ?', [req.params.id]);
    if (sesi.length === 0) {
      return res.status(404).json({ message: 'Sesi tidak ditemukan.' });
    }

    const [rows] = await pool.query(
      `SELECT u.id, u.name, u.email, a.status, a.checked_in_at, a.device_type, a.latitude, a.longitude
       FROM attendances a
       JOIN users u ON a.user_id = u.id
       WHERE a.session_id = ?
       ORDER BY a.checked_in_at ASC`,
      [req.params.id]
    );

    const rekap = {
      hadir: rows.filter(r => r.status === 'hadir').length,
      terlambat: rows.filter(r => r.status === 'terlambat').length,
      izin: rows.filter(r => r.status === 'izin').length,
      alpha: rows.filter(r => r.status === 'alpha').length,
    };

    res.json({
      sesi: sesi[0],
      rekap,
      total: rows.length,
      data: rows,
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};

exports.riwayatUser = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT s.id AS session_id, s.title, s.start_time, k.name AS kelas_name,
              a.status, a.checked_in_at, a.device_type
       FROM attendances a
       JOIN sessions s ON a.session_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE a.user_id = ?
       ORDER BY a.checked_in_at DESC`,
      [req.user.id]
    );
    res.json({ total: rows.length, data: rows });
  } catch (err) {
    res.status(500).json({ message: 'Server error.', error: err.message });
  }
};
