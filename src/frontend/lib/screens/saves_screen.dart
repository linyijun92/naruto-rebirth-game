import 'package:flutter/material.dart';
import '../data/models/save.dart';
import '../services/save_service.dart';
import '../config/app_config.dart';

class SavesScreen extends StatefulWidget {
  final Function(Save)? onLoadSave;
  final String? currentToken;

  const SavesScreen({
    Key? key,
    this.onLoadSave,
    this.currentToken,
  }) : super(key: key);

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Save> _localSaves = [];
  List<Save> _cloudSaves = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSaves();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载存档列表
  Future<void> _loadSaves() async {
    setState(() => _isLoading = true);

    try {
      // 加载本地存档
      final localSaves = SaveService.getAllLocalSaves();
      setState(() => _localSaves = localSaves);

      // 加载云端存档（如果有token）
      if (widget.currentToken != null) {
        final cloudSaves = await SaveService.getSaves(
          cloudOnly: true,
          token: widget.currentToken,
        );
        if (cloudSaves != null) {
          setState(() => _cloudSaves = cloudSaves);
        }
      }
    } catch (e) {
      print('加载存档失败: $e');
      _showErrorSnackBar('加载存档失败');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 创建新存档
  Future<void> _createSave() async {
    final saveNameController = TextEditingController();

    final saveName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '创建新存档',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: saveNameController,
          decoration: InputDecoration(
            labelText: '存档名称',
            hintText: '请输入存档名称',
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, saveNameController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (saveName != null && saveName.trim().isNotEmpty) {
      // TODO: 从当前游戏状态获取数据
      final gameData = {
        'gameTime': '火影纪元 1年',
        'playerLevel': 1,
        'attributes': {
          'chakra': 100,
          'ninjutsu': 50,
          'taijutsu': 50,
          'intelligence': 50,
          'speed': 50,
          'luck': 50,
        },
        'currentChapter': 'chapter_01_01',
        'inventory': [],
        'quests': [],
        'achievements': [],
        'playTime': 0,
      };

      final save = await SaveService.createManualSave(saveName.trim(), gameData);
      if (save != null) {
        setState(() => _localSaves = SaveService.getAllLocalSaves());
        _showSuccessSnackBar('存档创建成功');
      } else {
        _showErrorSnackBar('存档创建失败');
      }
    }
  }

  /// 加载存档
  void _loadSave(Save save) {
    if (widget.onLoadSave != null) {
      widget.onLoadSave!(save);
      Navigator.pop(context);
    }
  }

  /// 删除存档
  Future<void> _deleteSave(Save save, {bool isCloud = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              '确认删除',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          '确定要删除存档 "${save.saveName}" 吗？\n此操作无法撤销。',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.2),
              foregroundColor: Colors.white70,
            ),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = false;
      if (isCloud) {
        // TODO: 删除云端存档的API调用
        success = true;
      } else {
        success = await SaveService.deleteFromLocal(save.saveId);
      }
      
      if (success) {
        setState(() {
          if (isCloud) {
            _cloudSaves.remove(save);
          } else {
            _localSaves = SaveService.getAllLocalSaves();
          }
        });
        _showSuccessSnackBar('存档删除成功');
      } else {
        _showErrorSnackBar('存档删除失败');
      }
    }
  }

  /// 同步存档到云端
  Future<void> _syncSaveToCloud(Save save) async {
    if (widget.currentToken == null) {
      _showErrorSnackBar('请先登录');
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final result = await SaveService.syncSave(
        save.saveId,
        saveData: save,
        token: widget.currentToken,
      );

      if (result != null) {
        await _loadSaves();
        _showSuccessSnackBar('同步成功');
      } else {
        _showErrorSnackBar('同步失败');
      }
    } catch (e) {
      print('同步失败: $e');
      _showErrorSnackBar('同步失败');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  /// 下载云端存档到本地
  Future<void> _downloadSaveToLocal(Save save) async {
    setState(() => _isSyncing = true);

    try {
      await SaveService.saveToLocal(save);
      await _loadSaves();
      _showSuccessSnackBar('下载成功');
    } catch (e) {
      print('下载失败: $e');
      _showErrorSnackBar('下载失败');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('游戏存档'),
        backgroundColor: const Color(0xFF0f3460),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: '本地存档'),
            Tab(
              text: widget.currentToken != null ? '云端存档' : '云端存档*',
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _isLoading ? null : _createSave,
              tooltip: '创建新存档',
              color: Colors.orange,
            ),
          IconButton(
            icon: _isLoading || _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading || _isSyncing ? null : _loadSaves,
            tooltip: '刷新',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSavesList(_localSaves, isLocal: true),
          _buildSavesList(_cloudSaves, isLocal: false),
        ],
      ),
    );
  }

  Widget _buildSavesList(List<Save> saves, {required bool isLocal}) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (saves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocal ? Icons.save_outlined : Icons.cloud_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 20),
            Text(
              isLocal ? '暂无本地存档' : '暂无云端存档',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (!isLocal && widget.currentToken == null)
              Text(
                '请先登录查看云端存档',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            if (isLocal) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createSave,
                icon: const Icon(Icons.add),
                label: const Text('创建新存档'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSaves,
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: saves.length,
        itemBuilder: (context, index) {
          final save = saves[index];
          return _buildSaveCard(save, isLocal: isLocal);
        },
      ),
    );
  }

  Widget _buildSaveCard(Save save, {required bool isLocal}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF16213e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _loadSave(save),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：存档名称、类型、云端标识
              Row(
                children: [
                  // 存档类型图标
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: save.isAutoSave
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      save.isAutoSave ? Icons.auto_awesome : Icons.save,
                      size: 18,
                      color: save.isAutoSave ? Colors.orange : Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 存档名称
                  Expanded(
                    child: Text(
                      save.saveName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 存档类型标签
                  if (save.isAutoSave)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '自动',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '手动',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // 云端标识
                  if (!isLocal || save.isCloud)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud, size: 14, color: Colors.cyan),
                          SizedBox(width: 4),
                          Text(
                            '云端',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 第二行：缩略图占位符和基本信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 存档缩略图（占位符）
                  Container(
                    width: 120,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 占位符内容
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 32,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '存档截图',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 角色头像占位符
                        Positioned(
                          bottom: -8,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213e),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '🦊',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 基本信息列
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 等级和游戏时间
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lv.${save.playerLevel}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              save.gameTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 当前章节
                        Row(
                          children: [
                            const Icon(
                              Icons.bookmark,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                save.currentChapter,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 存档时间
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(save.updatedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 第三行：属性预览
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '属性预览',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildAttributeChip('查克拉', save.attributes['chakra'], Colors.orange),
                        _buildAttributeChip('忍术', save.attributes['ninjutsu'], Colors.blue),
                        _buildAttributeChip('体术', save.attributes['taijutsu'], Colors.green),
                        _buildAttributeChip('智力', save.attributes['intelligence'], Colors.purple),
                        _buildAttributeChip('速度', save.attributes['speed'], Colors.cyan),
                        _buildAttributeChip('运气', save.attributes['luck'], Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 第四行：操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _loadSave(save),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('加载存档'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLocal && widget.currentToken != null)
                    IconButton(
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.cyan,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      onPressed: _isSyncing ? null : () => _syncSaveToCloud(save),
                      tooltip: '上传到云端',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.cyan.withOpacity(0.1),
                        foregroundColor: Colors.cyan,
                      ),
                    ),
                  if (!isLocal)
                    IconButton(
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.cyan,
                              ),
                            )
                          : const Icon(Icons.cloud_download_outlined),
                      onPressed: _isSyncing ? null : () => _downloadSaveToLocal(save),
                      tooltip: '下载到本地',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.cyan.withOpacity(0.1),
                        foregroundColor: Colors.cyan,
                      ),
                    ),
                  if (isLocal)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteSave(save, isCloud: false),
                      tooltip: '删除',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  if (!isLocal)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteSave(save, isCloud: true),
                      tooltip: '删除',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeChip(String label, int? value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${value ?? 0}',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays > 30) {
        return '${difference.inDays ~/ 30}个月前';
      }
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
