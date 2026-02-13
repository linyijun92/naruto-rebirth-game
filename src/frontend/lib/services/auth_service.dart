import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// 认证服务
class AuthService {
  final Dio _dio;

  AuthService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自动添加 token
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 处理 401 未授权错误
        if (error.response?.statusCode == 401) {
          // Token 过期，清除本地存储并跳转到登录页
          await clearToken();
          // TODO: 跳转到登录页
          // navigatorKey?.currentState?.pushReplacementNamed('/login');
        }
        return handler.next(error);
      },
    ));
  }

  /// 用户注册
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/player/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        // 注册成功后自动登录
        final data = response.data['data'];
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {
          'success': true,
          'message': response.data['message'] ?? '注册成功',
          'data': data,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '注册失败',
      };
    } catch (e) {
      print('注册失败: $e');
      return {
        'success': false,
        'message': '网络错误，注册失败',
      };
    }
  }

  /// 用户登录
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/player/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {
          'success': true,
          'message': response.data['message'] ?? '登录成功',
          'data': data,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '登录失败',
      };
    } catch (e) {
      print('登录失败: $e');
      return {
        'success': false,
        'message': '网络错误，登录失败',
      };
    }
  }

  /// 用户登出
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post(
        '/api/player/logout',
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      // 无论服务器响应如何，都清除本地 token
      await clearToken();

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? '登出成功',
        };
      }

      return {
        'success': true,
        'message': '已登出',
      };
    } catch (e) {
      print('登出失败: $e');
      // 即使网络错误，也清除本地 token
      await clearToken();
      return {
        'success': true,
        'message': '已登出',
      };
    }
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _dio.get(
        '/api/player',
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return response.data['data'];
      }

      return null;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  /// 检查登录状态
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 保存 token
  Future<void> saveToken(String token) async {
    // TODO: 使用 Hive 存储token
    // final box = await Hive.openBox('auth');
    // await box.put('token', token);
    print('Token saved: $token');
  }

  /// 获取 token
  Future<String?> getToken() async {
    // TODO: 从 Hive 获取token
    // final box = await Hive.openBox('auth');
    // return box.get('token') as String?;
    return null;
  }

  /// 清除 token
  Future<void> clearToken() async {
    // TODO: 从 Hive 清除token
    // final box = await Hive.openBox('auth');
    // await box.delete('token');
    print('Token cleared');
  }

  /// 获取认证头
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }
}
