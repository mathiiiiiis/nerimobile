import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const databaseFile = 'nerimobile.sqlite';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(
      File(p.join(directory.path, databaseFile)),
    );
  });
}
