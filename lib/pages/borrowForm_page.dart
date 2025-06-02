import 'package:ass_sisforas/models/itemModel.dart';
import 'package:ass_sisforas/pages/home_page.dart';
import 'package:ass_sisforas/services/userService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ass_sisforas/models/borrowModel.dart';
import 'package:ass_sisforas/services/borrowService.dart';
import 'package:ass_sisforas/tokens/storageToken.dart';

class BorrowFormPage extends StatefulWidget {
  @override
  _BorrowFormPageState createState() => _BorrowFormPageState();
}

class _BorrowFormPageState extends State<BorrowFormPage> {
  final _formKey = GlobalKey<FormState>();
  List<ItemModel> _items = [];
  ItemModel? _selectedItem;
  int? _quantity;
  DateTime? _borrowDate;
  DateTime? _returnDate;
  String? _purposes;

  final TextEditingController _codeItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await UserService().getItems();
      setState(() {
        _items = items;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedItem != null &&
        _borrowDate != null) {
      _formKey.currentState!.save();
      final userId = await StorageToken.getUserId();
      if (userId == null) return;

      final borrow = Borrow(
        userId: int.parse(userId),
        itemId: _selectedItem!.id,
        quantity: _quantity,
        borrowDate: DateFormat('yyyy-MM-dd').format(_borrowDate!),
        returnDate: _returnDate != null
            ? DateFormat('yyyy-MM-dd').format(_returnDate!)
            : null,
        purposes: _purposes,
      );

      try {
        await BorrowService().addBorrow(borrow);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Peminjaman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<ItemModel>(
                decoration: InputDecoration(labelText: 'Pilih Barang'),
                items: _items.map((item) {
                  return DropdownMenuItem<ItemModel>(
                    value: item,
                    child: Text('Stock ${item.stock} - Nama ${item.name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value;
                    _codeItemController.text = value?.codeItem ?? '';
                  });
                },
                validator: (value) => value == null ? 'Pilih barang' : null,
              ),
              TextFormField(
                controller: _codeItemController,
                decoration: InputDecoration(labelText: 'Kode Barang'),
                readOnly: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  _quantity = int.parse(value!);
                },
              ),
              ListTile(
                title: Text(_borrowDate == null
                    ? 'Pilih Tanggal Pinjam'
                    : 'Tanggal Pinjam: ${DateFormat('yyyy-MM-dd').format(_borrowDate!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _borrowDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text(_returnDate == null
                    ? 'Pilih Tanggal Kembali (Opsional)'
                    : 'Tanggal Kembali: ${DateFormat('yyyy-MM-dd').format(_returnDate!)}'),
                trailing: Icon(Icons.calendar_today),
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
                    });
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Keperluan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan keperluan';
                  }
                  return null;
                },
                onSaved: (value) {
                  _purposes = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
