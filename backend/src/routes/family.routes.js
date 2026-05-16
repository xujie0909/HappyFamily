const router = require('express').Router();
const familyController = require('../controllers/family.controller');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.post('/create', familyController.createFamily);
router.post('/join', familyController.joinFamily);
router.get('/mine', familyController.getMyFamily);
router.post('/leave', familyController.leaveFamily);

module.exports = router;
