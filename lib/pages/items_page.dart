import 'package:ass_sisforas/models/categoryModel.dart';
import 'package:ass_sisforas/models/itemModel.dart';
import 'package:ass_sisforas/services/userService.dart';
import 'package:flutter/material.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final userService = UserService();

  List<CategoryModel> categories = [];
  List<ItemModel> allItems = [];
  List<ItemModel> filteredItems = [];
  int? selectedCategoryId;

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedCategories = await userService.getCategories();
      final fetchedItems = await userService.getItems();

      setState(() {
        categories = fetchedCategories;
        allItems = fetchedItems;
        filteredItems = fetchedItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void filterItemsByCategory(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      if (categoryId == null) {
        filteredItems = allItems;
      } else {
        filteredItems =
            allItems.where((item) => item.categoryId == categoryId).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Data Barang')),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: selectedCategoryId == null,
                      onSelected: (_) => filterItemsByCategory(null),
                    ),
                  );
                }

                final category = categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: selectedCategoryId == category.id,
                    onSelected: (_) => filterItemsByCategory(category.id),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No items found'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        leading: Image.network(
                          'http://127.0.0.1:8000/storage/${item.image}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          'Kode Barang: ${item.codeItem}, Stock: ${item.stock}, Kondisi: ${item.condition}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
