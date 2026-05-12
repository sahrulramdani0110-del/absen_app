const router = require('express').Router();
const auth = require('../middleware/auth');
const {
  buatKelas,
  listKelas,
  detailKelas,
  tambahAnggota,
  listAnggota,
  hapusAnggota,
} = require('../controllers/kelasController');

router.post('/',                        auth, buatKelas);
router.get('/',                         auth, listKelas);
router.get('/:id',                      auth, detailKelas);
router.post('/:id/anggota',             auth, tambahAnggota);
router.get('/:id/anggota',              auth, listAnggota);
router.delete('/:kelas_id/anggota/:user_id', auth, hapusAnggota);

module.exports = router;
