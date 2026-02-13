import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../theme/app_colors.dart';

/// 物品详情弹窗
class ItemDetailDialog extends StatefulWidget {
  final Item item;
  final bool isOwned;
  final int ownedQuantity;
  final bool isEquipped;
  final VoidCallback? onPurchase;
  final VoidCallback? onUse;
  final VoidCallback? onEquip;
  final VoidCallback? onUnequip;

  const ItemDetailDialog({
    super.key,
    required this.item,
    this.isOwned = false,
    this.ownedQuantity = 0,
    this.isEquipped = false,
    this.onPurchase,
    this.onUse,
    this.onEquip,
    this.onUnequip,
  });

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return AppColors.rarityN;
      case ItemRarity.uncommon:
        return AppColors.rarityR;
      case ItemRarity.rare:
        return AppColors.raritySR;
      case ItemRarity.epic:
        return AppColors.raritySSR;
      case ItemRarity.legendary:
        return AppColors.rarityUR;
    }
  }

  String _getRarityLabel(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return 'N 普通';
      case ItemRarity.uncommon:
        return 'R 稀有';
      case ItemRarity.rare:
        return 'SR 史诗';
      case ItemRarity.epic:
        return 'SSR 传说';
      case ItemRarity.legendary:
        return 'UR 神话';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(widget.item.rarity);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 顶部稀有度条
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            rarityColor.withOpacity(0.5),
                            rarityColor,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),

                    // 内容区域
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 物品图标和名称
                          Row(
                            children: [
                              // 物品大图标
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      rarityColor.withOpacity(0.3),
                                      rarityColor.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: rarityColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: rarityColor,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 稀有度标签
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: rarityColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: rarityColor.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        _getRarityLabel(widget.item.rarity),
                                        style: TextStyle(
                                          color: rarityColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // 物品名称
                                    Text(
                                      widget.item.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // 物品类型
                                    Text(
                                      widget.item.typeName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 分隔线
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.textSecondary.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 物品描述
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.item.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),

                          // 物品效果
                          if (widget.item.effect != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.1),
                                    AppColors.primary.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '效果: ${widget.item.effect!.target} +${widget.item.effect!.value}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // 价格和数量信息
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 价格
                              if (!widget.isOwned)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSecondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${widget.item.price}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSecondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.inventory,
                                        color: AppColors.info,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '拥有: ${widget.ownedQuantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // 装备状态
                              if (widget.item.canEquip && widget.isOwned)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.isEquipped
                                        ? AppColors.success.withOpacity(0.2)
                                        : AppColors.bgSecondary,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: widget.isEquipped
                                          ? AppColors.success
                                          : AppColors.textSecondary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        widget.isEquipped
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: widget.isEquipped
                                            ? AppColors.success
                                            : AppColors.textSecondary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.isEquipped ? '已装备' : '未装备',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: widget.isEquipped
                                              ? AppColors.success
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],

                          const SizedBox(height: 24),

                          // 操作按钮
                          Row(
                            children: [
                              // 关闭按钮
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: BorderSide(
                                      color: AppColors.textSecondary.withOpacity(0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('关闭'),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 主要操作按钮
                              Expanded(
                                child: _buildActionButton(rarityColor),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildActionButton(Color rarityColor) {
    // 如果未拥有，显示购买按钮
    if (!widget.isOwned) {
      return ElevatedButton(
        onPressed: widget.onPurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: rarityColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shadowColor: rarityColor.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 20),
            const SizedBox(width: 6),
            const Text(
              '购买',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 如果可以装备
    if (widget.item.canEquip) {
      if (widget.isEquipped) {
        return ElevatedButton(
          onPressed: widget.onUnequip,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bgSecondary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.remove_circle_outline, size: 20),
              SizedBox(width: 6),
              Text(
                '卸下',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: widget.onEquip,
          style: ElevatedButton.styleFrom(
            backgroundColor: rarityColor,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shadowColor: rarityColor.withOpacity(0.4),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 20),
              SizedBox(width: 6),
              Text(
                '装备',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }
    }

    // 如果可以使用
    if (widget.item.canUse) {
      return ElevatedButton(
        onPressed: widget.onUse,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shadowColor: AppColors.success.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 20),
            const SizedBox(width: 6),
            const Text(
              '使用',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 默认
    return const SizedBox.shrink();
  }
}

/// 显示物品详情弹窗的便捷方法
Future<void> showItemDetailDialog(
  BuildContext context, {
  required Item item,
  bool isOwned = false,
  int ownedQuantity = 0,
  bool isEquipped = false,
  VoidCallback? onPurchase,
  VoidCallback? onUse,
  VoidCallback? onEquip,
  VoidCallback? onUnequip,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => ItemDetailDialog(
      item: item,
      isOwned: isOwned,
      ownedQuantity: ownedQuantity,
      isEquipped: isEquipped,
      onPurchase: onPurchase,
      onUse: onUse,
      onEquip: onEquip,
      onUnequip: onUnequip,
    ),
  );
}
