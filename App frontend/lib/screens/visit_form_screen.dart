import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key});

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Step 2 Data
  final List<Map<String, dynamic>> _members = [
    {'name': 'Anita Sharma', 'age': 32, 'gender': 'F', 'risk': 'High', 'pregnant': true},
    {'name': 'Rajesh Sharma', 'age': 35, 'gender': 'M', 'risk': 'Low', 'pregnant': false},
    {'name': 'Rohan Sharma', 'age': 5, 'gender': 'M', 'risk': 'Medium', 'pregnant': false},
  ];

  // Step 3 Data
  bool _fever = false;
  bool _cough = false;
  bool _breathing = false;
  bool _diarrhea = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('New Household Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildCurrentStepContent(),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildProgressBar() {
    double progress = _currentStep / _totalSteps;
    String title = 'Basic Information';
    if (_currentStep == 2) title = 'Member Details';
    if (_currentStep == 3) title = 'Health Checklist';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: MyTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Step $_currentStep of $_totalSteps',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              color: MyTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField('Household ID', 'Enter or scan ID'),
        const SizedBox(height: 16),
        _buildInputField('Head of Family', 'Full Name'),
        const SizedBox(height: 16),
        _buildInputField('Phone Number', 'Contact Number', isPhone: true),
        const SizedBox(height: 24),
        _buildLocationSection(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Family Members',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyTheme.textDark),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: MyTheme.primaryBlue),
              label: const Text('Add Member', style: TextStyle(color: MyTheme.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._members.map((member) => _buildMemberCard(member)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptoms Checklist',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyTheme.textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check all that apply to any family member.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _buildCheckbox('Fever / High Temperature', _fever, (v) => setState(() => _fever = v!)),
        _buildCheckbox('Persistent Cough', _cough, (v) => setState(() => _cough = v!)),
        _buildCheckbox('Breathing Difficulty', _breathing, (v) => setState(() => _breathing = v!)),
        _buildCheckbox('Diarrhea / Stomach Pain', _diarrhea, (v) => setState(() => _diarrhea = v!)),
        
        const SizedBox(height: 32),
        const Text(
          'Observations / Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyTheme.textDark),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: MyTheme.primaryBlue, size: 32),
              ),
              const SizedBox(height: 8),
              const Text('Tap to Record Voice Note', style: TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    Color riskColor = Colors.green;
    if (member['risk'] == 'Medium') riskColor = Colors.orange;
    if (member['risk'] == 'High') riskColor = MyTheme.criticalRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Text(member['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: MyTheme.primaryBlue)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${member['age']} Yrs • ${member['gender']}', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${member['risk']} Risk',
                  style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          if (member['pregnant'] == true) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.pregnant_woman, size: 20, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Pregnant', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                const Spacer(),
                 const Icon(Icons.check_circle, size: 18, color: MyTheme.successGreen),
                const SizedBox(width: 4),
                 const Text('ANC Due', style: TextStyle(fontSize: 12, color: MyTheme.successGreen, fontWeight: FontWeight.bold)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? MyTheme.criticalRed : Colors.grey.shade200),
      ),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: MyTheme.criticalRed,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_currentStep < _totalSteps) {
              setState(() => _currentStep++);
            } else {
              // Submit
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visit Report Submitted Successfully!')),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_currentStep < _totalSteps ? 'Next Step' : 'Submit Report', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Icon(_currentStep < _totalSteps ? Icons.arrow_forward : Icons.check),
            ],
          ),
        ),
      ),
    );
  }

  // Reusing Step 1 Widgets from previous implementation
  Widget _buildInputField(String label, String hint, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF424242)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mic, color: MyTheme.primaryBlue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: MyTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Current Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF424242))),
              ],
            ),
            Text('GPS VERIFIED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: MyTheme.successGreen)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Icon(Icons.location_on, size: 48, color: MyTheme.primaryBlue),
          ),
        ),
      ],
    );
  }
}
