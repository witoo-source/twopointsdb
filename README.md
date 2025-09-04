# TwopointsDB 

## What is TwopointsDB?
- This DB system has been developed with the purpose of allowing y'all to manage constant data with easy and declarative API statements. This project is made in `Dart` but will be ported soon to the main programming languages (`JavaScript/TypeScript`, `Python`, `.NET C#`, etc..). This system just creates local DBs, but the main idea is to launch a cloud-based service to host your DBs in the cloud as some other services do.

## How does TwopointsDB work?

Well, TwopointsDB use a main class known as `DBController`, there is where you call all the statements (like DB creations, Stacks creations and the Query's). The systems works creating directories (the DBs) and files (the Stacks), then, the querys make their function in the selected Stack (a file). The internal engine saves the data in a sequence of bytes structured like this:
- ### Header
  - 01 <- `represents the number of datasets which are available to read (max 255 per stack)`
- ### Key structure
  - 03 <- `represents the lenght of the next KEY to be readed`
  - 7B <- `represents the ASCII value for the char[1] of the KEY`
  - 9C <- `represents the ASCII value for the char[2] of the KEY`
  - 5J <- `represents the ASCII value for the char[3] of the KEY`
- ### Type
  - 01 <- `represents the typeID of the actual VALUE (string[01], int[02] and boolean[03])`
- ### Value structure
  - 02 <- `represents the lenght of the next VALUE to be readed`
  - 2L <- `represents the ASCII value for the char[1] of the VALUE`
  - 8P <- `represents the ASCII value for the char[2] of the VALUE`


> Here there's an example of how do you initialize a new DB:

```dart
import 'package:twopointsdb/db.dart';

void main() {
  DBController()
    .DB("MyDB")
    .Stack("mystack")
    .Query([
      INSERT<String> ([
        { "myKey": "your string here" }
      ])
    ])
  ;
}
```

- ```dart
  .DB("MyDB") // It creates a new DB (Directory) or select an existing one.
  ```
- ```dart
  .Stack("mystack") // It creates a new Stack (Empty file) or select an existing one.
  ```
- ```dart
  .Query([]) // It spawns a new list of Querys (Array) which expects an array of "DBAction" classes.
  ```
- ```dart
  INSERT<String> ([                      // It calls
        { "myKey": "your string here" }  // the function
  ])                                     // to insert data.
  ```
