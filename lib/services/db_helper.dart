import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 2, // bumped version from 1 to 2
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            createdTime TEXT,
            isPinned INTEGER DEFAULT 0,
            color INTEGER DEFAULT 4294967295,
            isArchived INTEGER DEFAULT 0,
            labels TEXT,
            isChecklist INTEGER DEFAULT 0,
            reminderTime TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE labels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE note_labels (
            noteId INTEGER,
            labelId INTEGER,
            FOREIGN KEY(noteId) REFERENCES notes(id),
            FOREIGN KEY(labelId) REFERENCES labels(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Create new tables in version 2
          await db.execute('''
            CREATE TABLE labels (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE note_labels (
              noteId INTEGER,
              labelId INTEGER,
              FOREIGN KEY(noteId) REFERENCES notes(id),
              FOREIGN KEY(labelId) REFERENCES labels(id)
            )
          ''');
        }
        // You can add future migration steps here for higher versions
      },
    );
  }

  // The rest of your DBHelper methods remain the same
  static Future<int> insertNote(NoteModel note) async {
    final db = await getDatabase();
    return await db.insert('notes', note.toMap());
  }

  static Future<List<NoteModel>> getNotes() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> data = await db.query('notes');
    return data.map((e) => NoteModel.fromMap(e)).toList();
  }

  static Future<int> updateNote(NoteModel note) async {
    final db = await getDatabase();
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<int> deleteNote(int id) async {
    final db = await getDatabase();
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> createLabel(String name) async {
    final db = await getDatabase();
    return await db.insert('labels', {'name': name});
  }

  static Future<List<Map<String, dynamic>>> getAllLabels() async {
    final db = await getDatabase();
    return await db.query('labels');
  }

  static Future<void> assignLabelToNote(int noteId, int labelId) async {
    final db = await getDatabase();
    await db.insert('note_labels', {'noteId': noteId, 'labelId': labelId});
  }

  static Future<void> removeLabelFromNote(int noteId, int labelId) async {
    final db = await getDatabase();
    await db.delete(
      'note_labels',
      where: 'noteId = ? AND labelId = ?',
      whereArgs: [noteId, labelId],
    );
  }

  static Future<List<Map<String, dynamic>>> getLabelsForNote(int noteId) async {
    final db = await getDatabase();
    return await db.rawQuery(
      '''
      SELECT labels.id, labels.name
      FROM labels
      INNER JOIN note_labels ON labels.id = note_labels.labelId
      WHERE note_labels.noteId = ?
      ''',
      [noteId],
    );
  }

  static Future<List<NoteModel>> getNotesByLabel(int labelId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> data = await db.rawQuery(
      '''
      SELECT notes.*
      FROM notes
      INNER JOIN note_labels ON notes.id = note_labels.noteId
      WHERE note_labels.labelId = ?
      ''',
      [labelId],
    );
    return data.map((e) => NoteModel.fromMap(e)).toList();
  }
}
