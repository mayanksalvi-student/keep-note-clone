class NoteModel {
  int? id;
  String title;
  String content;
  String createdTime;
  bool isPinned;
  bool isArchived;
  int color;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    this.isPinned = false,
    this.isArchived = false,
    this.color = 0xFFFFFFFF,
  });

  // ✅ Convert object to map (for insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdTime': createdTime,
      'isPinned': isPinned ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'color': color,
    };
  }

  // ✅ Convert map to object (for fetching from DB)
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdTime: map['createdTime'],
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1, // ✅ No error here
      color: map['color'] ?? 0xFFFFFFFF,
    );
  }
}
