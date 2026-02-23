import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton wrapper around sqflite matching iOS FMDB database.
/// Database: NewTouchbase.db (matching iOS AppDelegate database setup).
///
/// Tables (exact same schemas as iOS):
/// - GROUPMASTER: Group/club data with notification counts
/// - MODULE_DATA_MASTER: Module configuration per group
/// - Notification_Table: Push notification local storage
/// - DIRECTORY_DATA_MASTER: Directory member data
/// - SERVICE_DIRECTORY_DATA_MASTER: Service directory entries
/// - GALLERY_MASTER: Gallery album data
/// - ALBUM_PHOTO_MASTER: Album photo data
/// - ReplicaInfo: Module replication tracking
class DatabaseHelper {
  DatabaseHelper._();

  static DatabaseHelper? _instance;
  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  Database? _database;

  static const String _dbName = 'NewTouchbase.db';
  static const int _dbVersion = 2;

  /// Initialize the database. Call once at app startup.
  Future<void> init() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Database? get database => _database;

  /// Create all tables matching iOS AppDelegate.swift table schemas exactly.
  Future<void> _onCreate(Database db, int version) async {
    // iOS: AppDelegate.swift line 939
    await db.execute('''
      CREATE TABLE IF NOT EXISTS GROUPMASTER (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        masterUID INTEGER,
        grpId INTEGER,
        grpName TEXT,
        grpImg TEXT,
        grpProfileid INTEGER,
        myCategory TEXT,
        isGrpAdmin TEXT,
        notificationCount TEXT DEFAULT '0'
      )
    ''');

    // iOS: AppDelegate.swift line 950
    await db.execute('''
      CREATE TABLE IF NOT EXISTS MODULE_DATA_MASTER (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        masterUID INTEGER,
        groupModuleId INTEGER,
        groupId TEXT,
        moduleId TEXT,
        moduleName TEXT,
        moduleStaticRef TEXT,
        image TEXT,
        moduleOrderNo INTEGER,
        notificationCount TEXT DEFAULT '0'
      )
    ''');

    // iOS: AppDelegate.swift line 2056 + NotificaionModel.swift
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Notification_Table (
        MsgID TEXT,
        Title TEXT,
        Details TEXT,
        Type TEXT,
        ClubDistrictType TEXT,
        NotifyDate TEXT,
        ExpiryDate TEXT,
        SortDate DATE,
        ReadStatus TEXT
      )
    ''');

    // iOS: AppDelegate.swift line 962
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DIRECTORY_DATA_MASTER (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        masterUID INTEGER,
        groupId INTEGER,
        memberMasterUID INTEGER,
        profileID INTEGER,
        groupName TEXT,
        memberName TEXT,
        pic TEXT,
        membermobile TEXT,
        grpCount INTEGER,
        moduleId TEXT
      )
    ''');

    // iOS: AppDelegate.swift line 974
    await db.execute('''
      CREATE TABLE IF NOT EXISTS SERVICE_DIRECTORY_DATA_MASTER (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        masterUID INTEGER,
        groupId INTEGER,
        memberName TEXT,
        image TEXT,
        contactNo TEXT,
        isdeleted TEXT,
        description TEXT,
        contactNo2 TEXT,
        pax TEXT,
        email TEXT,
        address TEXT,
        long TEXT,
        lat TEXT,
        countryId1 INTEGER,
        countryId2 INTEGER,
        csvKeywords TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        zip TEXT,
        moduleId TEXT,
        serviceDirId TEXT
      )
    ''');

