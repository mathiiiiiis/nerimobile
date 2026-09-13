import 'package:drift/drift.dart';

const cacheSchemaVersion = 1;

MigrationStrategy migrations(GeneratedDatabase db) => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {},
);
