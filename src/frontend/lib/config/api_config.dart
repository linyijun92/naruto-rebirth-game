class ApiConfig {
  // API基础URL（根据环境切换）
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  // API端点
  static const String save = '/saves';
  static const String story = '/story';
  static const String player = '/player';
  static const String quest = '/quests';
  static const String shop = '/shop';

  // 超时设置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 请求头
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
