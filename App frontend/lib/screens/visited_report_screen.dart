import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../providers/app_state_provider.dart';

class VisitedReportScreen extends StatefulWidget {
  const VisitedReportScreen({super.key});

  @override
  State<VisitedReportScreen> createState() => _VisitedReportScreenState();
}

class _VisitedReportScreenState extends State<VisitedReportScreen> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _todayVisits = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      
      // 1. Ensure we have latest visits and individuals
      await Future.wait([
        provider.fetchVisits(),
        provider.fetchIndividuals(),
      ]);

      // 2. Fetch households to get house numbers/labels
      Map<String, String> houseMap = {};
      try {
        final houseResponse = await ApiService.get('/households');
        final houses = houseResponse['households'] as List<dynamic>? ?? [];
        
        for (var h in houses) {
          final id = h['householdId'] ?? h['id'] ?? '';
          final num = h['displayId'] ?? h['houseNumber'] ?? '';
          final head = h['headName'] ?? '';
          houseMap[id] = 'H$num – $head';
        }
      } catch (e) {
        debugPrint('Household API failed, using fallback labels for demo');
        // Fallback for demo purposes
        houseMap = {
          'h1': 'H101 – Sharma Family',
          'h2': 'H102 – Verma Villa',
          'h3': 'H204 – Patel House',
          'h4': 'H305 – Singh Family',
        };
      }

      // 3. Filter selected date's visits
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      print('DEBUG: Total visits in local memory: ${provider.visits.length}');
      print('DEBUG: Filtering for date: $dateStr');
      if (provider.visits.isNotEmpty) {
        print('DEBUG: Example visit date: ${provider.visits[0]['visitDate']}');
      }

      final filteredVisits = provider.visits.where((v) {
        final visitDateStr = v['visitDate'] ?? '';
        return visitDateStr.startsWith(dateStr);
      }).toList();

      print('DEBUG: Found ${filteredVisits.length} matching visits for $dateStr');

      // 4. Map visits with individual and house info
      final List<Map<String, dynamic>> processedVisits = [];
      for (var v in filteredVisits) {
        final patientId = v['patientId'];
        
        // Find individual in local cache
        final individual = provider.individuals.firstWhere(
          (p) => p['id'] == patientId,
          orElse: () => null,
        );

        // Extract patient info - fallback to backend-provided 'patient' object if local individual missing
        final patientMetadata = v['patient'] ?? individual;
        final patientName = patientMetadata != null ? patientMetadata['name'] : 'Unknown';
        
        // Extract house info
        String? houseId;
        String houseLabel = 'Unknown House';
        
        if (individual != null) {
          houseId = individual['householdId'];
          houseLabel = houseMap[houseId] ?? 'House $houseId';
        } else if (v['patient'] != null && v['patient']['household'] != null) {
          // Fallback using direct patient->household data from backend
          final hNum = v['patient']['household']['houseNumber'];
          houseLabel = 'H$hNum';
        }

        processedVisits.add({
          'houseId': houseId,
          'houseLabel': houseLabel,
          'patientName': patientName ?? 'Unknown',
          'visitType': v['visitType'] ?? 'Routine',
          'time': _formatVisitTime(v['visitDate']),
          'outcome': v['outcome'] ?? '',
        });
      }

      // 5. Sort by house label
      processedVisits.sort((a, b) => a['houseLabel'].compareTo(b['houseLabel']));

      if (mounted) {
        setState(() {
          _todayVisits = processedVisits;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading report: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatVisitTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return '--:--';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: MyTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReportData();
    }
  }

  Future<void> _downloadReport() async {
    if (_todayVisits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to download!'))
      );
      return;
    }

    try {
      // 1. Check Permissions
      if (!kIsWeb && io.Platform.isAndroid) {
        await Permission.storage.request();
      }

      // 2. Generate PDF
      final pdf = pw.Document();
      final dateStr = DateFormat('dd MMMM yyyy').format(_selectedDate);
      final filenameDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('ASHA-Setu Daily Visit Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text(dateStr, style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['House', 'Individual Name', 'Visit Type', 'Time'],
              data: _todayVisits.map((v) => [
                v['houseId'] != null ? 'H${v['houseLabel'].split('H')[1].split(' ')[0]}' : '--',
                v['patientName'],
                v['visitType'],
                v['time']
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
              },
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 20),
              child: pw.Text('Total Visits: ${_todayVisits.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      );

      // 3. Save and Share/Download
      final bytes = await pdf.save();
      final String fileName = 'ASHA_Report_$filenameDate.pdf';
      
      // On Android, we try to save to Downloads explicitly
      if (!kIsWeb && io.Platform.isAndroid) {
        try {
          final directory = io.Directory('/storage/emulated/0/Download');
          if (await directory.exists()) {
            final io.File file = io.File('${directory.path}/$fileName');
            await file.writeAsBytes(bytes);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report saved to Downloads as $fileName'))
              );
              // Also trigger a share/preview for convenience
              await Printing.sharePdf(bytes: bytes, filename: fileName);
              return;
            }
          }
        } catch (e) {
          debugPrint('Failed to save to Downloads directly, falling back to share: $e');
        }
      }

      // Fallback or iOS or Web: Share the file which allows "Save to Files" or Browser Download
      await Printing.sharePdf(bytes: bytes, filename: fileName);

    } catch (e) {
      debugPrint('PDF Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e'), backgroundColor: MyTheme.criticalRed)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateDisplay = DateFormat('MMMM dd, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: MyTheme.textDark,
        title: const Text('Daily Visit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: MyTheme.primaryBlue),
            onPressed: _downloadReport,
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: MyTheme.primaryBlue),
            onPressed: () async {
              if (_todayVisits.isNotEmpty) {
                 await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
                    final pdf = pw.Document();
                    pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Text('Report Preview')))); // Generic preview
                    return pdf.save();
                 });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MyTheme.primaryBlue))
          : Column(
              children: [
                _buildHeader(dateDisplay),
                Expanded(
                  child: _todayVisits.isEmpty
                      ? _buildEmptyState()
                      : _buildReportTable(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: MyTheme.primaryBlue, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REPORTING DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
                      Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyTheme.textDark)),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MyTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_todayVisits.length} Visits',
                  style: const TextStyle(color: MyTheme.successGreen, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No visits on ${DateFormat('MMM dd').format(_selectedDate)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(_selectedDate.day == DateTime.now().day ? 'Log your first visit today' : 'Try selecting a different date', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<AppStateProvider>(context, listen: false).seedDemoData();
              _loadReportData();
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Add Demo Visits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
                )
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
                child: DataTable(
                  columnSpacing: 8,
                  horizontalMargin: 10,
                  headingRowHeight: 45,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 60,
                  headingRowColor: WidgetStateProperty.all(MyTheme.primaryBlue.withValues(alpha: 0.05)),
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: MyTheme.primaryBlue, fontSize: 11, letterSpacing: 0.2),
                  dataTextStyle: const TextStyle(fontSize: 12, color: MyTheme.textDark),
                  columns: const [
                    DataColumn(label: Expanded(child: Text('HOUSE', textAlign: TextAlign.start))),
                    DataColumn(label: Expanded(child: Text('INDIVIDUAL', textAlign: TextAlign.start))),
                    DataColumn(label: Expanded(child: Text('TYPE', textAlign: TextAlign.center))),
                    DataColumn(label: Expanded(child: Text('TIME', textAlign: TextAlign.center))),
                  ],
                  rows: _todayVisits.map((v) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            v['houseId'] != null ? 'H${v['houseLabel'].split('H')[1].split(' ')[0]}' : '--',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: constraints.maxWidth * 0.25,
                            child: Text(
                              v['patientName'],
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(Center(child: _buildVisitTypeChip(v['visitType']))),
                        DataCell(
                          Center(
                            child: Text(
                              v['time'].replaceFirst(' ', '\n'), 
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 10, height: 1.1),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisitTypeChip(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'emergency': color = MyTheme.criticalRed; break;
      case 'follow-up': color = Colors.orange; break;
      case 'anc follow-up': color = Colors.pink; break;
      case 'pnc follow-up': color = Colors.purple; break;
      default: color = MyTheme.successGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
