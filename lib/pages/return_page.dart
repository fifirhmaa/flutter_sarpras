import 'dart:convert';
import 'package:ass_sisforas/models/borrowModel.dart';
import 'package:ass_sisforas/models/returnModel.dart';
import 'package:ass_sisforas/services/borrowService.dart';
import 'package:ass_sisforas/services/returnService.dart';
import 'package:ass_sisforas/tokens/storageToken.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({Key? key}) : super(key: key);

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final _formKey = GlobalKey<FormState>();

  List<Borrow> _borrows = [];
  Borrow? _selectedBorrow;
  String? _selectedCondition;
  DateTime? _returnDate;
  String? status;

  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _codeItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBorrows();
  }

  Future<void> _fetchBorrows() async {
    try {
      final borrows = await BorrowService().getBorrows();
      setState(() {
        _borrows = borrows;
      });
    } catch (e) {
      print('Error fetching borrows: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pinjaman: $e')),
      );
    }
  }

  Future<void> _submitReturn() async {
    String status;
    if (_selectedCondition == 'good') {
      status = 'finish';
    } else if (_selectedCondition == 'bad') {
      status = 'finish(bad)';
    } else if (_selectedCondition == 'lost') {
      status = 'finish(lost)';
    } else {
      status = 'finish';
    }

    if (_formKey.currentState!.validate() && _selectedBorrow != null) {
      final userId = await StorageToken.getUserId();
      final newReturn = ReturnModel(
        userId: int.parse(userId!),
        borrowId: _selectedBorrow!.id!,
        returnDate: _returnDateController.text,
        condition: _selectedCondition!,
        note: _notesController.text,
        status: status,
      );

      try {
        final addedReturn = await ReturnService().addReturn(newReturn);
        if (addedReturn.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengembalian berhasil ditambahkan')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menambahkan pengembalian: $addedReturn')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pengembalian: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form belum lengkap')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengembalian')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Borrow>(
                value: _selectedBorrow,
                hint: const Text('Pilih Peminjaman'),
                items: _borrows.map((borrow) {
                  return DropdownMenuItem(
                    value: borrow,
                    child: Text(
                      'ID: ${borrow.id} - ${borrow.item?.name ?? "Item tidak ditemukan"}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBorrow = value;
                    _codeItemController.text = value?.item?.codeItem ?? '';
                  });
                },
                validator: (value) =>
                    value == null ? 'Peminjaman wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeItemController,
                decoration: const InputDecoration(labelText: 'Kode Item'),
                readOnly: true,
              ),
              ListTile(
                title: Text(
                  _returnDate == null
                      ? 'Pilih Tanggal Pengembalian'
                      : 'Tanggal: ${DateFormat('yyyy-MM-dd').format(_returnDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _returnDate = date;
                      _returnDateController.text =
                          DateFormat('yyyy-MM-dd').format(_returnDate!);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(labelText: 'Kondisi Barang'),
                items: const [
                  DropdownMenuItem(value: 'good', child: Text('Baik')),
                  DropdownMenuItem(value: 'bad', child: Text('Rusak')),
                  DropdownMenuItem(value: 'lost', child: Text('Hilang')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Kondisi wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitReturn,
                child: const Text('Simpan Pengembalian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
