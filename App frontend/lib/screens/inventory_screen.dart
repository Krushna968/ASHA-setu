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
  List<dynamic> _filteredInventory = [];
  bool _isLoading = true;
  String? _errorMsg;
  String _searchQuery = '';
  
  // Summary Stats
  int _totalItems = 0;
  int _lowStockCount = 0;

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
        final List<dynamic> items = response['inventory'];
        setState(() {
          _inventory = items;
          _calculateStats(items);
          _applySearch();
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

  void _calculateStats(List<dynamic> items) {
    _totalItems = items.length;
    _lowStockCount = items.where((item) => (item['quantity'] ?? 0) < 10).length;
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredInventory = List.from(_inventory);
    } else {
      _filteredInventory = _inventory.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> _updateQuantity(String itemId, int currentQuantity, int change) async {
    final newQuantity = currentQuantity + change;
    if (newQuantity < 0) return;

    // Optimistic UI update
    setState(() {
      final index = _inventory.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _inventory[index]['quantity'] = newQuantity;
        _calculateStats(_inventory);
        _applySearch();
      }
    });

    try {
      final response = await ApiService.put('/inventory/$itemId', {'quantity': newQuantity});
      if (response != null && response['error'] != null) {
        throw Exception(response['error']);
      }
    } catch (e) {
      // Revert on failure
      setState(() {
        final index = _inventory.indexWhere((item) => item['id'] == itemId);
        if (index != -1) {
          _inventory[index]['quantity'] = currentQuantity;
          _calculateStats(_inventory);
          _applySearch();
        }
      });
      if (mounted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: MyTheme.criticalRed,
            behavior: SnackBarBehavior.floating,
          ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add New Stock Item',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Register a new medicine or supply item to your kit.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildModalTextField(
                controller: nameCtrl,
                label: 'Item Name',
                hint: 'e.g., Paracetamol 500mg',
                icon: Icons.medication_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildModalTextField(
                      controller: quantityCtrl,
                      label: 'Initial Quantity',
                      hint: '0',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (int.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModalTextField(
                      controller: unitCtrl,
                      label: 'Unit',
                      hint: 'tablets, packs...',
                      icon: Icons.straighten_rounded,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      
                      try {
                        final response = await ApiService.post('/inventory', {
                          'name': nameCtrl.text.trim(),
                          'quantity': int.parse(quantityCtrl.text.trim()),
                          'unit': unitCtrl.text.trim(),
                        });
                        
                        if (response != null && !response.containsKey('error')) {
                          _fetchInventory();
                          if (mounted) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('New item added successfully!'),
                                backgroundColor: MyTheme.successGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } else {
                          throw Exception(response?['error'] ?? 'Unknown error');
                        }
                      } catch (e) {
                        if (mounted) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed: ${e.toString()}'),
                              backgroundColor: MyTheme.criticalRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Register Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: MyTheme.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: MyTheme.primaryBlue),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('My Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: MyTheme.primaryBlue),
            onPressed: _fetchInventory,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildSummarySection(),
                    _buildSearchBar(),
                    Expanded(
                      child: _filteredInventory.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _fetchInventory,
                              color: MyTheme.primaryBlue,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: _filteredInventory.length,
                                itemBuilder: (context, index) => _buildInventoryCard(_filteredInventory[index]),
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemModal,
        backgroundColor: MyTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Items',
              _totalItems.toString(),
              Icons.inventory_2_rounded,
              MyTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Low Stock',
              _lowStockCount.toString(),
              Icons.warning_amber_rounded,
              _lowStockCount > 0 ? MyTheme.criticalRed : MyTheme.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _applySearch();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search medicine/supplies...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryCard(dynamic item) {
    final int quantity = item['quantity'] ?? 0;
    final bool isLowStock = quantity < 10;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLowStock ? MyTheme.criticalRed.withValues(alpha: 0.2) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isLowStock ? MyTheme.criticalRed : MyTheme.primaryBlue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item['unit']?.toString().toLowerCase().contains('tab') == true 
                  ? Icons.medication_rounded 
                  : Icons.inventory_2_rounded,
                color: isLowStock ? MyTheme.criticalRed : MyTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Unknown Item',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$quantity ${item['unit']}',
                        style: TextStyle(
                          color: isLowStock ? MyTheme.criticalRed : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: isLowStock ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: MyTheme.criticalRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LOW STOCK',
                            style: TextStyle(color: MyTheme.criticalRed, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 22, color: Colors.grey),
                    onPressed: quantity > 0 ? () => _updateQuantity(item['id'], quantity, -1) : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 22, color: MyTheme.primaryBlue),
                    onPressed: () => _updateQuantity(item['id'], quantity, 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? "Inventory Empty" : "No results found",
            style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
              ? "Add items to track your stock." 
              : "Try a different search term.",
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: MyTheme.criticalRed),
            const SizedBox(height: 16),
            Text(_errorMsg!, textAlign: TextAlign.center, style: const TextStyle(color: MyTheme.textDark)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchInventory,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
