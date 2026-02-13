import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attributes.dart';
import '../providers/attributes_provider.dart';
import '../config/app_config.dart';

class AttributesScreen extends StatelessWidget {
  const AttributesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('角色属性'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showChangeHistory(context),
            tooltip: '变化历史',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('重置属性'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AttributesProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(provider),
                const SizedBox(height: 24),
                const Text(
                  '核心属性',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...AttributeInfo.allAttributes.map(
                  (attrInfo) => _buildAttributeCard(context, attrInfo, provider),
                ),
                const SizedBox(height: 24),
                _buildStatsCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 属性摘要卡片
  Widget _buildSummaryCard(AttributesProvider provider) {
    final total = provider.getTotalAttributes();
    final strongest = provider.getStrongestAttribute();
    final weakest = provider.getWeakestAttribute();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '属性总览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '总计: $total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.arrow_upward,
                    label: '最强属性',
                    value: _getAttributeName(strongest.key),
                    subValue: strongest.value.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.arrow_downward,
                    label: '最弱属性',
                    value: _getAttributeName(weakest.key),
                    subValue: weakest.value.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subValue,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 属性卡片
  Widget _buildAttributeCard(
    BuildContext context,
    AttributeInfo attrInfo,
    AttributesProvider provider,
  ) {
    final value = provider.getAttribute(_getAttributeKey(attrInfo.type));
    final level = provider.getAttributeLevel(_getAttributeKey(attrInfo.type));
    final levelName = AttributeExtension.getLevelName(level);
    final levelColor = AttributeExtension.getLevelColor(level);
    final bonus = provider.getBonusRate(attrInfo.type);
    final finalValue = provider.getFinalAttribute(attrInfo.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showAttributeDetail(context, attrInfo, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: attrInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(attrInfo.icon, color: attrInfo.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              attrInfo.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: levelColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                levelName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: levelColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attrInfo.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bonus > 0)
                        Text(
                          '+${(bonus * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: value / attrInfo.maxValue,
                backgroundColor: attrInfo.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(attrInfo.color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    attrInfo.maxValue.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              if (bonus > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '最终数值: $finalValue',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatsCard(AttributesProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '属性统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('平均属性', provider.getTotalAttributes() / 6),
            const SizedBox(height: 12),
            _buildStatRow('最高单属性', provider.getStrongestAttribute().value),
            const SizedBox(height: 12),
            _buildStatRow('最低单属性', provider.getWeakestAttribute().value),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 显示属性详情
  void _showAttributeDetail(
    BuildContext context,
    AttributeInfo attrInfo,
    AttributesProvider provider,
  ) {
    final key = _getAttributeKey(attrInfo.type);
    final value = provider.getAttribute(key);
    final level = provider.getAttributeLevel(key);
    final levelName = AttributeExtension.getLevelName(level);
    final levelColor = AttributeExtension.getLevelColor(level);
    final description = AttributeExtension.getDescription(attrInfo.type, value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(attrInfo.icon, color: attrInfo.color),
            const SizedBox(width: 8),
            Text(attrInfo.name),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('当前数值', value.toString()),
              _buildDetailRow('属性等级', levelName, color: levelColor),
              _buildDetailRow(
                '加成比例',
                '${(provider.getBonusRate(attrInfo.type) * 100).toStringAsFixed(1)}%',
              ),
              _buildDetailRow(
                '最终数值',
                provider.getFinalAttribute(attrInfo.type).toString(),
              ),
              const SizedBox(height: 16),
              Text(
                attrInfo.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示变化历史
  void _showChangeHistory(BuildContext context) {
    final provider = Provider.of<AttributesProvider>(context, listen: false);
    final history = provider.changeHistory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('属性变化历史'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? const Center(
                  child: Text(
                    '暂无变化记录',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final change = history[index];
                    final attrInfo = AttributeInfo.fromType(change.type);
                    final isIncrease = change.newValue > change.oldValue;

                    return ListTile(
                      leading: Icon(
                        attrInfo.icon,
                        color: attrInfo.color,
                      ),
                      title: Text(attrInfo.name),
                      subtitle: Text(_formatDateTime(change.timestamp)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            change.oldValue.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isIncrease ? Icons.arrow_forward : Icons.arrow_back,
                            size: 16,
                            color: isIncrease ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            change.newValue.toString(),
                            style: TextStyle(
                              color: isIncrease ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearChangeHistory();
              Navigator.pop(context);
            },
            child: const Text('清空记录'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('确定要重置所有属性到默认值吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<AttributesProvider>(context, listen: false);
              provider.resetAttributes();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('属性已重置'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  String _getAttributeKey(AttributeType type) {
    switch (type) {
      case AttributeType.chakra:
        return 'chakra';
      case AttributeType.ninjutsu:
        return 'ninjutsu';
      case AttributeType.taijutsu:
        return 'taijutsu';
      case AttributeType.intelligence:
        return 'intelligence';
      case AttributeType.speed:
        return 'speed';
      case AttributeType.luck:
        return 'luck';
    }
  }

  String _getAttributeName(String key) {
    switch (key) {
      case 'chakra':
        return '查克拉';
      case 'ninjutsu':
        return '忍术';
      case 'taijutsu':
        return '体术';
      case 'intelligence':
        return '智力';
      case 'speed':
        return '速度';
      case 'luck':
        return '幸运';
      default:
        return '未知';
    }
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
