import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final response = await ApiService.get('/inventory');
      if (response != null && response['inventory'] != null) {
        setState(() {
          _inventory = response['inventory'];
          _isLoading = false;
        });
      } else if (response != null && response['error'] != null) {
        setState(() {
          _errorMsg = response['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "Failed to load inventory. Check your connection.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateQuantity(String itemId, int currentQuantity, int change) async {
    final newQuantity = currentQuantity + change;
    if (newQuantity < 0) return;

    setState(() {
      final index = _inventory.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _inventory[index]['quantity'] = newQuantity;
      }
    });

    try {
      final response = await ApiService.put('/inventory/$itemId', {'quantity': newQuantity});
      if (response != null && response['error'] != null) {
        throw Exception(response['error']);
      }
    } catch (e) {
      setState(() {
        final index = _inventory.indexWhere((item) => item['id'] == itemId);
        if (index != -1) {
          _inventory[index]['quantity'] = currentQuantity;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${e.toString()}'), backgroundColor: MyTheme.criticalRed),
        );
      }
    }
  }

  void _showAddItemModal() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final unitCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Item',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Item Name (e.g., Paracetamol)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: quantityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (int.tryParse(val) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: unitCtrl,
                        decoration: InputDecoration(
                          labelText: 'Unit (e.g., tablets)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Adding item...')),
                        );
                        
                        try {
                          final response = await ApiService.post('/inventory', {
                            'name': nameCtrl.text.trim(),
                            'quantity': int.parse(quantityCtrl.text.trim()),
                            'unit': unitCtrl.text.trim(),
                          });
                          
                          if (response != null && !response.containsKey('error')) {
                            _fetchInventory();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item added!'),
                                backgroundColor: MyTheme.successGreen,
                              ),
                            );
                          } else {
                            throw Exception(response?['error'] ?? 'Unknown error');
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed: ${e.toString()}'),
                              backgroundColor: MyTheme.criticalRed,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Add Item', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('My Inventory', style: TextStyle(color: MyTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: MyTheme.primaryBlue),
            onPressed: _fetchInventory,
            tooltip: 'Refresh Inventory',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red)))
              : _inventory.isEmpty
                  ? const Center(child: Text("Your inventory is currently empty.", style: TextStyle(color: Colors.grey, fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: _fetchInventory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _inventory.length,
                        itemBuilder: (context, index) {
                          final item = _inventory[index];
                          final int quantity = item['quantity'] ?? 0;
                          final bool isLowStock = quantity < 10;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isLowStock ? Colors.red.shade200 : Colors.grey.shade200),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon Context
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isLowStock ? Colors.red.withOpacity(0.1) : MyTheme.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.medication, color: isLowStock ? Colors.red : MyTheme.primaryBlue),
                                  ),
                                  const SizedBox(width: 16),
                                  // Detail Body
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stock: $quantity ${item['unit']}',
                                          style: TextStyle(
                                            color: isLowStock ? Colors.red : Colors.grey.shade600,
                                            fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (isLowStock)
                                          Text('Low Stock alert!', style: TextStyle(color: Colors.red.shade400, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  // Plus / Minus Dispenser
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                        onPressed: quantity > 0 ? () => _updateQuantity(item['id'], quantity, -1) : null,
                                      ),
                                      Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: MyTheme.primaryBlue),
                                        onPressed: () => _updateQuantity(item['id'], quantity, 1),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemModal,
        backgroundColor: MyTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
