import 'package:twopointsdb/db.dart';
import 'package:twopointsdb/query.utilities/query.utilities.dart';

void main() {
  print(
    DBController()
      .DB("MyDB")
      .Stack("mystack")
      .Query<Dataset<dynamic>> ([
        
      ])[0]
  );
}