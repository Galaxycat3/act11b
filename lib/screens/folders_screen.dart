import 'package:flutter/material.dart';
import '../repositories/folder_repository.dart';
import '../models/folder_model.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({Key? key}) : super(key: key);

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final repo = FolderRepository();
  late Future<List<FolderModel>> _foldersFuture;

  @override
  void initState() {
    super.initState();
    _foldersFuture = repo.getAllFolders();
  }

  Future<void> _refresh() async {
    setState(() {
      _foldersFuture = repo.getAllFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: FutureBuilder<List<FolderModel>>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final folders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.0, crossAxisSpacing: 12, mainAxisSpacing: 12
              ),
              itemCount: folders.length,
              itemBuilder: (context, i) {
                final f = folders[i];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => CardsScreen(folder: f)));
                    _refresh();
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: f.previewImage != null
                             ? Image.network(f.previewImage!, fit: BoxFit.cover, width: double.infinity)
                             : Container(color: Colors.grey[200], alignment: Alignment.center, child: Text(f.name)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              FutureBuilder<int>(
                                future: repo.countCardsInFolder(f.id!),
                                builder: (c, s) => Text(s.data?.toString() ?? '0'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
