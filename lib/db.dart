import 'package:twopointsdb/utility.dart';

abstract class DBAction {
  void run(DBController db);
}

class Insert<T> implements DBAction {
  List<Map<String, T>> insertData;
  String ID = SpawnID(32);

  Insert(this.insertData);

  @override
  void run(DBController db) {
    for (var doc in insertData) {
      for (var key in doc.keys) {
        for (var value in doc.values) {
          WriteFile(
            db.actualDBStackPath!,
            '$key :: ${T.toString().toLowerCase()} :: $value || $ID\n',
          );
          print(
            '${Style().green(key)} ${Style().bold(Style().green('has been inserted ✅.'.toUpperCase()))} ${Style().green('(with ID: $ID)')}',
          );
        }
      }
    }
  }
}

class DBController {
  String? actualDBPath;
  String? actualDBStackPath;

  DBController DB(String name) {
    actualDBPath = 'Databases/$name';

    if (!CheckDir('Databases/$name')) {
      CreateDir('Databases');
      CreateDir('Databases/$name');
      print(
        '${Style().green(name)} ${Style().bold(Style().green('has been initializated ✅.'.toUpperCase()))}',
      );
    } else {
      print(
        '${Style().red(name)} ${Style().bold(Style().red('has already been initializated ❌.'.toUpperCase()))}',
      );
    }

    return this;
  }

  DBController Stack(String name) {
    actualDBStackPath = '$actualDBPath/$name';

    if (!CheckFile(actualDBStackPath!)) {
      WriteFile(actualDBStackPath!, " ");
      print(
        '${Style().green(name)} ${Style().bold(Style().green('has been stacked ✅.'.toUpperCase()))}',
      );
    } else {
      print(
        '${Style().red(name)} ${Style().bold(Style().red('has already been stacked ❌.'.toUpperCase()))}',
      );
    }

    return this;
  }

  DBController Query(List<DBAction> actions) {
    for (var action in actions) {
      action.run(this);
    }
    return this;
  }
}
