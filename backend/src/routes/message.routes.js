const router = require('express').Router();
const messageController = require('../controllers/message.controller');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.get('/', messageController.getMessages);

module.exports = router;
