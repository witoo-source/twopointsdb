import 'package:twopointsdb/db.dart';

void main() {
  print(
    DBController()
    .DB("MyDB")
    .Stack("mystack")
    .Query<Dataset<String>>([
      Insert<String> ([
        {"username": "Wito"},
        {"mail": "witoo132@icloud.com"},
      ]),
      Insert<int> ([
        {"age": 16},
        {"birthDate": 27062009}
      ]),
      Find<String> ([
        "username"
      ])
    ])[0]
  );
}