import 'package:twopointsdb/db.dart';

void main() {
  DBController()
    .DB("MyDB")
    .Stack("mystack")
    .Query([
      Insert<String> ([
        { "myKey": "Hola, esto es un string" }
      ])
    ])
  ;
}