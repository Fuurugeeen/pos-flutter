import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/cart_providers.dart';
import '../../../data/models/product.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sale_item.dart';
import '../../../data/models/enums.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';
import 'package:go_router/go_router.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController customerSearchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
  
  String searchQuery = '';
  Customer? selectedCustomer;
  List<Customer> customerSearchResults = [];
  bool isProcessingPayment = false;

  @override
  void dispose() {
    searchController.dispose();
    customerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS レジ'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _clearCart(),
            tooltip: 'カート初期化',
          ),
        ],
      ),
      body: Row(
        children: [
          // 商品選択エリア
          Expanded(
            flex: 2,
            child: _buildProductArea(),
          ),
          // カートエリア
          Expanded(
            flex: 1,
            child: _buildCartArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品選択',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '商品検索',
            controller: searchController,
            hint: '商品名またはバーコードで検索...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final productRepository = ref.watch(productRepositoryProvider);

    return FutureBuilder(
      future: searchQuery.isEmpty
        ? productRepository.getAllProducts()
        : productRepository.searchProducts(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final productsResult = snapshot.data;
        if (productsResult == null || !productsResult.isSuccess) {
          return const Center(child: Text('商品の読み込みに失敗しました'));
        }

        final products = productsResult.data ?? [];
        
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  '商品が見つかりません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isOutOfStock = product.stockQuantity <= 0;
    
    return AppCard(
      onTap: isOutOfStock ? null : () => _addToCart(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
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
                        size: 40,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.local_cafe,
                    size: 40,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            currencyFormatter.format(product.price),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isOutOfStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '在庫切れ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            )
          else
            Text(
              '在庫: ${product.stockQuantity}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartArea() {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ショッピングカート',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomerSelection(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildCartItems(cart, cartNotifier),
          ),
          _buildCartSummary(cart),
          const SizedBox(height: 16),
          _buildCheckoutButton(cart),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '顧客選択',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppFormField(
                label: '顧客検索',
                controller: customerSearchController,
                hint: '顧客名または電話番号で検索...',
                onChanged: (value) => _searchCustomer(value),
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'ゲスト',
              type: AppButtonType.outline,
              size: AppButtonSize.small,
              onPressed: () {
                setState(() {
                  selectedCustomer = null;
                  customerSearchController.clear();
                });
              },
            ),
          ],
        ),
        if (customerSearchResults.isNotEmpty && selectedCustomer == null) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: customerSearchResults.length,
              itemBuilder: (context, index) {
                final customer = customerSearchResults[index];
                return ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(customer.name),
                  subtitle: Text('ポイント: ${customer.loyaltyPoints}'),
                  onTap: () {
                    setState(() {
                      selectedCustomer = customer;
                      customerSearchController.text = customer.name;
                      customerSearchResults = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
        if (selectedCustomer != null) ...[
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCustomer!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ポイント: ${selectedCustomer!.loyaltyPoints}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      selectedCustomer = null;
                      customerSearchController.clear();
                      customerSearchResults = [];
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCartItems(Sale cart, dynamic cartNotifier) {
    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'カートが空です',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildCartItemFromSaleItem(item, cartNotifier);
      },
    );
  }

  Widget _buildCartItemFromSaleItem(SaleItem item, dynamic cartNotifier) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(item.unitPrice),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (item.quantity > 1) {
                    cartNotifier.updateItemQuantity(item.productId, item.quantity - 1);
                  } else {
                    cartNotifier.removeItem(item.productId);
                  }
                },
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => cartNotifier.updateItemQuantity(item.productId, item.quantity + 1),
              ),
            ],
          ),
          SizedBox(
            width: 80,
            child: Text(
              currencyFormatter.format(item.subtotal),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(Sale cart) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('小計'),
              Text(currencyFormatter.format(cart.subtotal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('税額'),
              Text(currencyFormatter.format(cart.totalTax)),
            ],
          ),
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('割引'),
                Text(
                  '-${currencyFormatter.format(cart.discountAmount)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '合計',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currencyFormatter.format(cart.finalTotal),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(Sale cart) {
    return AppButton(
      text: isProcessingPayment ? '処理中...' : '決済',
      icon: Icons.payment,
      isFullWidth: true,
      isLoading: isProcessingPayment,
      onPressed: cart.items.isEmpty || isProcessingPayment ? null : () => _processCheckout(),
    );
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} をカートに追加しました'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearCart() {
    ref.read(cartProvider.notifier).clearCart();
    setState(() {
      selectedCustomer = null;
      customerSearchController.clear();
    });
  }

  void _searchCustomer(String query) async {
    if (query.isEmpty) {
      setState(() {
        selectedCustomer = null;
        customerSearchResults = [];
      });
      return;
    }

    final customersResult = await ref.read(customerRepositoryProvider).searchCustomers(query);
    if (customersResult.isSuccess && customersResult.data != null) {
      setState(() {
        customerSearchResults = customersResult.data!;
      });
    }
  }

  Future<void> _processCheckout() async {
    setState(() {
      isProcessingPayment = true;
    });

    try {
      final cart = ref.read(cartProvider);

      // Use the completed sale with customer info
      final completedSale = cart.copyWith(
        customerId: selectedCustomer?.id,
        customerName: selectedCustomer?.name,
        status: SaleStatus.completed,
        updatedAt: DateTime.now(),
      );

      await ref.read(saleRepositoryProvider).createSale(completedSale);

      // Update stock quantities
      final productsResult = await ref.read(productRepositoryProvider).getAllProducts();
      if (productsResult.isSuccess && productsResult.data != null) {
        final productMap = {for (var p in productsResult.data!) p.id: p};

        for (final item in cart.items) {
          final product = productMap[item.productId];
          if (product != null) {
            final updatedProduct = product.copyWith(
              stockQuantity: product.stockQuantity - item.quantity,
            );
            await ref.read(productRepositoryProvider).updateProduct(updatedProduct);
          }
        }
      }

      // Update customer loyalty points
      if (selectedCustomer != null) {
        final pointsEarned = (completedSale.finalTotal / 100).floor();
        final updatedCustomer = selectedCustomer!.copyWith(
          loyaltyPoints: selectedCustomer!.loyaltyPoints + pointsEarned,
        );
        await ref.read(customerRepositoryProvider).updateCustomer(updatedCustomer);
      }

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();
      setState(() {
        selectedCustomer = null;
        customerSearchController.clear();
      });

      if (mounted) {
        _showCheckoutSuccess(completedSale);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('決済処理に失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  void _showCheckoutSuccess(Sale sale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('決済完了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('決済が完了しました。'),
            const SizedBox(height: 16),
            Text('レシート番号: ${sale.id}'),
            Text('合計金額: ${currencyFormatter.format(sale.finalTotal)}'),
            if (selectedCustomer != null)
              Text('獲得ポイント: ${(sale.finalTotal / 100).floor()}pt'),
          ],
        ),
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'ダッシュボードへ',
            type: AppButtonType.outline,
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}