import 'package:flutter/foundation.dart';

class GameProvider extends ChangeNotifier {
  // 游戏状态
  bool _isPaused = false;
  bool _isLoading = false;

  // 当前游戏时间
  String _gameTime = '火影纪元 1年';

  // Getters
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  String get gameTime => _gameTime;

  // 暂停游戏
  void pauseGame() {
    _isPaused = true;
    notifyListeners();
  }

  // 恢复游戏
  void resumeGame() {
    _isPaused = false;
    notifyListeners();
  }

  // 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 更新游戏时间
  void updateGameTime(String time) {
    _gameTime = time;
    notifyListeners();
  }
}
