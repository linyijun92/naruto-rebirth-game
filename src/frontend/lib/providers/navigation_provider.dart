import 'package:flutter/foundation.dart';

/// 导航状态管理 Provider
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  static const int homeIndex = 0;
  static const int storyIndex = 1;
  static const int questIndex = 2;
  static const int shopIndex = 3;
  static const int profileIndex = 4;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateToHome() => setIndex(homeIndex);
  void navigateToStory() => setIndex(storyIndex);
  void navigateToQuest() => setIndex(questIndex);
  void navigateToShop() => setIndex(shopIndex);
  void navigateToProfile() => setIndex(profileIndex);
}
