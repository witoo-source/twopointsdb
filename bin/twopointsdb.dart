import 'package:twopointsdb/db.dart';

void main() {
  print(
    DBController()
    .DB("MyDB")
    .Stack("mystack")
    .Query<Dataset<String>>([
      INSERT<String>([
        {"test": "test1"}
      ]),
      FIND<String> (
        "test"
      )
    ])[0]
  );
}