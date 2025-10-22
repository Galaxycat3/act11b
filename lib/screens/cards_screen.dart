import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import '../repositories/card_repository.dart';
import '../models/card_model.dart';
import '../repositories/folder_repository.dart';

class CardsScreen extends StatefulWidget {
  final FolderModel folder;
  const CardsScreen({Key? key, required this.folder}) : super(key: key);

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final cardRepo = CardRepository();
  final folderRepo = FolderRepository();
  late Future<List<CardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = cardRepo.getCardsByFolder(widget.folder.id!);
  }

  Future<void> _refresh() async {
    setState(() {
      _cardsFuture = cardRepo.getCardsByFolder(widget.folder.id!);
    });
  }

  Future<void> _addFromUnassigned() async {
    final count = await cardRepo.countCardsInFolder(widget.folder.id!);
    if (count >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Folder already has 6 cards.')));
      return;
    }

    // open selection of unassigned cards
    final unassigned = await cardRepo.getUnassignedCards();
    if (unassigned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No unassigned cards available.')));
      return;
    }

    final chosen = await showDialog<CardModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Pick a card to add'),
        children: unassigned.take(10).map((c) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, c),
          child: Row(children: [Image.network(c.imageUrl, width: 36, height: 36), const SizedBox(width: 8), Text(c.name)]),
        )).toList(),
      )
    );

    if (chosen != null) {
      chosen.folderId = widget.folder.id;
      await cardRepo.updateCard(chosen);
      // update preview to first card image if previewImage was null
      if (widget.folder.previewImage == null) {
        await folderRepo.updatePreviewImage(widget.folder.id!, chosen.imageUrl);
      }
      _refresh();
    }
  }

  Future<void> _removeCard(CardModel card) async {
    // remove association (set folderId null)
    card.folderId = null;
    await cardRepo.updateCard(card);
    // check folder preview update
    final cardsLeft = await cardRepo.getCardsByFolder(widget.folder.id!);
    if (cardsLeft.isEmpty) {
      await folderRepo.updatePreviewImage(widget.folder.id!, null);
    } else {
      await folderRepo.updatePreviewImage(widget.folder.id!, cardsLeft.first.imageUrl);
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFromUnassigned,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final cards = snapshot.data!;
          if (cards.length < 3) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warning: folder has less than 3 cards.')));
            });
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.7, mainAxisSpacing: 8, crossAxisSpacing: 8
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final c = cards[i];
              return GestureDetector(
                onLongPress: () => _removeCard(c),
                child: Column(
                  children: [
                    Expanded(child: Image.network(c.imageUrl, fit: BoxFit.cover)),
                    const SizedBox(height: 4),
                    Text(c.name, overflow: TextOverflow.ellipsis)
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
//Test github credentials push
