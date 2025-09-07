import 'package:twopointsdb/db.dart';
import 'package:twopointsdb/utility.dart';

class GETALL implements DBAction<Stack<dynamic>> {
  @override
  Stack<dynamic> run(DBController db) {
    return Parse(db).result;
  }
}