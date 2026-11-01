import 'dart:async';
import 'package:drift/drift.dart';
import '../data/database/app_database.dart';
import 'ws_channel_hub.dart';

class DriftChangeNotifier {
  final AppDatabase _db;
  final WsChannelHub _hub;
  StreamSubscription? _sub;

  DriftChangeNotifier(this._db, this._hub);

  void start() {
    _sub = _db
        .tableUpdates(TableUpdateQuery.onAllTables(_db.allTables))
        .listen((updates) {
      final tablas = updates.map((u) => u.table).toList();
      if (tablas.isEmpty) return;
      _hub.broadcast({
        'event': 'db_changed',
        'tables': tablas,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
