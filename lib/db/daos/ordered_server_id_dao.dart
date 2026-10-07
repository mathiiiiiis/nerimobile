import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/ordered_server_ids.dart';

part 'ordered_server_id_dao.g.dart';

@DriftAccessor(tables: [OrderedServerIds])
class OrderedServerIdDao extends DatabaseAccessor<NeriDatabase>
    with _$OrderedServerIdDaoMixin {
  OrderedServerIdDao(super.attachedDatabase);

  Future<List<String>> all() async {
    final rows = await (select(
      orderedServerIds,
    )..orderBy([(t) => OrderingTerm(expression: t.position)])).get();
    return [for (final row in rows) row.id];
  }

  Future<void> sync(List<String> ids) async {
    await transaction(() async {
      await delete(orderedServerIds).go();
      await batch(
        (b) => b.insertAll(orderedServerIds, [
          for (final (position, id) in ids.indexed)
            OrderedServerIdsCompanion.insert(id: id, position: position),
        ]),
      );
    });
  }
}
