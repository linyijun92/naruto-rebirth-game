import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../services/hive_service.dart';
import '../config/app_config.dart';

/// 设置界面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 音量设置
  double _bgmVolume = 0.8;
  double _sfxVolume = 0.9;
  double _voiceVolume = 1.0;

  // 画质设置
  String _graphicsQuality = 'high'; // low, medium, high

  // 语言设置
  String _language = 'zh_CN'; // zh_CN, zh_TW, en

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 从本地加载设置
  Future<void> _loadSettings() async {
    setState(() {
      _bgmVolume = HiveService.getSetting('bgm_volume') ?? 0.8;
      _sfxVolume = HiveService.getSetting('sfx_volume') ?? 0.9;
      _voiceVolume = HiveService.getSetting('voice_volume') ?? 1.0;
      _graphicsQuality = HiveService.getSetting('graphics_quality') ?? 'high';
      _language = HiveService.getSetting('language') ?? 'zh_CN';
    });
  }

  /// 保存设置到本地
  Future<void> _saveSettings() async {
    await HiveService.saveSetting('bgm_volume', _bgmVolume);
    await HiveService.saveSetting('sfx_volume', _sfxVolume);
    await HiveService.saveSetting('voice_volume', _voiceVolume);
    await HiveService.saveSetting('graphics_quality', _graphicsQuality);
    await HiveService.saveSetting('language', _language);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveSettings();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          backgroundColor: Colors.orange.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a237e),
                Color(0xFF4a148c),
              ],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 音量控制部分
              _buildSection(
                title: '音量控制',
                icon: Icons.volume_up,
                children: [
                  _buildSliderTile(
                    label: '背景音乐',
                    icon: Icons.music_note,
                    value: _bgmVolume,
                    onChanged: (value) {
                      setState(() => _bgmVolume = value);
                    },
                  ),
                  _buildSliderTile(
                    label: '音效',
                    icon: Icons.surround_sound,
                    value: _sfxVolume,
                    onChanged: (value) {
                      setState(() => _sfxVolume = value);
                    },
                  ),
                  _buildSliderTile(
                    label: '语音',
                    icon: Icons.record_voice_over,
                    value: _voiceVolume,
                    onChanged: (value) {
                      setState(() => _voiceVolume = value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 画质设置部分
              _buildSection(
                title: '画质设置',
                icon: Icons.high_quality,
                children: [
                  _buildQualitySelector(),
                ],
              ),

              const SizedBox(height: 20),

              // 语言设置部分
              _buildSection(
                title: '语言选择',
                icon: Icons.language,
                children: [
                  _buildLanguageSelector(),
                ],
              ),

              const SizedBox(height: 20),

              // 存档管理部分
              _buildSection(
                title: '存档管理',
                icon: Icons.storage,
                children: [
                  _buildActionTile(
                    label: '清理缓存',
                    icon: Icons.cleaning_services,
                    subtitle: '清除临时文件和缓存',
                    onTap: _clearCache,
                  ),
                  _buildActionTile(
                    label: '查看存档大小',
                    icon: Icons.folder_open,
                    subtitle: '查看存档占用的空间',
                    onTap: _showSaveSize,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 关于部分
              _buildSection(
                title: '关于',
                icon: Icons.info,
                children: [
                  _buildAboutTile(),
                ],
              ),

              const SizedBox(height: 100), // 底部留白
            ],
          ),
        ),
      ),
    );
  }

  /// 构建设置部分
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.orange.shade300, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// 构建滑块设置项
  Widget _buildSliderTile({
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(
            width: 150,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.orange.shade600,
                inactiveTrackColor: Colors.white.withOpacity(0.2),
                thumbColor: Colors.orange.shade300,
                overlayColor: Colors.orange.shade300.withOpacity(0.3),
                trackHeight: 4,
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建画质选择器
  Widget _buildQualitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQualityOption(
              label: '低',
              value: 'low',
              icon: Icons.low_priority,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQualityOption(
              label: '中',
              value: 'medium',
              icon: Icons.center_focus_strong,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQualityOption(
              label: '高',
              value: 'high',
              icon: Icons.hd,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建画质选项
  Widget _buildQualityOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _graphicsQuality == value;
    return InkWell(
      onTap: () {
        setState(() => _graphicsQuality = value);
        _saveSettings();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.shade600.withOpacity(0.8)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.orange.shade400 : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建语言选择器
  Widget _buildLanguageSelector() {
    final languages = [
      {'code': 'zh_CN', 'name': '简体中文', 'flag': '🇨🇳'},
      {'code': 'zh_TW', 'name': '繁体中文', 'flag': '🇹🇼'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: languages.map((lang) {
          final isSelected = _language == lang['code'];
          return InkWell(
            onTap: () {
              setState(() => _language = lang['code']!);
              _saveSettings();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange.shade600.withOpacity(0.3)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      lang['name']!,
                      style: TextStyle(
                        color: isSelected ? Colors.orange.shade300 : Colors.white,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.orange.shade300,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建操作按钮项
  Widget _buildActionTile({
    required String label,
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange.shade300, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建关于信息项
  Widget _buildAboutTile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutRow('版本', AppConfig.appVersion),
          _buildAboutRow('构建号', AppConfig.buildNumber),
          _buildAboutRow('开发者', '技术团队'),
          const SizedBox(height: 16),
          const Text(
            '感谢您的支持！',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 清理缓存
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清理'),
        content: const Text('确定要清理所有缓存吗？此操作不会影响存档。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实际清理缓存逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存已清理'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 显示存档大小
  void _showSaveSize() {
    // TODO: 实际计算存档大小
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('存档大小'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总存档数量: 0'),
            SizedBox(height: 8),
            Text('占用空间: 0 KB'),
            SizedBox(height: 8),
            Text('最大可用空间: 无限制'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
