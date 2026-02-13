import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../services/shop_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  List<Map<String, String>> _categories = [];
  List<Item> _items = [];
  String _selectedCategory = 'all';
  ItemType? _selectedType;
  ItemRarity? _selectedRarity;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int _playerGold = 0; // 玩家金币

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _loadCategories(),
      _loadItems(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  /// 加载分类
  Future<void> _loadCategories() async {
    final categories = await _shopService.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  /// 加载商品列表
  Future<void> _loadItems({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
      }
    });

    final items = await _shopService.getShopItems(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      type: _selectedType,
      rarity: _selectedRarity,
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (refresh) {
          _items = items;
        } else {
          _items.addAll(items);
        }
        _hasMore = items.length >= 20;
        _isLoading = false;
      });
    }
  }

  /// 购买物品
  Future<void> _purchaseItem(Item item) async {
    final quantity = await _showQuantityDialog(item);
    if (quantity == null || quantity <= 0) return;

    final totalCost = item.price * quantity;
    if (totalCost > _playerGold) {
      _showErrorDialog('金币不足！');
      return;
    }

    final result = await _shopService.purchaseItem(
      itemId: item.itemId,
      quantity: quantity,
    );

    if (mounted) {
      if (result['success']) {
        _showSuccessDialog('购买成功！花费 ${totalCost} 金币');
        // 更新金币
        // setState(() {
        //   _playerGold -= totalCost;
        // });
      } else {
        _showErrorDialog(result['message']);
      }
    }
  }

  /// 显示数量选择对话框
  Future<int?> _showQuantityDialog(Item item) async {
    int quantity = 1;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('购买 ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setDialogState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: quantity < (item.maxStack ?? 99)
                        ? () => setDialogState(() => quantity++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '总价: ${item.price * quantity} 金币',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, quantity),
              child: const Text('购买'),
            ),
          ],
        ),
      ),
    );
    return result;
  }

  /// 显示成功对话框
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('成功'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示物品详情对话框
  void _showItemDetail(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(item.rarityColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null)
                Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: _getRarityColor(item.rarity),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                item.rarityName,
                style: TextStyle(
                  color: _getRarityColor(item.rarity),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('类型: ${item.typeName}'),
              const SizedBox(height: 8),
              Text('分类: ${item.category}'),
              const SizedBox(height: 16),
              const Text(
                '描述:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(item.description),
              if (item.effect != null) ...[
                const SizedBox(height: 16),
                const Text(
                  '效果:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${item.effect!.type}: ${item.effect!.target} +${item.effect!.value}'),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '售价:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${item.price} 金币',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (item.sellPrice > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '回收价:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${item.sellPrice} 金币'),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseItem(item);
            },
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }

  /// 获取稀有度颜色
  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.blue;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.purple;
      case ItemRarity.epic:
        return Colors.orange;
      case ItemRarity.legendary:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('忍具商店'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(
                  '$_playerGold',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类选择
          _buildCategories(),
          // 筛选按钮
          _buildFilters(),
          // 商品列表
          Expanded(
            child: _isLoading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('暂无商品'))
                    : NotificationListener<ScrollNotification>(
                        onScroll: (scrollInfo) {
                          if (!_isLoading &&
                              _hasMore &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                            _currentPage++;
                            _loadItems();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _items.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final item = _items[index];
                            return _buildItemCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// 构建分类选择器
  Widget _buildCategories() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category['name']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id']!;
                  _selectedType = null;
                  _loadItems(refresh: true);
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  /// 构建筛选按钮
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<ItemType>(
              decoration: const InputDecoration(
                labelText: '类型',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _selectedType,
              items: ItemType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                  _loadItems(refresh: true);
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<ItemRarity>(
              decoration: const InputDecoration(
                labelText: '稀有度',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _selectedRarity,
              items: ItemRarity.values.map((rarity) {
                return DropdownMenuItem(
                  value: rarity,
                  child: Text(_getRarityName(rarity)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRarity = value;
                  _loadItems(refresh: true);
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedRarity = null;
                _loadItems(refresh: true);
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  /// 构建物品卡片
  Widget _buildItemCard(Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getRarityColor(item.rarity).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: _getRarityColor(item.rarity),
          ),
        ),
        title: Row(
          children: [
            Text(item.rarityColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.typeName),
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.price} 💰',
              style: const TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () => _showItemDetail(item),
      ),
    );
  }

  /// 获取类型名称
  String _getTypeName(ItemType type) {
    switch (type) {
      case ItemType.tool:
        return '忍具';
      case ItemType.medicine:
        return '药品';
      case ItemType.equipment:
        return '装备';
      case ItemType.material:
        return '材料';
    }
  }

  /// 获取稀有度名称
  String _getRarityName(ItemRarity rarity) {
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
}
