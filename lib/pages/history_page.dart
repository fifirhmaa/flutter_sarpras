import 'package:ass_sisforas/models/returnModel.dart';
import 'package:ass_sisforas/services/returnService.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ReturnModel> returns = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchReturns();
  }

  Future<void> fetchReturns() async {
    try {
      final fetchedReturns = await ReturnService().getReturns();
      setState(() {
        returns = fetchedReturns;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Data Return')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : returns.isEmpty
                  ? const Center(child: Text('No return data found'))
                  : ListView.builder(
                      itemCount: returns.length,
                      itemBuilder: (context, index) {
                        final item = returns[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('Return ID: ${item.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User ID: ${item.userId}'),
                                Text('Borrow ID: ${item.borrowId}'),
                                Text('Return Date: ${item.returnDate}'),
                                Text('Condition: ${item.condition}'),
                                Text('Note: ${item.note}'),
                                Text('Status: ${item.status}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
