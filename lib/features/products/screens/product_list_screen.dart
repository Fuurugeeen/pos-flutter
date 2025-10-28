import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/product.dart';
import '../../../data/models/enums.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';
import 'package:go_router/go_router.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController searchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
  String searchQuery = '';
  ProductCategory? selectedCategory;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品管理'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () => context.go('/products/new'),
            tooltip: '新規商品追加',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/products/new'),
        icon: const Icon(Icons.add_box),
        label: const Text('新規商品'),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '商品管理',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            AppButton(
              text: 'CSVエクスポート',
              type: AppButtonType.outline,
              icon: Icons.download,
              onPressed: () => _exportProducts(),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'CSVインポート',
              type: AppButtonType.outline,
              icon: Icons.upload,
              onPressed: () => _importProducts(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppFormField(
                label: '商品検索',
                controller: searchController,
                hint: '商品名、バーコード、説明で検索...',
                prefixIcon: Icons.search,
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdownField<ProductCategory?>(
                label: 'カテゴリー',
                value: selectedCategory,
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
                    selectedCategory = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    final productRepository = ref.watch(productRepositoryProvider);

    return FutureBuilder(
      future: productRepository.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final result = snapshot.data;
        if (result == null) {
          return const SizedBox.shrink();
        }

        final products = result.isSuccess ? (result.data ?? []) : <Product>[];
        final totalProducts = products.length;
        final lowStockProducts = products.where((p) => p.stockQuantity <= (p.lowStockThreshold ?? 0)).length;
        final outOfStockProducts = products.where((p) => p.stockQuantity <= 0).length;
        final totalValue = products.fold<double>(
          0, 
          (sum, product) => sum + (product.price * product.stockQuantity),
        );
        
        return Row(
          children: [
            Expanded(
              child: AppInfoCard(
                title: '総商品数',
                value: '$totalProducts品',
                icon: Icons.inventory_2,
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
                value: '$lowStockProducts品',
                icon: Icons.warning,
                iconColor: Colors.orange,
                onTap: lowStockProducts > 0 ? () => _showLowStockProducts() : null,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '在庫切れ',
                value: '$outOfStockProducts品',
                icon: Icons.error,
                iconColor: Colors.red,
                onTap: outOfStockProducts > 0 ? () => _showOutOfStockProducts() : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductList() {
    final productRepository = ref.watch(productRepositoryProvider);

    return FutureBuilder(
      future: _getFilteredProducts(productRepository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = result.isSuccess ? (result.data ?? []) : <Product>[];
        
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isEmpty && selectedCategory == null
                      ? Icons.inventory_2
                      : Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty && selectedCategory == null
                      ? '商品データがありません'
                      : '検索結果が見つかりません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (searchQuery.isEmpty && selectedCategory == null) ...[
                  const SizedBox(height: 16),
                  AppButton(
                    text: '最初の商品を追加',
                    icon: Icons.add_box,
                    onPressed: () => context.go('/products/new'),
                  ),
                ],
              ],
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
                    const SizedBox(width: 60), // Image space
                    const Expanded(flex: 2, child: Text('商品名', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('カテゴリー', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('価格', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('在庫', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('ステータス', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 100),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductRow(product);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductRow(Product product) {
    final isLowStock = product.stockQuantity <= (product.lowStockThreshold ?? 0);
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_cafe,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.local_cafe,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              currencyFormatter.format(product.price),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/products/${product.id}/edit'),
                  tooltip: '編集',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product),
                  tooltip: '削除',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Result<List<Product>>> _getFilteredProducts(dynamic productRepository) async {
    List<Product> products = [];

    if (searchQuery.isEmpty) {
      final result = await productRepository.getAllProducts();
      if (result.isSuccess) {
        products = result.data ?? [];
      } else {
        return result; // Return the error result
      }
    } else {
      final result = await productRepository.searchProducts(searchQuery);
      if (result.isSuccess) {
        products = result.data ?? [];
      } else {
        return result; // Return the error result
      }
    }

    if (selectedCategory != null) {
      products = products.where((p) => p.category == selectedCategory).toList();
    }

    // Return a success result with the filtered products
    return Result.success(products);
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

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品削除'),
        content: Text('${product.name}を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: '削除',
            type: AppButtonType.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await ref.read(productRepositoryProvider).deleteProduct(product.id);
        setState(() {}); // Refresh the list
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name}を削除しました'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportProducts() async {
    try {
      final result = await ref.read(productRepositoryProvider).getAllProducts();

      if (result.isSuccess) {
        final products = result.data ?? [];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${products.length}件の商品データをエクスポートしました'),
            ),
          );
        }
      } else {
        if (mounted) {
          final errorMessage = result.error != null ? result.error.toString() : "不明なエラー";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エクスポートに失敗しました: $errorMessage'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エクスポートに失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _importProducts() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSVインポート機能は準備中です'),
        ),
      );
    }
  }

  void _showLowStockProducts() {
    // In a real app, this would filter to show only low stock products
    setState(() {
      selectedCategory = null;
      searchController.clear();
      searchQuery = '';
    });
  }

  void _showOutOfStockProducts() {
    // In a real app, this would filter to show only out of stock products
    setState(() {
      selectedCategory = null;
      searchController.clear();
      searchQuery = '';
    });
  }
}