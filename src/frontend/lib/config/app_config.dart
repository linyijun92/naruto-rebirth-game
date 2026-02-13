class AppConfig {
  // 应用信息
  static const String appName = '重生到火影忍者世界';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // 游戏配置
  static const int maxSaveSlots = 10; // 最大存档数量
  static const int autoSaveInterval = 300; // 自动保存间隔（秒）
  static const bool enableCloudSync = true; // 是否启用云端同步

  // 属性配置
  static const Map<String, int> defaultAttributes = {
    'chakra': 100,
    'ninjutsu': 50,
    'taijutsu': 50,
    'intelligence': 50,
  };

  static const Map<String, int> maxAttributes = {
    'chakra': 999,
    'ninjutsu': 999,
    'taijutsu': 999,
    'intelligence': 999,
  };

  // 游戏货币
  static const String currencyName = '银两';
  static const int startingCurrency = 1000;
}
