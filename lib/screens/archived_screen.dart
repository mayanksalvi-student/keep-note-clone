import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/db_helper.dart';
import '../theme/app_fonts.dart';
import '../widgets/keep_note_card.dart';

class ArchivedScreen extends StatefulWidget {
  const ArchivedScreen({super.key});

  @override
  State<ArchivedScreen> createState() => _ArchivedScreenState();
}

class _ArchivedScreenState extends State<ArchivedScreen> {
  List<NoteModel> archivedNotes = [];

  @override
  void initState() {
    super.initState();
    loadArchivedNotes();
  }

  Future<void> loadArchivedNotes() async {
    final notes = await DBHelper.getNotes();
    setState(() {
      archivedNotes = notes.where((n) => n.isArchived).toList();
    });
  }

  Future<void> unarchiveNote(NoteModel note) async {
    note.isArchived = false;
    await DBHelper.updateNote(note);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Note unarchived")));

    // ✅ Option 1: Remove from current list only
    setState(() {
      archivedNotes.removeWhere((n) => n.id == note.id);
    });

    // ✅ Option 2 (better): Reload full list
    // await loadArchivedNotes();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Archived"), elevation: 0),
      body: archivedNotes.isEmpty
          ? Center(child: Text("No archived notes"))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: archivedNotes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final note = archivedNotes[index];
                  return KeepNoteCard(
                    title: note.title,
                    content: note.content,
                    isPinned: note.isPinned,
                    color: note.color,
                    onTap: () {},
                    onLongPress: () => unarchiveNote(note),
                    onPinTap: () {},
                  );
                },
              ),
            ),
    );
  }
}
