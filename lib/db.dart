import 'package:twopointsdb/utility.dart';

abstract class DBAction<T> {
  T run(DBController db);
}

typedef Dataset<T> = List<Map<String, T>>;
typedef Stack<T> = Map<String, T>;

class INSERT<T> implements DBAction<void> {
  List<Map<String, T>> insertData;

  INSERT(this.insertData);

  @override
  void run(DBController db) {
    for (var doc in insertData) {
      String ID = SpawnID(32);
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

class FIND<T> implements DBAction<List<Map<String, T>>> {
  List<String> keys;

  FIND(this.keys);

  @override
  List<Map<String, T>> run(DBController db) {
    List<Map<String, T>> wrappedValues = [];
    for (var key in keys) {
      for (var line in WrapLines(ReadFile(db.actualDBStackPath!))) {
        final List<String> secs = line.split('::');
        if (secs[0].trim() == key) {
          wrappedValues.add({key: secs[2].split('||')[0].trim() as T});
        }
      }
    }

    return wrappedValues;
  }
}

class GET implements DBAction<Map<String, dynamic>> {
  @override
  Map<String, dynamic> run(DBController db) {
    Map<String, dynamic> stackDatasets = {};

    for (var line in WrapLines(ReadFile(db.actualDBStackPath!))) {
      final List<String> secs = line.split(' :: ');
      if (secs.length < 3) continue;
      stackDatasets[secs[0].trim()] = secs[2].split('||')[0].trim();
    }

    return stackDatasets;
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

  List<F> Query<F>(List<DBAction> actions) {
    List<F> returnQueue = [];
    try {
      for (var action in actions) {
        final result = action.run(this);

        if (result is F) {
          returnQueue.add(result);
        } else if (result != null) {
          throw Exception(
            "Types don't match with the required value in the query.",
          );
        }
      }
    } catch (e) {
      print(e);
    }

    return returnQueue;
  }
}
