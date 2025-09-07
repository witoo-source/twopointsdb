import 'dart:io';
import 'package:twopointsdb/db.dart';
import 'package:twopointsdb/utility.dart';

class INDEX implements DBAction<void> {
  List<String> keys;
  late Directory _dir;
  late DBController _dbInstance;

  INDEX(this.keys);

  void _index(String key) {
    File(
      '${_dbInstance.actualDBPath}/indexed/$key.idx.db',
    ).writeAsStringSync("${Parse(_dbInstance).indexedOffset[key]}");
  }

  @override
  void run(DBController db) {
    _dir = Directory('${db.actualDBPath!}/indexed');
    _dbInstance = db;
    for (String key in keys) {
      if (_dir.existsSync()) {
        _index(key);
      } else {
        _dir.createSync();
        _index(key);
      }
    }
  }
}