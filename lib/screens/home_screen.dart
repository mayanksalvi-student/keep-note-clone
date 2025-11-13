import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import '../widgets/keep_note_card.dart';
import '../theme/app_colors.dart';
import '../screens/add_edit_note_screen.dart';
import '../models/note_model.dart';
import '../services/db_helper.dart';
import '../screens/archived_screen.dart';
import '../screens/label_notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteModel> notes = [];
  List<NoteModel> filteredNotes = [];
  List<Map<String, dynamic>> allLabels = [];

  String searchQuery = '';
  bool isGrid = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
    loadLabels();
  }

  Future<void> loadNotes() async {
    final data = await DBHelper.getNotes();
    setState(() {
      notes = data;
      filteredNotes = data;
    });
  }

  Future<void> loadLabels() async {
    final labels = await DBHelper.getAllLabels();
    setState(() {
      allLabels = labels;
    });
  }

  Future<void> _addOrEditNote({NoteModel? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
    );
    if (result == true) {
      loadNotes();
    }
  }

  Future<void> _deleteNote(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete this note?'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.deleteNote(id);
      loadNotes();
    }
  }

  void _onFabMenuSelected(String value) {
    if (value == 'new_note') _addOrEditNote();
  }

  void filterNotes(String query) {
    final result = notes.where((note) {
      final titleLower = note.title.toLowerCase();
      final contentLower = note.content.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) ||
          contentLower.contains(searchLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredNotes = result;
    });
  }

  Future<void> _togglePin(NoteModel note) async {
    note.isPinned = !note.isPinned;
    await DBHelper.updateNote(note);
    loadNotes();
  }

  void _showNoteOptions(NoteModel note) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(note.isArchived ? Icons.unarchive : Icons.archive),
              title: Text(note.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () async {
                Navigator.pop(context);
                note.isArchived = !note.isArchived;
                await DBHelper.updateNote(note);
                loadNotes();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () async {
                Navigator.pop(context);
                _deleteNote(note.id!);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildNotesGrid(List<NoteModel> notesList) {
    if (notesList.isEmpty) return SizedBox();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: notesList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isGrid ? 2 : 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isGrid ? 0.9 : 3,
      ),
      itemBuilder: (context, index) {
        final note = notesList[index];

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: DBHelper.getLabelsForNote(note.id!),
          builder: (context, snapshot) {
            final labelNames =
                snapshot.data?.map((e) => e['name'] as String).toList() ?? [];

            return KeepNoteCard(
              title: note.title,
              content: note.content,
              isPinned: note.isPinned,
              onTap: () => _addOrEditNote(note: note),
              onLongPress: () => _showNoteOptions(note),
              onPinTap: () => _togglePin(note),
              color: note.color,
              labels: labelNames,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<NoteModel> pinnedNotes = filteredNotes
        .where((n) => n.isPinned && !n.isArchived)
        .toList();
    List<NoteModel> otherNotes = filteredNotes
        .where((n) => !n.isPinned && !n.isArchived)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Welcome",
                    style: AppFonts.heading.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
            ListTile(leading: Icon(Icons.notes), title: Text('Notes')),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archive'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ArchivedScreen()),
                );
                if (result == true) {
                  loadNotes();
                }
              },
            ),
            ListTile(title: Text("Labels", style: AppFonts.subheading)),
            ...allLabels.map(
              (label) => ListTile(
                title: Text(label['name']),
                onTap: () async {
                  final notes = await DBHelper.getNotesByLabel(label['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabelNotesScreen(
                        labelName: label['name'],
                        notes: notes,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Keep Clone", style: AppFonts.heading),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your notes',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => filterNotes(val),
            ),
          ),
        ),
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: _onFabMenuSelected,
        icon: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: null,
          child: Icon(Icons.add),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(value: 'new_note', child: Text('New Note')),
          PopupMenuItem(value: 'new_list', child: Text('New List (TODO)')),
        ],
        offset: Offset(0, -80),
        elevation: 8,
      ),
      body: filteredNotes.isEmpty
          ? Center(child: Text("No notes found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pinnedNotes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8,
                      ),
                      child: Text("Pinned", style: AppFonts.subheading),
                    ),
                    buildNotesGrid(pinnedNotes),
                  ],
                  if (otherNotes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8,
                      ),
                      child: Text("Others", style: AppFonts.subheading),
                    ),
                    buildNotesGrid(otherNotes),
                  ],
                ],
              ),
            ),
    );
  }
}