    // iOS: AppDelegate.swift line 985
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ReplicaInfo (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleId INTEGER,
        replicaOf TEXT
      )
    ''');

    // iOS: AppDelegate.swift line 996
    await db.execute('''
      CREATE TABLE IF NOT EXISTS GALLERY_MASTER (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        masterUID INTEGER,
        albumId INTEGER,
        title TEXT,
        description TEXT,
        image TEXT,
        groupId INTEGER,
        isAdmin TEXT,
        moduleId TEXT
      )
    ''');

    // iOS: AppDelegate.swift line 1008
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ALBUM_PHOTO_MASTER (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER,
        albumId INTEGER,
        photoId INTEGER,
        url TEXT,
        description TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add notificationCount column if upgrading from version 1
      try {
        await db.execute(
          'ALTER TABLE GROUPMASTER ADD COLUMN notificationCount TEXT DEFAULT \'0\'',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE MODULE_DATA_MASTER ADD COLUMN notificationCount TEXT DEFAULT \'0\'',
        );
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════
  // GROUPMASTER CRUD (matching iOS CommonSqlite.swift)
  // ═══════════════════════════════════════════════════════

  /// Insert a group into GROUPMASTER.
  Future<int?> insertGroup(Map<String, dynamic> group) async {
    try {
      return await _database?.insert('GROUPMASTER', group);
    } catch (e) {
      debugPrint('Error inserting group: $e');
      return null;
    }
  }

  /// Get all groups for a user.
  Future<List<Map<String, dynamic>>?> getGroups(String masterUid) async {
    try {
      return await _database?.query(
        'GROUPMASTER',
        where: 'masterUID = ?',
        whereArgs: [masterUid],
      );
    } catch (e) {
      debugPrint('Error getting groups: $e');
      return null;
    }
  }

  /// Update notification count for a group.
  /// Matches iOS CommonSqliteClass.functionForUpdateGroupMasterandModuleDataMasterTable
  Future<int?> updateGroupNotificationCount(
    String grpId,
    String count,
  ) async {
    try {
      return await _database?.update(
        'GROUPMASTER',
        {'notificationCount': count},
        where: 'grpId = ?',
        whereArgs: [grpId],
      );
    } catch (e) {
      debugPrint('Error updating group notification count: $e');
      return null;
    }
  }

  /// Delete a group.
  /// Matches iOS CommonSqliteClass.functionForDeleteEntityandGroup
  Future<int?> deleteGroup(String grpId) async {
    try {
      return await _database?.delete(
        'GROUPMASTER',
        where: 'grpId = ?',
        whereArgs: [grpId],
      );
    } catch (e) {
      debugPrint('Error deleting group: $e');
      return null;
    }
  }

  /// Delete all groups for cleanup.
  Future<int?> deleteAllGroups() async {
    try {
      return await _database?.delete('GROUPMASTER');
    } catch (e) {
      debugPrint('Error deleting all groups: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  // MODULE_DATA_MASTER CRUD
  // ═══════════════════════════════════════════════════════

  /// Insert a module into MODULE_DATA_MASTER.
  Future<int?> insertModule(Map<String, dynamic> module) async {
    try {
      return await _database?.insert('MODULE_DATA_MASTER', module);
    } catch (e) {
      debugPrint('Error inserting module: $e');
      return null;
    }
  }

  /// Get all modules for a group.
  Future<List<Map<String, dynamic>>?> getModules(String groupId) async {
    try {
      return await _database?.query(
        'MODULE_DATA_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
        orderBy: 'moduleOrderNo ASC',
      );
    } catch (e) {
      debugPrint('Error getting modules: $e');
      return null;
    }
  }

  /// Update module notification count.
  Future<int?> updateModuleNotificationCount(
    String groupId,
    String moduleId,
    String count,
  ) async {
    try {
      return await _database?.update(
        'MODULE_DATA_MASTER',
        {'notificationCount': count},
        where: 'groupId = ? AND moduleId = ?',
        whereArgs: [groupId, moduleId],
      );
    } catch (e) {
      debugPrint('Error updating module notification count: $e');
      return null;
    }
  }

  /// Delete all modules for a group.
  Future<int?> deleteModulesForGroup(String groupId) async {
    try {
      return await _database?.delete(
        'MODULE_DATA_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } catch (e) {
      debugPrint('Error deleting modules: $e');
      return null;
    }
  }

  /// Delete all modules.
  Future<int?> deleteAllModules() async {
    try {
      return await _database?.delete('MODULE_DATA_MASTER');
    } catch (e) {
      debugPrint('Error deleting all modules: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  // Notification_Table CRUD (matching iOS NotificaionModel.swift)
  // ═══════════════════════════════════════════════════════

  /// Save a notification.
  /// Matches iOS NotificaioModel.saveNotificationDetails
  Future<int?> insertNotification(Map<String, dynamic> notification) async {
    try {
      return await _database?.insert('Notification_Table', notification);
    } catch (e) {
      debugPrint('Error inserting notification: $e');
      return null;
    }
  }

  /// Get all notifications ordered by ReadStatus and SortDate.
  /// Matches iOS NotificaioModel.getAllNotificationDetail
  Future<List<Map<String, dynamic>>?> getAllNotifications() async {
    try {
      return await _database?.query(
        'Notification_Table',
        orderBy: 'ReadStatus DESC, SortDate DESC',
      );
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return null;
    }
  }

  /// Get unread notification count.
  /// Matches iOS NotificaioModel.getNotificationCount
  Future<int?> getUnreadNotificationCount() async {
    try {
      final result = await _database?.rawQuery(
        "SELECT COUNT(*) as count FROM Notification_Table WHERE ReadStatus = 'UnRead'",
      );
      return result?.first['count'] as int?;
    } catch (e) {
      debugPrint('Error getting notification count: $e');
      return null;
    }
  }

  /// Update notification read status.
  /// Matches iOS NotificaioModel.changeReadStatus
  Future<int?> markNotificationAsRead(String msgId) async {
    try {
      return await _database?.update(
        'Notification_Table',
        {'ReadStatus': 'Read'},
        where: 'MsgID = ?',
        whereArgs: [msgId],
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return null;
    }
  }

  /// Delete notification by MsgID.
  /// Matches iOS NotificaioModel.deleteNotification(.ByMessage)
  Future<int?> deleteNotificationByMsgId(String msgId) async {
    try {
      return await _database?.delete(
        'Notification_Table',
        where: 'MsgID = ?',
        whereArgs: [msgId],
      );
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return null;
    }
  }

  /// Delete all notifications.
  /// Matches iOS NotificaioModel.deleteNotification(.All)
  Future<int?> deleteAllNotifications() async {
    try {
      return await _database?.delete('Notification_Table');
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return null;
    }
  }

  /// Delete expired notifications (older than 3 days, matching Android).
  Future<int?> deleteExpiredNotifications() async {
    try {
      return await _database?.rawDelete(
        "DELETE FROM Notification_Table WHERE SortDate <= date('now', '-3 day')",
      );
    } catch (e) {
      debugPrint('Error deleting expired notifications: $e');
      return null;
    }
  }

  /// Get total notification count.
  /// Android: DatabaseHelper.getProfilesCount()
  Future<int?> getTotalNotificationCount() async {
    try {
      final result = await _database?.rawQuery(
        'SELECT COUNT(*) as count FROM Notification_Table',
      );
      return result?.first['count'] as int?;
    } catch (e) {
      debugPrint('Error getting total notification count: $e');
      return null;
    }
  }

  /// Delete the 2 oldest notifications.
  /// Android: DatabaseHelper.deletrow() — cleanup when > 100 records.
  Future<int?> deleteOldestNotifications({int count = 2}) async {
    try {
      return await _database?.rawDelete(
        'DELETE FROM Notification_Table WHERE rowid IN '
        '(SELECT rowid FROM Notification_Table ORDER BY SortDate ASC LIMIT ?)',
        [count],
      );
    } catch (e) {
      debugPrint('Error deleting oldest notifications: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  // DIRECTORY_DATA_MASTER CRUD
  // ═══════════════════════════════════════════════════════

  Future<int?> insertDirectoryMember(Map<String, dynamic> member) async {
    try {
      return await _database?.insert('DIRECTORY_DATA_MASTER', member);
    } catch (e) {
      debugPrint('Error inserting directory member: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getDirectoryMembers(
    String groupId,
  ) async {
    try {
      return await _database?.query(
        'DIRECTORY_DATA_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } catch (e) {
      debugPrint('Error getting directory members: $e');
      return null;
    }
  }

  Future<int?> deleteDirectoryMembers(String groupId) async {
    try {
      return await _database?.delete(
        'DIRECTORY_DATA_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } catch (e) {
      debugPrint('Error deleting directory members: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  // SERVICE_DIRECTORY_DATA_MASTER CRUD
  // ═══════════════════════════════════════════════════════

  Future<int?> insertServiceDirectory(Map<String, dynamic> entry) async {
    try {
      return await _database?.insert('SERVICE_DIRECTORY_DATA_MASTER', entry);
    } catch (e) {
      debugPrint('Error inserting service directory: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getServiceDirectory(
    String groupId,
  ) async {
    try {
      return await _database?.query(
        'SERVICE_DIRECTORY_DATA_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } catch (e) {
      debugPrint('Error getting service directory: $e');
      return null;
    }
  }

  Future<int?> deleteServiceDirectory(String groupId) async {
    try {
      return await _database?.delete(
        'SERVICE_DIRECTORY_DATA_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } catch (e) {
      debugPrint('Error deleting service directory: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  // GALLERY CRUD
  // ═══════════════════════════════════════════════════════

  Future<int?> insertAlbum(Map<String, dynamic> album) async {
    try {
      return await _database?.insert('GALLERY_MASTER', album);
    } catch (e) {
      debugPrint('Error inserting album: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAlbums(String groupId) async {
    try {
      return await _database?.query(
        'GALLERY_MASTER',
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } catch (e) {
      debugPrint('Error getting albums: $e');
      return null;
    }
  }

  Future<int?> insertAlbumPhoto(Map<String, dynamic> photo) async {
    try {
      return await _database?.insert('ALBUM_PHOTO_MASTER', photo);
    } catch (e) {
      debugPrint('Error inserting album photo: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAlbumPhotos(String albumId) async {
    try {
      return await _database?.query(
        'ALBUM_PHOTO_MASTER',
        where: 'albumId = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      debugPrint('Error getting album photos: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════════════════

  /// Execute a raw SQL query.
  Future<List<Map<String, dynamic>>?> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    try {
      return await _database?.rawQuery(sql, arguments);
    } catch (e) {
      debugPrint('Error executing raw query: $e');
      return null;
    }
  }

  /// Execute a raw SQL statement (INSERT, UPDATE, DELETE).
  Future<int?> rawExecute(String sql, [List<dynamic>? arguments]) async {
    try {
      return await _database?.rawUpdate(sql, arguments);
    } catch (e) {
      debugPrint('Error executing raw statement: $e');
      return null;
    }
  }

  /// Close the database.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
