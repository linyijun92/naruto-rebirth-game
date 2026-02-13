import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/models/save.dart';
import 'hive_service.dart';

class SaveService {
  /// 创建新存档
  static Future<Save?> createSave(Save saveData, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode(saveData.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Save.fromJson(data['data']);
      } else {
        print('创建存档失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('创建存档异常: $e');
      return null;
    }
  }

  /// 获取存档列表
  static Future<List<Save>?> getSaves({bool cloudOnly = false, String? token}) async {
    try {
      final queryParams = cloudOnly ? '?cloudOnly=true' : '';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}$queryParams'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final savesData = data['data']['saves'] as List;
        return savesData.map((json) => Save.fromJson(json)).toList();
      } else {
        print('获取存档列表失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('获取存档列表异常: $e');
      return null;
    }
  }

  /// 获取存档详情
  static Future<Save?> getSave(String saveId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}/$saveId'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Save.fromJson(data['data']);
      } else {
        print('获取存档详情失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('获取存档详情异常: $e');
      return null;
    }
  }

  /// 更新存档
  static Future<Save?> updateSave(String saveId, Map<String, dynamic> updateData, {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}/$saveId'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Save.fromJson(data['data']);
      } else {
        print('更新存档失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('更新存档异常: $e');
      return null;
    }
  }

  /// 删除存档
  static Future<bool> deleteSave(String saveId, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}/$saveId'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('删除存档失败: ${response.body}');
        return false;
      }
    } catch (e) {
      print('删除存档异常: $e');
      return false;
    }
  }

  /// 同步存档到云端
  static Future<Save?> syncSave(String saveId, {Save? saveData, String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}/$saveId/sync'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({'saveData': saveData?.toJson()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Save.fromJson(data['data']);
      } else {
        print('同步存档失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('同步存档异常: $e');
      return null;
    }
  }

  /// 批量上传存档
  static Future<List<Save>?> batchUploadSaves(List<Save> saves, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.save}/batch'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({'saves': saves.map((s) => s.toJson()).toList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final savesData = data['data']['saves'] as List;
        return savesData.map((json) => Save.fromJson(json)).toList();
      } else {
        print('批量上传存档失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('批量上传存档异常: $e');
      return null;
    }
  }

  // ========== 本地存储方法 ==========

  /// 保存存档到本地
  static Future<void> saveToLocal(Save save) async {
    await HiveService.save(save.saveId, save.toJson());
  }

  /// 从本地获取存档
  static Save? getFromLocal(String saveId) {
    final data = HiveService.get(saveId);
    if (data != null) {
      return Save.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// 获取所有本地存档
  static List<Save> getAllLocalSaves() {
    final keys = HiveService.getAllKeys();
    final saves = <Save>[];
    for (final key in keys) {
      final save = getFromLocal(key as String);
      if (save != null) {
        saves.add(save);
      }
    }
    // 按更新时间降序排序
    saves.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return saves;
  }

  /// 从本地删除存档
  static Future<void> deleteFromLocal(String saveId) async {
    await HiveService.delete(saveId);
  }

  /// 清空所有本地存档
  static Future<void> clearAllLocalSaves() async {
    final keys = HiveService.getAllKeys();
    for (final key in keys) {
      await HiveService.delete(key as String);
    }
  }

  /// 检查本地存档是否存在
  static bool existsLocal(String saveId) {
    return HiveService.containsKey(saveId);
  }

  // ========== 工具方法 ==========

  /// 创建自动存档
  static Future<Save?> createAutoSave(Map<String, dynamic> gameData) async {
    final saveId = 'auto_save_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final autoSave = Save(
      saveId: saveId,
      playerId: gameData['playerId'] ?? 'local',
      saveName: '自动存档 ${now.toString().substring(0, 19)}',
      gameTime: gameData['gameTime'] ?? '火影纪元 1年',
      playerLevel: gameData['playerLevel'] ?? 1,
      attributes: gameData['attributes'] ?? {},
      currentChapter: gameData['currentChapter'] ?? 'chapter_01_01',
      inventory: gameData['inventory'] ?? [],
      quests: gameData['quests'] ?? [],
      achievements: gameData['achievements'] ?? [],
      playTime: gameData['playTime'] ?? 0,
      createdAt: now,
      updatedAt: now,
    );

    await saveToLocal(autoSave);
    return autoSave;
  }

  /// 创建手动存档
  static Future<Save?> createManualSave(String saveName, Map<String, dynamic> gameData) async {
    final saveId = 'manual_save_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final manualSave = Save(
      saveId: saveId,
      playerId: gameData['playerId'] ?? 'local',
      saveName: saveName,
      gameTime: gameData['gameTime'] ?? '火影纪元 1年',
      playerLevel: gameData['playerLevel'] ?? 1,
      attributes: gameData['attributes'] ?? {},
      currentChapter: gameData['currentChapter'] ?? 'chapter_01_01',
      inventory: gameData['inventory'] ?? [],
      quests: gameData['quests'] ?? [],
      achievements: gameData['achievements'] ?? [],
      playTime: gameData['playTime'] ?? 0,
      createdAt: now,
      updatedAt: now,
    );

    await saveToLocal(manualSave);
    return manualSave;
  }

  /// 格式化播放时间
  static String formatPlayTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}小时${minutes}分';
    } else if (minutes > 0) {
      return '${minutes}分${secs}秒';
    } else {
      return '${secs}秒';
    }
  }
}
