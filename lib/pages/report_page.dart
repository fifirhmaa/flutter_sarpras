import 'dart:convert';
import 'dart:io';
import 'package:ass_sisforas/models/borrowModel.dart';
import 'package:ass_sisforas/services/borrowService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'borrowed'; // default

  bool _isLoading = false;

  Future<void> _pickDate({
    required bool isStartDate,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih tanggal awal dan akhir!')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final borrow = Borrow(
          borrowDate: DateFormat('yyyy-MM-dd').format(_startDate!),
          returnDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          status: _status,
        );

        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin penyimpanan ditolak!')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final pdfBytes = await BorrowService().reportBorrow(borrow);

        final directory = await getExternalStorageDirectory();
        final downloadsPath = directory!.path;

        final file = File(
            '$downloadsPath/borrow_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(pdfBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan berhasil disimpan di: ${file.path}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Peminjaman')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text:
                      _startDate != null ? dateFormat.format(_startDate!) : '',
                ),
                onTap: () => _pickDate(isStartDate: true),
                validator: (value) {
                  if (_startDate == null) {
                    return 'Tanggal mulai wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Akhir',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _endDate != null ? dateFormat.format(_endDate!) : '',
                ),
                onTap: () => _pickDate(isStartDate: false),
                validator: (value) {
                  if (_endDate == null) {
                    return 'Tanggal akhir wajib diisi';
                  }
                  if (_endDate!.isBefore(_startDate!)) {
                    return 'Tanggal akhir tidak boleh sebelum tanggal mulai';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'borrowed', child: Text('Borrowed')),
                  DropdownMenuItem(value: 'returned', child: Text('Returned')),
                  DropdownMenuItem(value: 'fine', child: Text('Fine')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Submit
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _generateReport,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate Laporan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
