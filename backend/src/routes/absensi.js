const router = require('express').Router();
const auth = require('../middleware/auth');
const {
  bukaSesi,
  listSesi,
  tutupSesi,
  checkIn,
  rekapSesi,
  riwayatUser,
} = require('../controllers/absensiController');

router.post('/sesi',              auth, bukaSesi);
router.get('/sesi',               auth, listSesi);
router.patch('/sesi/:id/tutup',   auth, tutupSesi);
router.post('/checkin',           auth, checkIn);
router.get('/sesi/:id/rekap',     auth, rekapSesi);
router.get('/riwayat',            auth, riwayatUser);

module.exports = router;
