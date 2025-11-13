import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/db_helper.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  int selectedColor = 0xFFFFFFFF; // Default color: white

  final List<int> noteColors = [
    0xFFFFFFFF, // white
    0xFFFFF59D, // light yellow
    0xFFAED581, // light green
    0xFF80DEEA, // cyan
    0xFFFFAB91, // orange
    0xFFCE93D8, // lavender
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
      selectedColor = widget.note!.color;
    }
  }

  Future<void> _saveNote() async {
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    final note = NoteModel(
      id: widget.note?.id,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      createdTime: DateTime.now().toIso8601String(),
      isPinned: widget.note?.isPinned ?? false,
      color: selectedColor,
    );

    if (widget.note == null) {
      await DBHelper.insertNote(note);
    } else {
      await DBHelper.updateNote(note);
    }

    Navigator.pop(context, true);
  }

  Widget buildColorPicker() {
    return Row(
      children: noteColors.map((color) {
        bool isSelected = selectedColor == color;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
            });
          },
          child: Container(
            margin: EdgeInsets.only(right: 8),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black, width: 2)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(selectedColor),
      appBar: AppBar(
        backgroundColor: Color(selectedColor),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: titleController,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 8),

            // Content Field
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Note...',
                  border: InputBorder.none,
                ),
              ),
            ),

            // Color Picker
            SizedBox(height: 16),
            Text("Note Color", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            buildColorPicker(),
          ],
        ),
      ),
    );
  }
}
