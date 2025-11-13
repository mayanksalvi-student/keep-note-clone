import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../widgets/keep_note_card.dart';
import '../theme/app_fonts.dart';

class LabelNotesScreen extends StatelessWidget {
  final String labelName;
  final List<NoteModel> notes;

  const LabelNotesScreen({super.key, required this.labelName, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(labelName, style: AppFonts.heading)),
      body: notes.isEmpty
          ? Center(child: Text("No notes under this label"))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: notes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return KeepNoteCard(
                    title: note.title,
                    content: note.content,
                    isPinned: note.isPinned,
                    color: note.color,
                    onTap: () {},
                    onLongPress: () {},
                    onPinTap: () {},
                  );
                },
              ),
            ),
    );
  }
}
