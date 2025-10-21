import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'database/models/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DatabaseExample(),
    );
  }
}

class DatabaseExample extends StatefulWidget {
  const DatabaseExample({super.key});

  @override
  State<DatabaseExample> createState() => _DatabaseExampleState();
}

class _DatabaseExampleState extends State<DatabaseExample> {
  final dbHelper = DBHelper.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  
  List<Item> items = [];

  void _addItem() async {
    final newItem = Item(
      name: nameController.text,
      description: descController.text,
    );
    await dbHelper.insertItem(newItem);
    _refreshItems();
    _clearTextFields();
  }

  void _refreshItems() async {
    final data = await dbHelper.getItems();
    setState(() {
      items = data;
    });
  }

  void _clearTextFields() {
    nameController.clear();
    descController.clear();
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database CRUD Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Item Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addItem,
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _refreshItems,
                    child: const Text('Refresh List'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Items List:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await dbHelper.deleteItem(item.id!);
                        _refreshItems();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
