const express = require('express');
const { getInventory, addInventoryItem, updateInventoryItem, deleteInventoryItem } = require('../controllers/inventoryController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.get('/', getInventory);
router.post('/', addInventoryItem);
router.put('/:itemId', updateInventoryItem);
router.delete('/:itemId', deleteInventoryItem);

module.exports = router;
