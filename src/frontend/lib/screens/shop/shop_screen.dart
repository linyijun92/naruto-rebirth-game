import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../services/shop_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/item_detail_dialog.dart';

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
  int _minPrice = 0;
  int _maxPrice = 999999;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  // 玩家货币
  int _playerGold = 50000;
  int _playerDiamond = 1000;

  // 购物车
  final Map<String, int> _cart = {};
  bool _showCart = false;

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

    // 价格筛选
    final filteredItems = items.where((item) {
      return item.price >= _minPrice && item.price <= _maxPrice;
    }).toList();

    if (mounted) {
      setState(() {
        if (refresh) {
          _items = filteredItems;
        } else {
          _items.addAll(filteredItems);
        }
        _hasMore = items.length >= 20;
        _isLoading = false;
      });
    }
  }

  /// 添加到购物车
  void _addToCart(Item item) {
    setState(() {
      if (_cart.containsKey(item.itemId)) {
        _cart[item.itemId] = _cart[item.itemId]! + 1;
      } else {
        _cart[item.itemId] = 1;
      }
    });
    _showSuccessSnackBar('已添加到购物车');
  }

  /// 从购物车移除
  void _removeFromCart(String itemId) {
    setState(() {
      if (_cart.containsKey(itemId)) {
        if (_cart[itemId]! > 1) {
          _cart[itemId] = _cart[itemId]! - 1;
        } else {
          _cart.remove(itemId);
        }
      }
    });
  }

  /// 获取购物车总价
  int _getCartTotal() {
    int total = 0;
    _cart.forEach((itemId, quantity) {
      final item = _items.firstWhere((i) => i.itemId == itemId);
      total += item.price * quantity;
    });
    return total;
  }

  /// 结账
  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      _showErrorSnackBar('购物车为空');
      return;
    }

    final totalCost = _getCartTotal();
    if (totalCost > _playerGold) {
      _showErrorSnackBar('金币不足！');
      return;
    }

    // 模拟购买
    setState(() {
      _playerGold -= totalCost;
      _cart.clear();
    });

    _showSuccessSnackBar('购买成功！花费 $totalCost 金币');
  }

  /// 显示物品详情
  void _showItemDetail(Item item) {
    showItemDetailDialog(
      context,
      item: item,
      onPurchase: () {
        Navigator.pop(context);
        _addToCart(item);
      },
    );
  }

  /// 显示筛选器
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('筛选条件'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 稀有度筛选
              const Text('稀有度', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ItemRarity.values.map((rarity) {
                  final isSelected = _selectedRarity == rarity;
                  return FilterChip(
                    label: Text(_getRarityName(rarity)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setDialogState(() {
                        _selectedRarity = selected ? rarity : null;
                      });
                    },
                    selectedColor: _getRarityColor(rarity).withOpacity(0.3),
                    checkmarkColor: _getRarityColor(rarity),
                    labelStyle: TextStyle(
                      color: isSelected ? _getRarityColor(rarity) : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // 价格范围
              const Text('价格范围', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '最低价',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _minPrice.toString()),
                      onChanged: (value) {
                        _minPrice = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '最高价',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _maxPrice.toString()),
                      onChanged: (value) {
                        _maxPrice = int.tryParse(value) ?? 999999;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRarity = null;
                  _minPrice = 0;
                  _maxPrice = 999999;
                });
                Navigator.pop(context);
                _loadItems(refresh: true);
              },
              child: const Text('重置'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadItems(refresh: true);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示购物车
  void _showCartDialog() {
    if (_cart.isEmpty) {
      _showErrorSnackBar('购物车为空');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              const Text('购物车'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_cart.length} 件',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final itemId = _cart.keys.elementAt(index);
                final quantity = _cart[itemId]!;
                final item = _items.firstWhere((i) => i.itemId == itemId);
                final total = item.price * quantity;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '单价: ${item.price} 金币',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  iconSize: 20,
                                  onPressed: () {
                                    setDialogState(() {
                                      _removeFromCart(itemId);
                                    });
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  iconSize: 20,
                                  onPressed: () {
                                    setDialogState(() {
                                      _addToCart(item);
                                    });
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                            Text(
                              '总计: $total',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                _checkout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('结账 (${_getCartTotal()} 金币)'),
            ),
          ],
        ),
      ),
    );
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
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
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
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
        title: const Text('忍具商店'),
        actions: [
          // 金币
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$_playerGold',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 钻石
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.cyan, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$_playerDiamond',
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 分类标签页
          _buildCategories(),

          // 筛选栏
          _buildFilterBar(),

          // 商品列表
          Expanded(
            child: _isLoading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无商品',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
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
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
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

          // 购物车栏
          _buildCartBar(),
        ],
      ),
    );
  }

  /// 构建分类选择器
  Widget _buildCategories() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.bgTertiary),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
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
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.bgTertiary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.textDisabled,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建筛选栏
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.bgTertiary),
        ),
      ),
      child: Row(
        children: [
          // 类型筛选
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ItemType>(
                  isExpanded: true,
                  value: _selectedType,
                  hint: Text(
                    '类型',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  dropdownColor: AppColors.bgTertiary,
                  iconEnabledColor: AppColors.textSecondary,
                  style: TextStyle(color: AppColors.textPrimary),
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
            ),
          ),
          const SizedBox(width: 8),
          // 筛选按钮
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            color: AppColors.textSecondary,
            tooltip: '筛选',
          ),
          // 刷新按钮
          IconButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedRarity = null;
                _minPrice = 0;
                _maxPrice = 999999;
                _loadItems(refresh: true);
              });
            },
            icon: const Icon(Icons.refresh),
            color: AppColors.textSecondary,
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  /// 构建物品卡片
  Widget _buildItemCard(Item item) {
    final rarityColor = _getRarityColor(item.rarity);

    return Card(
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showItemDetail(item),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 稀有度边框
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rarityColor.withOpacity(0.5), rarityColor],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),

            // 物品图标
            Expanded(
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        rarityColor.withOpacity(0.2),
                        rarityColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: rarityColor, width: 2),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: rarityColor,
                    size: 48,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 物品名称和等级
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rarityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.rarityName.split(' ')[0],
                          style: TextStyle(
                            fontSize: 10,
                            color: rarityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 物品类型
                  Text(
                    item.typeName,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // 快速购买按钮
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建购物车栏
  Widget _buildCartBar() {
    if (_cart.isEmpty) return const SizedBox.shrink();

    final total = _getCartTotal();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.shopping_cart, color: AppColors.primary),
                  ),
                  if (_cart.length > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_cart.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '购物车',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '总计: $total 金币',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _showCartDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('查看购物车'),
            ),
          ],
        ),
      ),
    );
  }

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
}
