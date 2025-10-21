class CardModel {
  int? id;
  String name;
  String suit;
  String imageUrl;
  String? imageBytes;
  int? folderId;
  DateTime createdAt;

  CardModel({
    this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    this.imageBytes,
    this.folderId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
      'folderId': folderId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      suit: map['suit'] as String,
      imageUrl: map['imageUrl'] as String,
      imageBytes: map['imageBytes'] as String?,
      folderId: map['folderId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
