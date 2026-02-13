import 'package:flutter/material.dart';

/// 火影忍者主题配色方案
class AppColors {
  // ========== 品牌色 ==========
  static const Color primary = Color(0xFFFF6B00); // 品牌主色 - 橙色
  static const Color primaryLight = Color(0xFFFF8C00); // 橙色亮色
  static const Color primaryDark = Color(0xFFE66000); // 橙色暗色

  // ========== 背景色 ==========
  static const Color bgPrimary = Color(0xFF1C1C1C); // 主背景色 - 深灰
  static const Color bgSecondary = Color(0xFF282828); // 深灰背景
  static const Color bgTertiary = Color(0xFF3C3C3C); // 中灰背景
  static const Color bgCard = Color(0xFF303030); // 卡片背景

  // ========== 文字色 ==========
  static const Color textPrimary = Color(0xFFFFFFFF); // 主文字
  static const Color textSecondary = Color(0xFFBBBBBB); // 次要文字
  static const Color textDisabled = Color(0xFF666666); // 禁用文字

  // ========== 状态色 ==========
  static const Color success = Color(0xFF43A047); // 成功
  static const Color warning = Color(0xFFFF9800); // 警告
  static const Color error = Color(0xFFE53935); // 错误
  static const Color info = Color(0xFF2196F3); // 信息

  // ========== 稀有度色 ==========
  static const Color rarityN = Color(0xFF9E9E9E); // 普通
  static const Color rarityR = Color(0xFF2196F3); // 稀有
  static const Color raritySR = Color(0xFF9C27B0); // 史诗
  static const Color raritySSR = Color(0xFFFFC107); // 传说
  static const Color rarityUR = Color(0xFFFF6B00); // 神话

  // ========== 属性色 ==========
  static const Color elementFire = Color(0xFFFF5722); // 火属性
  static const Color elementWater = Color(0xFF2196F3); // 水属性
  static const Color elementWind = Color(0xFF4CAF50); // 风属性
  static const Color elementLightning = Color(0xFFFFEB3B); // 雷属性
  static const Color elementEarth = Color(0xFF9E9E9E); // 土属性

  // ========== 火影主题渐变 ==========
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [bgPrimary, bgSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient chakraGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF8C00), Color(0xFFFFA726)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
