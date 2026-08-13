import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';

/// Reads recent hunt records for the journal screen.
// ? Keeping data access separate from widgets makes filtering and testing easier.
class ActivityController {
  ActivityController({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<List<SessionLog>> loadRecentHistory({int limit = 60}) =>
      _dbHelper.fetchSessionLogs(limit: limit);
}
