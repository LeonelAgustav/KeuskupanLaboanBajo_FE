import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class DateToStringConverter extends TypeConverter<DateTime, String> {
  const DateToStringConverter();
  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb);
  @override
  String toSql(DateTime value) => value.toIso8601String().substring(0, 10);
}

class Users extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get nama => text()();
  TextColumn get email => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client // keterangan sudah terkirim (0=belum,1=sudah) - tambahan client sesuai Pak Gusti
  @override
  Set<Column> get primaryKey => {id};
}

class Keuskupans extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  TextColumn get alamat => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client
  @override
  Set<Column> get primaryKey => {id};
}

class Parokis extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  TextColumn get alamat => text()();
  TextColumn get keuskupanId => text().customConstraint('REFERENCES keuskupans(id)')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client
  @override
  Set<Column> get primaryKey => {id};
}

class Jenis extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client
  @override
  Set<Column> get primaryKey => {id};
}

class Akuns extends Table {
  TextColumn get id => text()();
  TextColumn get kode => text()();
  TextColumn get nama => text()();
  TextColumn get jenisId => text().customConstraint('REFERENCES jenis(id)')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client
  @override
  Set<Column> get primaryKey => {id};
}

class Jurnals extends Table {
  TextColumn get id => text()();
  TextColumn get keuskupanId => text().customConstraint('REFERENCES keuskupans(id)')();
  TextColumn get tanggal => text().map(const DateToStringConverter())(); // YYYY-MM-DD
  TextColumn get deskripsi => text().nullable()();
  TextColumn get noBukti => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client
  @override
  Set<Column> get primaryKey => {id};
}

class DetilJurnals extends Table {
  TextColumn get id => text()();
  TextColumn get jurnalId => text().customConstraint('REFERENCES jurnals(id)')();
  TextColumn get akunId => text().customConstraint('REFERENCES akuns(id)')();
  TextColumn get parokiId => text().customConstraint('REFERENCES parokis(id)')();
  RealColumn get debit => real().nullable().withDefault(const Constant(0))();
  RealColumn get kredit => real().nullable().withDefault(const Constant(0))();
  TextColumn get keterangan => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // keterangan sudah terkirim - tambahan client
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get rowId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Users, Keuskupans, Parokis, Jenis, Akuns, Jurnals, DetilJurnals, SyncQueues])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ??
            driftDatabase(
              name: 'keuskupan_local',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // tanggal dari DateTime (int) jadi TEXT YYYY-MM-DD -> drop & recreate
            await m.deleteTable('jurnals');
            await m.createTable(jurnals);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<List<SyncQueue>> getPendingSync() =>
      (select(syncQueues)..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).get();

  Future<int> queueCount() async {
    final q = await customSelect('SELECT COUNT(*) as c FROM sync_queues').getSingle();
    return q.data['c'] as int;
  }

  Future<void> enqueue(String table, String rowId, String op, String payload) =>
      into(syncQueues).insert(SyncQueuesCompanion.insert(targetTable: table, rowId: rowId, operation: op, payload: payload));

  Future<void> clearSync(int id) => (delete(syncQueues)..where((t) => t.id.equals(id))).go();

  Future<void> insertJurnalLocal({
    required String id,
    required String keuskupanId,
    required DateTime tanggal,
    String? deskripsi,
    String? noBukti,
  }) async {
    await into(jurnals).insert(JurnalsCompanion.insert(
      id: id,
      keuskupanId: keuskupanId,
      tanggal: tanggal,
      deskripsi: Value(deskripsi),
      noBukti: Value(noBukti),
    ));
    // ponytail: payload lengkap biar BE bisa upsert (keuskupan_id wajib FK)
    final payload = '{"id":"$id","keuskupan_id":"$keuskupanId","tanggal":"${tanggal.toIso8601String()}",'
        '"deskripsi":${deskripsi == null ? 'null' : '"${deskripsi.replaceAll('"', '\\"')}"'},'
        '"no_bukti":${noBukti == null ? 'null' : '"${noBukti.replaceAll('"', '\\"')}"'}}';
    await enqueue('jurnals', id, 'insert', payload);
  }

  Future<List<Jurnal>> getAllJurnal() => (select(jurnals)..where((t) => t.deletedAt.isNull())).get();
}
