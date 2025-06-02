import 'package:ass_sisforas/pages/borrowForm_page.dart';
import 'package:flutter/material.dart';
import 'package:ass_sisforas/models/borrowModel.dart';
import 'package:ass_sisforas/services/borrowService.dart'; // ganti sesuai lokasi file

class BorrowPage extends StatefulWidget {
  const BorrowPage({Key? key}) : super(key: key);

  @override
  State<BorrowPage> createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  List<Borrow> borrows = [];
  bool isLoading = true;
  String? error;
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    fetchBorrows();
  }

  Future<void> fetchBorrows() async {
    try {
      final fetchedBorrows = await BorrowService().getBorrows();
      setState(() {
        borrows = fetchedBorrows;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBorrows = selectedStatus == 'Semua'
        ? borrows
        : borrows.where((borrow) {
            switch (selectedStatus) {
              case 'Dipinjam':
                return borrow.status == 'borrowed';
              case 'Dikembalikan':
                return borrow.status == 'returned';
              case 'Didenda':
                return borrow.status == 'fine';
              default:
                return false;
            }
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Borrow'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BorrowFormPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Pinjam'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFilterButton('Semua'),
                          _buildFilterButton('Dipinjam'),
                          _buildFilterButton('Dikembalikan'),
                          _buildFilterButton('Didenda'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredBorrows.isEmpty
                          ? const Center(child: Text('No borrow data found'))
                          : ListView.builder(
                              itemCount: filteredBorrows.length,
                              itemBuilder: (context, index) {
                                final item = filteredBorrows[index];
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text('Borrow ID: ${item.id}'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('User ID: ${item.userId}'),
                                        Text('Item ID: ${item.itemId}'),
                                        Text('Quantity: ${item.quantity}'),
                                        Text('Borrow Date: ${item.borrowDate}'),
                                        Text('Purposes: ${item.purposes}'),
                                        Text('Status: ${item.status}'),
                                        Text(
                                            'Is Approved: ${item.isApproved == 0 ? 'Belum disetujui' : 'Disetujui'}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterButton(String status) {
    final isSelected = selectedStatus == status;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
      child: Text(status),
    );
  }
}
