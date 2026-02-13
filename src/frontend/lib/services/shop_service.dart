import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../data/models/item.dart';

/// 商店服务
class ShopService {
  final Dio _dio;

  ShopService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 获取商品分类列表
  Future<List<Map<String, String>>> getCategories() async {
    try {
      final response = await _dio.get(
        '/api/shop/categories',
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final categories = response.data['data'] as List;
        return categories.map((e) => Map<String, String>.from(e)).toList();
      }

      return _getDefaultCategories();
    } catch (e) {
      print('获取商品分类失败: $e');
      return _getDefaultCategories();
    }
  }

  /// 获取商品列表
  Future<List<Item>> getShopItems({
    String? category,
    ItemType? type,
    ItemRarity? rarity,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (category != null) {
        queryParams['category'] = category;
      }

      if (type != null) {
        queryParams['type'] = type.name;
      }

      if (rarity != null) {
        queryParams['rarity'] = rarity.name;
      }

      final response = await _dio.get(
        '/api/shop/items',
        queryParameters: queryParams,
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final items = response.data['data']['items'] as List;
        return items.map((e) => Item.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print('获取商品列表失败: $e');
      return [];
    }
  }

  /// 购买商品
  Future<Map<String, dynamic>> purchaseItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(
        '/api/shop/purchase',
        data: {
          'itemId': itemId,
          'quantity': quantity,
        },
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '购买失败',
      };
    } catch (e) {
      print('购买商品失败: $e');
      return {
        'success': false,
        'message': '网络错误，购买失败',
      };
    }
  }

  /// 使用物品
  Future<Map<String, dynamic>> useItem({
    required String itemId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/player/inventory/use',
        data: {
          'itemId': itemId,
        },
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '使用失败',
      };
    } catch (e) {
      print('使用物品失败: $e');
      return {
        'success': false,
        'message': '网络错误，使用失败',
      };
    }
  }

  /// 装备物品
  Future<Map<String, dynamic>> equipItem({
    required String itemId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/player/inventory/equip',
        data: {
          'itemId': itemId,
        },
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '装备失败',
      };
    } catch (e) {
      print('装备物品失败: $e');
      return {
        'success': false,
        'message': '网络错误，装备失败',
      };
    }
  }

  /// 卸下装备
  Future<Map<String, dynamic>> unequipItem({
    required String itemId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/player/inventory/unequip',
        data: {
          'itemId': itemId,
        },
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '卸下失败',
      };
    } catch (e) {
      print('卸下装备失败: $e');
      return {
        'success': false,
        'message': '网络错误，卸下失败',
      };
    }
  }

  /// 获取玩家库存
  Future<List<InventoryItem>> getPlayerInventory() async {
    try {
      final response = await _dio.get(
        '/api/player/inventory',
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final items = response.data['data'] as List;
        return items.map((e) => InventoryItem.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print('获取库存失败: $e');
      return [];
    }
  }

  /// 获取认证头
  Future<Map<String, String>> _getAuthHeaders() async {
    // TODO: 从本地存储获取 token
    // final token = await AuthService.getToken();
    // if (token != null) {
    //   return {'Authorization': 'Bearer $token'};
    // }
    return {};
  }

  /// 获取默认分类（当 API 调用失败时使用）
  List<Map<String, String>> _getDefaultCategories() {
    return [
      {'id': 'all', 'name': '全部'},
      {'id': 'tool', 'name': '忍具'},
      {'id': 'medicine', 'name': '药品'},
      {'id': 'equipment', 'name': '装备'},
      {'id': 'material', 'name': '材料'},
    ];
  }
}
