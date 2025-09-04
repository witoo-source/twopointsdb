import 'package:twopointsdb/db.dart';

void main() {
  print(
    DBController()
    .DB("MyDB")
    .Stack("mystack")
    .Query<Stack<dynamic>>([
      GET()
    ])[0]
  );
}