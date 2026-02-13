import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attributes.dart';
import '../providers/attributes_provider.dart';
import '../theme/app_colors.dart';

class AttributesScreen extends StatelessWidget {
  const AttributesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
        title: const Text('角色属性'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showChangeHistory(context),
            tooltip: '变化历史',
            color: AppColors.textSecondary,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppColors.bgCard,
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    const Text(
                      '重置属性',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
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
                // 属性总览卡片
                _buildSummaryCard(provider),
                const SizedBox(height: 24),

                // 核心属性标题
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '核心属性',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 属性卡片列表
                ...AttributeInfo.allAttributes.map(
                  (attrInfo) => _buildAttributeCard(context, attrInfo, provider),
                ),
                const SizedBox(height: 24),

                // 统计卡片
                _buildStatsCard(provider),
                const SizedBox(height: 80), // 底部空间
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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bgCard, AppColors.bgSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '总计: $total',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.arrow_upward,
                    label: '最强属性',
                    value: _getAttributeName(strongest.key),
                    subValue: strongest.value.toString(),
                    color: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.arrow_downward,
                    label: '最弱属性',
                    value: _getAttributeName(weakest.key),
                    subValue: weakest.value.toString(),
                    color: AppColors.warning,
                    bgColor: AppColors.warning.withOpacity(0.1),
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
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
    final maxValue = attrInfo.maxValue;
    final progress = value / maxValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgCard,
            AppColors.bgCard.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: attrInfo.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: attrInfo.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAttributeDetail(context, attrInfo, provider),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 属性头部
                Row(
                  children: [
                    // 属性图标
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            attrInfo.color.withOpacity(0.3),
                            attrInfo.color.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: attrInfo.color.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(attrInfo.icon, color: attrInfo.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // 属性信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                attrInfo.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 等级标签
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      levelColor.withOpacity(0.3),
                                      levelColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: levelColor.withOpacity(0.5),
                                  ),
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
                          const SizedBox(height: 6),
                          Text(
                            attrInfo.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 属性数值
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (bonus > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${(bonus * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 渐变进度条
                Stack(
                  children: [
                    // 背景进度条
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: attrInfo.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // 前景进度条（渐变）
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              attrInfo.color.withOpacity(0.4),
                              attrInfo.color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: attrInfo.color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 进度文字
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: attrInfo.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      maxValue.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),

                // 最终数值显示
                if (bonus > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '最终数值: $finalValue',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatsCard(AttributesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textDisabled.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '属性统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow('平均属性', provider.getTotalAttributes() / 6),
            const Divider(height: 24, color: AppColors.bgTertiary),
            _buildStatRow('最高单属性', provider.getStrongestAttribute().value),
            const Divider(height: 24, color: AppColors.bgTertiary),
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
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgTertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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
      builder: (context) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部颜色条
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      attrInfo.color.withOpacity(0.5),
                      attrInfo.color,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                attrInfo.color.withOpacity(0.3),
                                attrInfo.color.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: attrInfo.color.withOpacity(0.5),
                            ),
                          ),
                          child: Icon(attrInfo.icon, color: attrInfo.color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attrInfo.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                levelName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: levelColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 描述
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 详细信息
                    _buildDetailRow('当前数值', value.toString()),
                    _buildDetailRow('属性等级', levelName, color: levelColor),
                    _buildDetailRow(
                      '加成比例',
                      '${(provider.getBonusRate(attrInfo.type) * 100).toStringAsFixed(1)}%',
                      color: AppColors.success,
                    ),
                    _buildDetailRow(
                      '最终数值',
                      provider.getFinalAttribute(attrInfo.type).toString(),
                      color: attrInfo.color,
                    ),
                    const SizedBox(height: 16),
                    // 属性说明
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: attrInfo.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: attrInfo.color.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: attrInfo.color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              attrInfo.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 关闭按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: attrInfo.color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '关闭',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
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
      builder: (context) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: Column(
            children: [
              // 标题
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.bgTertiary),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      '属性变化历史',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // 历史列表
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无变化记录',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: history.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final change = history[index];
                          final attrInfo = AttributeInfo.fromType(change.type);
                          final isIncrease = change.newValue > change.oldValue;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: attrInfo.color.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: attrInfo.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    attrInfo.icon,
                                    color: attrInfo.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        attrInfo.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _formatDateTime(change.timestamp),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textDisabled,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 变化值
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isIncrease
                                        ? AppColors.success.withOpacity(0.2)
                                        : AppColors.error.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        change.oldValue.toString(),
                                        style: TextStyle(
                                          color: AppColors.textDisabled,
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        isIncrease
                                            ? Icons.arrow_forward
                                            : Icons.arrow_back,
                                        size: 14,
                                        color: isIncrease
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        change.newValue.toString(),
                                        style: TextStyle(
                                          color: isIncrease
                                              ? AppColors.success
                                              : AppColors.error,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // 底部按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.clearChangeHistory();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('清空记录'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('关闭'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text(
              '确认重置',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: const Text(
          '确定要重置所有属性到默认值吗？此操作不可撤销。',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<AttributesProvider>(context, listen: false);
              provider.resetAttributes();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('属性已重置'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
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
