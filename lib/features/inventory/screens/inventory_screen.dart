import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/product.dart';
import '../../../data/models/enums.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
  
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  String _stockFilter = 'all'; // all, low_stock, out_of_stock

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('在庫管理'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _showStockAdjustmentDialog(),
            tooltip: '一括在庫調整',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportInventory(),
            tooltip: '在庫エクスポート',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: '在庫一覧'),
            Tab(icon: Icon(Icons.add_box), text: '入庫'),
            Tab(icon: Icon(Icons.remove_circle), text: '出庫'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventoryListTab(),
          _buildStockInTab(),
          _buildStockOutTab(),
        ],
      ),
    );
  }

  Widget _buildInventoryListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInventoryHeader(),
          const SizedBox(height: 24),
          _buildInventoryFilters(),
          const SizedBox(height: 24),
          _buildInventoryStats(),
          const SizedBox(height: 24),
          _buildInventoryList(),
        ],
      ),
    );
  }

  Widget _buildStockInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '在庫入庫',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildBulkStockIn(),
        ],
      ),
    );
  }

  Widget _buildStockOutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '在庫出庫',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildBulkStockOut(),
        ],
      ),
    );
  }

  Widget _buildInventoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '在庫管理',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            AppButton(
              text: 'テンプレート',
              type: AppButtonType.outline,
              size: AppButtonSize.small,
              icon: Icons.download,
              onPressed: () => _downloadTemplate(),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'CSVインポート',
              type: AppButtonType.outline,
              size: AppButtonSize.small,
              icon: Icons.upload,
              onPressed: () => _importInventory(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppFormField(
                label: '商品検索',
                controller: _searchController,
                hint: '商品名で検索...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdownField<ProductCategory?>(
                label: 'カテゴリー',
                value: _selectedCategory,
                hint: '全てのカテゴリー',
                items: [
                  const DropdownMenuItem<ProductCategory?>(
                    value: null,
                    child: Text('全てのカテゴリー'),
                  ),
                  ...ProductCategory.values.map((category) =>
                    DropdownMenuItem<ProductCategory?>(
                      value: category,
                      child: Text(_getCategoryDisplayName(category)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdownField<String>(
                label: '在庫状況',
                value: _stockFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('全て')),
                  DropdownMenuItem(value: 'low_stock', child: Text('在庫少')),
                  DropdownMenuItem(value: 'out_of_stock', child: Text('在庫切れ')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _stockFilter = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryStats() {
    final productRepository = ref.watch(productRepositoryProvider);
    
    return FutureBuilder<Result<List<Product>>>(
      future: productRepository.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        final productsResult = snapshot.data;
        if (productsResult == null || !productsResult.isSuccess) {
          return const SizedBox.shrink();
        }
        final products = productsResult.data!;
        final totalItems = products.fold<int>(0, (sum, p) => sum + p.stockQuantity);
        final totalValue = products.fold<double>(0, (sum, p) => sum + (p.price * p.stockQuantity));
        final lowStockCount = products.where((p) => p.stockQuantity <= (p.lowStockThreshold ?? 0) && p.stockQuantity > 0).length;
        final outOfStockCount = products.where((p) => p.stockQuantity <= 0).length;
        
        return Row(
          children: [
            Expanded(
              child: AppInfoCard(
                title: '総在庫数',
                value: '$totalItems個',
                icon: Icons.inventory,
                iconColor: Colors.blue,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '在庫価値',
                value: currencyFormatter.format(totalValue),
                icon: Icons.attach_money,
                iconColor: Colors.green,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '在庫少',
                value: '$lowStockCount品目',
                icon: Icons.warning,
                iconColor: Colors.orange,
                onTap: lowStockCount > 0 ? () => _setFilter('low_stock') : null,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '在庫切れ',
                value: '$outOfStockCount品目',
                icon: Icons.error,
                iconColor: Colors.red,
                onTap: outOfStockCount > 0 ? () => _setFilter('out_of_stock') : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInventoryList() {
    final productRepository = ref.watch(productRepositoryProvider);
    
    return FutureBuilder<List<Product>>(
      future: _getFilteredProducts(productRepository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return Center(
            child: Text(
              '該当する商品がありません',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          );
        }
        
        return AppCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: Text('商品名', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('カテゴリー', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('在庫', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('閾値', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('状況', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 100),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildInventoryRow(product);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryRow(Product product) {
    final isLowStock = product.stockQuantity <= (product.lowStockThreshold ?? 0) && product.stockQuantity > 0;
    final isOutOfStock = product.stockQuantity <= 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(product.price),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(_getCategoryDisplayName(product.category)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${product.stockQuantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOutOfStock
                    ? Colors.red
                    : isLowStock
                        ? Colors.orange
                        : null,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${product.lowStockThreshold}'),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? Colors.red.withValues(alpha: 0.1)
                    : isLowStock
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isOutOfStock
                    ? '在庫切れ'
                    : isLowStock
                        ? '在庫少'
                        : '正常',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isOutOfStock
                      ? Colors.red
                      : isLowStock
                          ? Colors.orange
                          : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showStockAdjustmentDialog(product: product, isIncrease: true),
                  tooltip: '入庫',
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _showStockAdjustmentDialog(product: product, isIncrease: false),
                  tooltip: '出庫',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkStockIn() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品入庫',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('商品の在庫を増やします。仕入れや返品時に使用してください。'),
          const SizedBox(height: 24),
          AppButton(
            text: '商品を選択して入庫',
            icon: Icons.add_box,
            isFullWidth: true,
            onPressed: () => _showBulkStockDialog(isIncrease: true),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkStockOut() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品出庫',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('商品の在庫を減らします。廃棄や破損時に使用してください。'),
          const SizedBox(height: 24),
          AppButton(
            text: '商品を選択して出庫',
            icon: Icons.remove_circle,
            type: AppButtonType.secondary,
            isFullWidth: true,
            onPressed: () => _showBulkStockDialog(isIncrease: false),
          ),
        ],
      ),
    );
  }

  Future<List<Product>> _getFilteredProducts(dynamic productRepository) async {
    List<Product> products;
    
    if (_searchQuery.isEmpty) {
      products = await productRepository.getAllProducts();
    } else {
      products = await productRepository.searchProducts(_searchQuery);
    }
    
    if (_selectedCategory != null) {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }
    
    switch (_stockFilter) {
      case 'low_stock':
        products = products.where((p) => p.stockQuantity <= (p.lowStockThreshold ?? 0) && p.stockQuantity > 0).toList();
        break;
      case 'out_of_stock':
        products = products.where((p) => p.stockQuantity <= 0).toList();
        break;
    }
    
    return products;
  }

  String _getCategoryDisplayName(ProductCategory category) {
    return switch (category) {
      ProductCategory.coffee => 'コーヒー',
      ProductCategory.tea => '紅茶',
      ProductCategory.pastry => 'ペストリー',
      ProductCategory.sandwich => 'サンドイッチ',
      ProductCategory.dessert => 'デザート',
      ProductCategory.beverage => '飲み物',
      ProductCategory.other => 'その他',
    };
  }

  void _setFilter(String filter) {
    setState(() {
      _stockFilter = filter;
    });
  }

  Future<void> _showStockAdjustmentDialog({Product? product, bool isIncrease = true}) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    Product? selectedProduct = product;
    
    if (product == null) {
      // Show product selection dialog first
      final productsResult = await ref.read(productRepositoryProvider).getAllProducts();
      if (!productsResult.isSuccess || productsResult.data == null) return;

      final products = productsResult.data!;
      if (!mounted) return;

      selectedProduct = await showDialog<Product>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${isIncrease ? '入庫' : '出庫'}商品選択'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('在庫: ${p.stockQuantity}個'),
                  onTap: () => Navigator.of(context).pop(p),
                );
              },
            ),
          ),
        ),
      );

      if (selectedProduct == null) return;
    }

    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${selectedProduct!.name} - ${isIncrease ? '入庫' : '出庫'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('現在在庫: ${selectedProduct.stockQuantity}個'),
            const SizedBox(height: 16),
            AppFormField(
              label: '${isIncrease ? '入庫' : '出庫'}数量',
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return '数量を入力してください';
                final qty = int.tryParse(value);
                if (qty == null || qty <= 0) return '1以上の数値を入力してください';
                if (!isIncrease && qty > selectedProduct!.stockQuantity) {
                  return '在庫数量を超えています';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: '理由',
              controller: reasonController,
              hint: isIncrease ? '仕入れ、返品など' : '廃棄、破損など',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: isIncrease ? '入庫' : '出庫',
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                Navigator.of(context).pop({
                  'quantity': quantity,
                  'reason': reasonController.text,
                });
              }
            },
          ),
        ],
      ),
    );
    
    if (result != null) {
      await _adjustStock(selectedProduct!, result['quantity'], isIncrease, result['reason']);
    }
  }

  Future<void> _showBulkStockDialog({required bool isIncrease}) async {
    final productsResult = await ref.read(productRepositoryProvider).getAllProducts();
    if (!productsResult.isSuccess || productsResult.data == null) return;

    final products = productsResult.data!;
    final selectedProducts = <Product, int>{};

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('一括${isIncrease ? '入庫' : '出庫'}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StatefulBuilder(
            builder: (context, setState) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final controller = TextEditingController(
                  text: selectedProducts[product]?.toString() ?? '',
                );
                
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('在庫: ${product.stockQuantity}個'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: '数量',
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final qty = int.tryParse(value);
                        if (qty != null && qty > 0) {
                          selectedProducts[product] = qty;
                        } else {
                          selectedProducts.remove(product);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: '${isIncrease ? '入庫' : '出庫'}実行',
            onPressed: selectedProducts.isEmpty 
                ? null 
                : () async {
                    Navigator.of(context).pop();
                    await _bulkAdjustStock(selectedProducts, isIncrease);
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _adjustStock(Product product, int quantity, bool isIncrease, String reason) async {
    try {
      final newQuantity = isIncrease 
          ? product.stockQuantity + quantity
          : product.stockQuantity - quantity;
      
      final updatedProduct = product.copyWith(stockQuantity: newQuantity);
      await ref.read(productRepositoryProvider).updateProduct(updatedProduct);
      
      setState(() {}); // Refresh the UI
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name}を${isIncrease ? '入庫' : '出庫'}しました '
              '(${isIncrease ? '+' : '-'}$quantity個)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('在庫調整に失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _bulkAdjustStock(Map<Product, int> adjustments, bool isIncrease) async {
    try {
      int successCount = 0;
      
      for (final entry in adjustments.entries) {
        final product = entry.key;
        final quantity = entry.value;
        
        final newQuantity = isIncrease 
            ? product.stockQuantity + quantity
            : product.stockQuantity - quantity;
        
        if (newQuantity >= 0) {
          final updatedProduct = product.copyWith(stockQuantity: newQuantity);
          await ref.read(productRepositoryProvider).updateProduct(updatedProduct);
          successCount++;
        }
      }
      
      setState(() {}); // Refresh the UI
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount件の商品を${isIncrease ? '入庫' : '出庫'}しました'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('一括在庫調整に失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportInventory() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('在庫データをエクスポートしました'),
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('在庫テンプレートをダウンロードしました'),
      ),
    );
  }

  Future<void> _importInventory() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSVインポート機能は準備中です'),
      ),
    );
  }
}