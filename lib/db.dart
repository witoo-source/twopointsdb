import 'dart:io';
import 'dart:typed_data';
import 'package:twopointsdb/utility.dart';

abstract class DBAction<T> {
  T run(DBController db);
}

typedef Dataset<T> = List<Map<String, T>>;
typedef Stack<T> = Map<String, T>;

class DBController {
  String? actualDBPath;
  String? actualDBStackPath;

  DBController DB(String name) {
    actualDBPath = 'Databases/$name';

    if (!CheckDir(actualDBPath!)) {
      CreateDir('Databases');
      CreateDir(actualDBPath!);
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
      File(actualDBStackPath!).writeAsBytesSync(Uint8List.fromList([0]));
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
