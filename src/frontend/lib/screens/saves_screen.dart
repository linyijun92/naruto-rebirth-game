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
        title: const Text('创建新存档'),
        content: TextField(
          controller: saveNameController,
          decoration: const InputDecoration(
            labelText: '存档名称',
            hintText: '请输入存档名称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, saveNameController.text),
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
  Future<void> _deleteSave(Save save) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除存档 "${save.saveName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await SaveService.deleteFromLocal(save.saveId);
      if (success) {
        setState(() => _localSaves = SaveService.getAllLocalSaves());
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
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏存档'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '本地存档'),
            Tab(text: '云端存档'),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _isLoading ? null : _createSave,
              tooltip: '创建新存档',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (saves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocal ? Icons.save_outlined : Icons.cloud_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isLocal ? '暂无本地存档' : '暂无云端存档',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (isLocal) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _createSave,
                icon: const Icon(Icons.add),
                label: const Text('创建新存档'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSaves,
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
      child: InkWell(
        onTap: () => _loadSave(save),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              save.saveName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (save.isAutoSave) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '自动',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[900],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(save.updatedAt),
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Lv.${save.playerLevel}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        save.gameTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAttributeChip('查克拉', save.attributes['chakra']),
                  const SizedBox(width: 8),
                  _buildAttributeChip('忍术', save.attributes['ninjutsu']),
                  const SizedBox(width: 8),
                  _buildAttributeChip('体术', save.attributes['taijutsu']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    SaveService.formatPlayTime(save.playTime),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (isLocal && widget.currentToken != null)
                    IconButton(
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      onPressed: _isSyncing ? null : () => _syncSaveToCloud(save),
                      tooltip: '上传到云端',
                    ),
                  if (!isLocal)
                    IconButton(
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download_outlined),
                      onPressed: _isSyncing ? null : () => _downloadSaveToLocal(save),
                      tooltip: '下载到本地',
                    ),
                  if (isLocal)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteSave(save),
                      tooltip: '删除',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeChip(String label, int? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: ${value ?? 0}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[900],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
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
