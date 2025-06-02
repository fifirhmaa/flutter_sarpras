import 'package:ass_sisforas/pages/borrow_page.dart';
import 'package:ass_sisforas/pages/history_page.dart';
import 'package:ass_sisforas/pages/items_page.dart';
import 'package:ass_sisforas/pages/report_page.dart';
import 'package:ass_sisforas/pages/return_page.dart';
import 'package:ass_sisforas/services/borrowService.dart';
import 'package:ass_sisforas/services/returnService.dart';
import 'package:flutter/material.dart';
import 'package:ass_sisforas/services/userService.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int borrowCount = 0;
  int itemCount = 0;
  int returnCount = 0;
  int fineCount = 0;
  bool isLoading = true;
  String userName = '';

  Future<void> loadAllData() async {
    await Future.wait([
      loadBorrowCount(),
      loadUserName(),
      fetchItemsCount(),
      loadReturnCount(),
      loadFineCount(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadReturnCount() async {
    final countReturn = await ReturnService().getReturnCount();
    setState(() {
      returnCount = countReturn;
    });
  }

  Future<void> fetchItemsCount() async {
    final count = await UserService().getItemCount();
    setState(() {
      itemCount = count;
    });
  }

  Future<void> loadBorrowCount() async {
    final response = await BorrowService().getBorrowCount();
    setState(() {
      borrowCount = response;
    });
  }

  Future<void> loadFineCount() async {
    final response = await BorrowService().getFineCount();
    setState(() {
      fineCount = response;
    });
  }

  Future<void> loadUserName() async {
    final userModel = await UserService().getUser();
    setState(() {
      userName = userModel.name;
    });
  }

  Widget buildCountBox(String title, int count) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('$count', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName.isEmpty ? 'Loading...' : userName),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://avatars.githubusercontent.com/u/44428967?v=4',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAllData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 4 box data
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          buildCountBox('Total Barang', itemCount),
                          buildCountBox('Dipinjam', borrowCount),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          buildCountBox('Dikembalikan', returnCount),
                          buildCountBox('Terlambat', fineCount),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Menu Utama',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    buildMenuItem(Icons.inventory, 'Data Barang', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ItemsPage()),
                      );
                    }),
                    buildMenuItem(Icons.assignment, 'Peminjaman', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BorrowPage()),
                      );
                    }),
                    buildMenuItem(Icons.assignment_return, 'Pengembalian', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReturnPage()),
                      );
                    }),
                    buildMenuItem(Icons.bar_chart, 'Laporan', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportPage()),
                      );
                    }),
                    buildMenuItem(Icons.history, 'Riwayat Peminjaman', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryPage()),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
