const router = require('express').Router();
const auth = require('../middleware/auth');
const {
  buatOrganisasi,
  listOrganisasi,
  detailOrganisasi,
} = require('../controllers/organisasiController');

router.post('/',     auth, buatOrganisasi);
router.get('/',      auth, listOrganisasi);
router.get('/:id',   auth, detailOrganisasi);

module.exports = router;
