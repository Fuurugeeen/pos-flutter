import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/cart_providers.dart';
import '../../../data/models/product.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sale_item.dart';
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
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
    
    return FutureBuilder<List<Product>>(
      future: searchQuery.isEmpty 
        ? productRepository.getAllProducts()
        : productRepository.searchProducts(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  '商品が見つかりません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                color: Theme.of(context).colorScheme.surfaceVariant,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildCartItems(Map<String, int> cart, dynamic cartNotifier) {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'カートが空です',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    return FutureBuilder<List<Product>>(
      future: ref.read(productRepositoryProvider).getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final products = snapshot.data ?? [];
        final productMap = {for (var p in products) p.id: p};
        
        return ListView.builder(
          itemCount: cart.length,
          itemBuilder: (context, index) {
            final productId = cart.keys.elementAt(index);
            final quantity = cart[productId]!;
            final product = productMap[productId];
            
            if (product == null) return const SizedBox.shrink();
            
            return _buildCartItem(product, quantity, cartNotifier);
          },
        );
      },
    );
  }

  Widget _buildCartItem(Product product, int quantity, dynamic cartNotifier) {
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
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(product.price),
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
                onPressed: () => cartNotifier.decreaseQuantity(product.id),
              ),
              Text(
                '$quantity',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => cartNotifier.addToCart(product.id),
              ),
            ],
          ),
          SizedBox(
            width: 80,
            child: Text(
              currencyFormatter.format(product.price * quantity),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(Map<String, int> cart) {
    return FutureBuilder<List<Product>>(
      future: ref.read(productRepositoryProvider).getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        
        final products = snapshot.data ?? [];
        final productMap = {for (var p in products) p.id: p};
        
        double subtotal = 0;
        for (final entry in cart.entries) {
          final product = productMap[entry.key];
          if (product != null) {
            subtotal += product.price * entry.value;
          }
        }
        
        final taxAmount = subtotal * 0.1; // 10% tax
        final total = subtotal + taxAmount;
        
        return AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('小計'),
                  Text(currencyFormatter.format(subtotal)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('税額 (10%)'),
                  Text(currencyFormatter.format(taxAmount)),
                ],
              ),
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
                    currencyFormatter.format(total),
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
      },
    );
  }

  Widget _buildCheckoutButton(Map<String, int> cart) {
    return AppButton(
      text: isProcessingPayment ? '処理中...' : '決済',
      icon: Icons.payment,
      isFullWidth: true,
      isLoading: isProcessingPayment,
      onPressed: cart.isEmpty || isProcessingPayment ? null : () => _processCheckout(),
    );
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addToCart(product.id);
    
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
      });
      return;
    }
    
    final customers = await ref.read(customerRepositoryProvider).searchCustomers(query);
    if (customers.isNotEmpty) {
      setState(() {
        selectedCustomer = customers.first;
      });
    }
  }

  Future<void> _processCheckout() async {
    setState(() {
      isProcessingPayment = true;
    });
    
    try {
      final cart = ref.read(cartProvider);
      final products = await ref.read(productRepositoryProvider).getAllProducts();
      final productMap = {for (var p in products) p.id: p};
      
      final saleItems = <SaleItem>[];
      double subtotal = 0;
      
      for (final entry in cart.entries) {
        final product = productMap[entry.key];
        if (product != null) {
          final saleItem = SaleItem(
            productId: product.id,
            productName: product.name,
            unitPrice: product.price,
            quantity: entry.value,
          );
          saleItems.add(saleItem);
          subtotal += saleItem.totalPrice;
        }
      }
      
      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: selectedCustomer?.id,
        customerName: selectedCustomer?.name,
        items: saleItems,
        subtotal: subtotal,
        taxAmount: subtotal * 0.1,
        totalAmount: subtotal * 1.1,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      );
      
      await ref.read(saleRepositoryProvider).createSale(sale);
      
      // Update stock quantities
      for (final entry in cart.entries) {
        final product = productMap[entry.key];
        if (product != null) {
          final updatedProduct = product.copyWith(
            stockQuantity: product.stockQuantity - entry.value,
          );
          await ref.read(productRepositoryProvider).updateProduct(updatedProduct);
        }
      }
      
      // Update customer loyalty points
      if (selectedCustomer != null) {
        final pointsEarned = (sale.totalAmount / 100).floor();
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
        _showCheckoutSuccess(sale);
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
            Text('合計金額: ${currencyFormatter.format(sale.totalAmount)}'),
            if (selectedCustomer != null)
              Text('獲得ポイント: ${(sale.totalAmount / 100).floor()}pt'),
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