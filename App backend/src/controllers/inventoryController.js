const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all inventory items for the logged-in worker
const getInventory = async (req, res) => {
    try {
        const workerId = req.user.id;

        const inventory = await prisma.inventoryItem.findMany({
            where: { workerId },
            orderBy: { name: 'asc' }
        });

        res.json({ inventory });
    } catch (error) {
        console.error("getInventory error", error);
        res.status(500).json({ error: 'Failed to retrieve inventory' });
    }
};

// Add a new inventory item
const addInventoryItem = async (req, res) => {
    try {
        const { name, quantity, unit } = req.body;
        const workerId = req.user.id; // from JWT token auth middleware

        if (!name || quantity === undefined || !unit) {
            return res.status(400).json({ error: 'Name, quantity, and unit are required' });
        }

        const item = await prisma.inventoryItem.create({
            data: {
                name,
                quantity: parseInt(quantity),
                unit,
                workerId
            }
        });

        res.status(201).json({ message: 'Item added successfully', item });
    } catch (error) {
        console.error("addInventoryItem error", error);
        res.status(500).json({ error: 'Failed to add inventory item' });
    }
};

// Update an existing inventory item
const updateInventoryItem = async (req, res) => {
    try {
        const { itemId } = req.params;
        const { quantity } = req.body;
        const workerId = req.user.id;

        if (quantity === undefined) {
            return res.status(400).json({ error: 'Quantity is required' });
        }

        // Verify ownership
        const existingItem = await prisma.inventoryItem.findFirst({
            where: { id: itemId, workerId }
        });

        if (!existingItem) {
            return res.status(404).json({ error: 'Item not found' });
        }

        const updatedItem = await prisma.inventoryItem.update({
            where: { id: itemId },
            data: { quantity: parseInt(quantity) }
        });

        res.json({ message: 'Item updated successfully', item: updatedItem });
    } catch (error) {
        console.error("updateInventoryItem error", error);
        res.status(500).json({ error: 'Failed to update inventory item' });
    }
};

// Delete an inventory item
const deleteInventoryItem = async (req, res) => {
    try {
        const { itemId } = req.params;
        const workerId = req.user.id;

        // Verify ownership
        const existingItem = await prisma.inventoryItem.findFirst({
            where: { id: itemId, workerId }
        });

        if (!existingItem) {
            return res.status(404).json({ error: 'Item not found' });
        }

        await prisma.inventoryItem.delete({
            where: { id: itemId }
        });

        res.json({ message: 'Item deleted successfully' });
    } catch (error) {
        console.error("deleteInventoryItem error", error);
        res.status(500).json({ error: 'Failed to delete inventory item' });
    }
};

module.exports = { getInventory, addInventoryItem, updateInventoryItem, deleteInventoryItem };
