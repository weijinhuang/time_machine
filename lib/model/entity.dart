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

class RecordEntity {
  RecordEntity(
      {this.recordId,
      this.comment,
      this.startDateTime,
      this.endDateTime,
      this.image,
      this.isBlank,
        this.recordType});

  int recordId;
  String comment = '';
  bool hasSelectTime = false;
  int startDateTime = -1;
  int endDateTime = -1;
  String image;
  bool isBlank = false;
  String recordType;
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COMMENT: comment,
      START_DATE_TIME: startDateTime,
      END_DATE_TIME: endDateTime,
      IMAGE: image,
      RECORD_TYPE: recordType
    };
    if (null == recordId ) {
      map[RECORD_ID] = recordId;
    }
    map[HAS_SELECT_TIME] = hasSelectTime==true?1:0;
    return map;
  }

  RecordEntity.fromMap(Map<String, dynamic> map) {
    recordId = map[RECORD_ID];
    comment = map[COMMENT];
    startDateTime = map[START_DATE_TIME];
    endDateTime = map[END_DATE_TIME];
    image = map[IMAGE];
    recordType = map[RECORD_TYPE];
    hasSelectTime = map[HAS_SELECT_TIME]==1?true:false;
  }
}

class RecordEntityProvider {
  Database db;

  Future<RecordEntityProvider> open() async {
    var databasePaht = await getDatabasesPath();
    String path = join(databasePaht, DB_RECORD);
    db = await openDatabase(path, version: 2,
        onUpgrade: ((Database db, int oldVersion, int newVersion) {
          if (newVersion == 2) {
            db.execute(
                ' alter table $TABLE_RECORD add column $RECORD_TYPE text');
          }
        }),
        onCreate: (Database db, int version,) async {
      await db.execute('create table $TABLE_RECORD($RECORD_ID integer primary key autoincrement,$COMMENT text,$START_DATE_TIME integer,$END_DATE_TIME integer,$HAS_SELECT_TIME integer,$IMAGE text)');
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
