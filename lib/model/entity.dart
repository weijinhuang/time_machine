import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final RECORD_ID = "recordId";
final COMMENT = "comment";
final START_DATE_TIME = "startTime";
final END_DATE_TIME = "endDateTime";
final IMAGE = "image";
final HAS_SELECT_TIME = "hasSelectTime";
final TABLE_RECORD = "table_record";
final RECORD_TYPE = "recordType";
final DB_RECORD = "db_record.db";
final TITLE = "title";

class RecordEntity {
  RecordEntity(
      {this.comment,
      this.startDateTime,
      this.endDateTime,
      this.image,
      this.title,
      this.recordType,
      this.recordId});

  String comment = '';
  int startDateTime = -1;
  int endDateTime = -1;
  String image;
  String title = '';
  String recordType;
  int recordId;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COMMENT: comment,
      START_DATE_TIME: startDateTime,
      END_DATE_TIME: endDateTime,
      IMAGE: image,
      TITLE: title,
      RECORD_TYPE: recordType,
    };
    if (null == recordId) {
      map[RECORD_ID] = recordId;
    }
    return map;
  }

  RecordEntity.fromMap(Map<String, dynamic> map) {
    comment = map[COMMENT];
    startDateTime = map[START_DATE_TIME];
    endDateTime = map[END_DATE_TIME];
    image = map[IMAGE];
    title = map[TITLE];
    recordType = map[RECORD_TYPE];
    recordId = map[RECORD_ID];
  }
}

class RecordEntityProvider {
  Database db;

  Future<RecordEntityProvider> open() async {
    var databasePaht = await getDatabasesPath();
    String path = join(databasePaht, DB_RECORD);
    db = await openDatabase(path, version: 1,
        onUpgrade: ((Database db, int oldVersion, int newVersion) {
//      if (newVersion == 2) {
//        db.execute(' alter table $TABLE_RECORD add column $TITLE text');
//        db.execute(' alter table $TABLE_RECORD add column $RECORD_TYPE text');
//      }
    }), onCreate: (
      Database db,
      int version,
    ) async {
      await db.execute(
          'create table $TABLE_RECORD($RECORD_ID integer primary key autoincrement,$COMMENT text,$START_DATE_TIME integer,$END_DATE_TIME integer,$IMAGE text,$TITLE text,$RECORD_TYPE text)');
    });
    return this;
  }

  Future<RecordEntity> insert(RecordEntity record) async {
    record.recordId = await db.insert(TABLE_RECORD, record.toMap());
    return record;
  }

  Future<RecordEntity> get(int id) async {
    List<Map> maps =
        await db.query(TABLE_RECORD, where: '$RECORD_ID = ?', whereArgs: [id]);
    if (null != maps && maps.length > 0) {
      return RecordEntity.fromMap(maps.first);
    }
    return null;
  }

  Future<List<RecordEntity>> getAll() async {
    List<Map> maps = await db.query(TABLE_RECORD);
    List<RecordEntity> results = List();
    for (Map m in maps) {
      results.add(RecordEntity.fromMap(m));
    }
    return results;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(TABLE_RECORD, where: '$RECORD_ID = ?', whereArgs: [id]);
  }

  Future<int> update(RecordEntity record) async {
    return await db.update(TABLE_RECORD, record.toMap(),
        where: '$RECORD_ID = ?', whereArgs: [record.recordId]);
  }

  Future close() async => db.close();
}
