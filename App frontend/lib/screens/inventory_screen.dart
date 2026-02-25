import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _supplies = [
    {
      'name': 'ORS Packets',
      'icon': Icons.water_drop_outlined,
      'iconColor': Color(0xFF1565C0),
      'qty': 50,
      'unit': 'Packets',
      'status': 'good', // good, low, out
      'statusLabel': 'Good Stock',
      'isEmergency': false,
    },
    {
      'name': 'Paracetamol 500mg',
      'icon': Icons.medication_outlined,
      'iconColor': Color(0xFF6A1B9A),
      'qty': 10,
      'unit': 'Tablets',
      'status': 'low',
      'statusLabel': 'Low Stock',
      'isEmergency': false,
    },
    {
      'name': 'Iron & Folic Acid',
      'icon': Icons.vaccines_outlined,
      'iconColor': Color(0xFF1565C0),
      'qty': 0,
      'unit': 'Tablets',
      'status': 'out',
      'statusLabel': 'Out of Stock',
      'isEmergency': true,
    },
    {
      'name': 'Zinc Tablets',
      'icon': Icons.medical_services_outlined,
      'iconColor': Color(0xFF1565C0),
      'qty': 25,
      'unit': 'Tablets',
      'status': 'good',
      'statusLabel': 'Good Stock',
      'isEmergency': false,
    },
    {
      'name': 'Condoms (Nirodh)',
      'icon': Icons.people_outline,
      'iconColor': Color(0xFF1565C0),
      'qty': 5,
      'unit': 'Packets',
      'status': 'low',
      'statusLabel': 'Low Stock',
      'isEmergency': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredSupplies {
    if (_searchQuery.isEmpty) return _supplies;
    return _supplies.where((s) =>
      s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  int get _goodCount => _supplies.where((s) => s['status'] == 'good').length;
  int get _lowCount => _supplies.where((s) => s['status'] == 'low').length;
  int get _outCount => _supplies.where((s) => s['status'] == 'out').length;

  Color _statusColor(String status) {
    switch (status) {
      case 'good': return MyTheme.successGreen;
      case 'low': return MyTheme.warningOrange;
      case 'out': return MyTheme.criticalRed;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildSummaryRow(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Supplies List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textDark,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredSupplies.length,
                itemBuilder: (context, index) {
                  return _buildSupplyCard(_filteredSupplies[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          // Back button + title
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: MyTheme.textDark),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Inventory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textDark,
                  ),
                ),
                Text(
                  'Last updated: Today, 09:30 AM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_none, size: 28, color: MyTheme.textDark),
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: MyTheme.criticalRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search medicines (e.g. ORS, Zinc)',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF0F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _buildSummaryCard('GOOD', _goodCount.toString(), Icons.check_circle, MyTheme.successGreen),
          const SizedBox(width: 10),
          _buildSummaryCard('LOW', _lowCount.toString(), Icons.warning_amber_rounded, MyTheme.warningOrange),
          const SizedBox(width: 10),
          _buildSummaryCard('OUT', _outCount.toString(), Icons.error, MyTheme.criticalRed),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color == MyTheme.successGreen ? MyTheme.textDark : color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyCard(Map<String, dynamic> supply) {
    final String status = supply['status'];
    final Color statusColor = _statusColor(status);
    final bool isOut = status == 'out';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (supply['iconColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(supply['icon'] as IconData, color: supply['iconColor'] as Color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supply['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MyTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(supply['statusLabel'], style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      supply['qty'].toString(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isOut ? MyTheme.criticalRed : (status == 'low' ? MyTheme.warningOrange : MyTheme.textDark),
                      ),
                    ),
                    Text(supply['unit'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRefillButton(supply),
          ],
        ),
      ),
    );
  }

  Widget _buildRefillButton(Map<String, dynamic> supply) {
    final bool isOut = supply['status'] == 'out';
    final bool isLow = supply['status'] == 'low';
    final bool isFilled = isOut || isLow;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isOut ? "Emergency refill" : "Refill"} requested for ${supply['name']}'),
              backgroundColor: isOut ? MyTheme.criticalRed : MyTheme.primaryBlue,
            ),
          );
        },
        icon: Icon(
          isOut ? Icons.warning_amber_rounded : Icons.shopping_cart_outlined,
          size: 18,
          color: isFilled ? Colors.white : MyTheme.textDark,
        ),
        label: Text(
          isOut ? 'Request Emergency Refill' : 'Request Refill',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isFilled ? Colors.white : MyTheme.textDark,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isFilled ? MyTheme.primaryBlue : Colors.transparent,
          side: BorderSide(color: isFilled ? MyTheme.primaryBlue : Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: MyTheme.primaryBlue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
