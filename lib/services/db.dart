import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/surgery_case.dart';

class VetcareDb {
  static final VetcareDb _i = VetcareDb._();
  VetcareDb._();
  factory VetcareDb() => _i;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'vetcare_postop.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE surgeries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petName TEXT NOT NULL,
            phone TEXT NOT NULL,
            classType TEXT NOT NULL,
            surgeryDate TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            status TEXT NOT NULL
          );
        ''');
      },
    );
    return _db!;
  }

  Future<int> insertCase(SurgeryCase c) async {
    final d = await db;
    return d.insert('surgeries', c.toMap());
  }

  Future<void> insertMany(List<SurgeryCase> list) async {
    final d = await db;
    final batch = d.batch();
    for (final c in list) {
      batch.insert('surgeries', c.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<SurgeryCase>> casesDueOn(DateTime day) async {
    final d = await db;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await d.query('surgeries',
        where: 'dueDate >= ? AND dueDate < ? AND status = ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String(), 'pending'],
        orderBy: 'dueDate ASC');
    return rows.map(SurgeryCase.fromMap).toList();
  }

  Future<List<SurgeryCase>> allCases() async {
    final d = await db;
    final rows = await d.query('surgeries', orderBy: 'dueDate ASC');
    return rows.map(SurgeryCase.fromMap).toList();
  }

  Future<int> markDone(int id) async {
    final d = await db;
    return d.update('surgeries', {'status': 'done'}, where: 'id = ?', whereArgs: [id]);
  }
}
