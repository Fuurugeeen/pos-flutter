import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/product.dart';
import '../../../data/models/customer.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
  final dateFormatter = DateFormat('yyyy/MM/dd');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('売上レポート'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(),
            tooltip: '期間選択',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(),
            tooltip: 'レポートエクスポート',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: '概要'),
            Tab(icon: Icon(Icons.trending_up), text: '売上'),
            Tab(icon: Icon(Icons.inventory_2), text: '商品'),
            Tab(icon: Icon(Icons.people), text: '顧客'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesTab(),
          _buildProductsTab(),
          _buildCustomersTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 24),
          _buildOverviewStats(),
          const SizedBox(height: 24),
          _buildTrendChart(),
          const SizedBox(height: 24),
          _buildTopProducts(),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    final saleRepository = ref.watch(saleRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 24),
          FutureBuilder(
            future: saleRepository.getSalesByDateRange(_startDate, _endDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final result = snapshot.data;
              if (result == null) {
                return const Center(child: Text('データがありません'));
              }

              final sales = result.isSuccess ? (result.data ?? []) : <Sale>[];
              return Column(
                children: [
                  _buildSalesStats(sales),
                  const SizedBox(height: 24),
                  _buildSalesList(sales),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final saleRepository = ref.watch(saleRepositoryProvider);
    final productRepository = ref.watch(productRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 24),
          FutureBuilder(
            future: saleRepository.getSalesByDateRange(_startDate, _endDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final salesResult = snapshot.data;
              if (salesResult == null) {
                return const Center(child: Text('データがありません'));
              }

              final sales = salesResult.isSuccess ? (salesResult.data ?? []) : <Sale>[];
              return FutureBuilder(
                future: productRepository.getAllProducts(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final productsResult = productSnapshot.data;
                  if (productsResult == null) {
                    return const Center(child: Text('データがありません'));
                  }

                  final products = productsResult.isSuccess ? (productsResult.data ?? []) : <Product>[];
                  return _buildProductAnalysis(sales, products);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    final saleRepository = ref.watch(saleRepositoryProvider);
    final customerRepository = ref.watch(customerRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 24),
          FutureBuilder(
            future: saleRepository.getSalesByDateRange(_startDate, _endDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final salesResult = snapshot.data;
              if (salesResult == null) {
                return const Center(child: Text('データがありません'));
              }

              final sales = salesResult.isSuccess ? (salesResult.data ?? []) : <Sale>[];
              return FutureBuilder(
                future: customerRepository.getAllCustomers(),
                builder: (context, customerSnapshot) {
                  if (customerSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final customersResult = customerSnapshot.data;
                  if (customersResult == null) {
                    return const Center(child: Text('データがありません'));
                  }

                  final customers = customersResult.isSuccess ? (customersResult.data ?? []) : <Customer>[];
                  return _buildCustomerAnalysis(sales, customers);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return AppCard(
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '期間: ${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          AppButton(
            text: '期間変更',
            type: AppButtonType.outline,
            size: AppButtonSize.small,
            onPressed: () => _selectDateRange(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    final saleRepository = ref.watch(saleRepositoryProvider);

    return FutureBuilder(
      future: saleRepository.getSalesByDateRange(_startDate, _endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data;
        if (result == null) {
          return const SizedBox.shrink();
        }

        final sales = result.isSuccess ? (result.data ?? []) : <Sale>[];
        final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.finalTotal);
        final totalOrders = sales.length;
        final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;
        final days = _endDate.difference(_startDate).inDays + 1;
        final avgDailySales = days > 0 ? totalSales / days : 0.0;
        
        return Row(
          children: [
            Expanded(
              child: AppInfoCard(
                title: '総売上',
                value: currencyFormatter.format(totalSales),
                icon: Icons.payments,
                iconColor: Colors.green,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '注文数',
                value: '$totalOrders件',
                icon: Icons.receipt_long,
                iconColor: Colors.blue,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '平均注文額',
                value: currencyFormatter.format(avgOrderValue),
                icon: Icons.trending_up,
                iconColor: Colors.orange,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '日平均売上',
                value: currencyFormatter.format(avgDailySales),
                icon: Icons.today,
                iconColor: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendChart() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '売上トレンド',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'チャート表示エリア\n（実装時はChartsライブラリを使用）',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final saleRepository = ref.watch(saleRepositoryProvider);

    return FutureBuilder(
      future: saleRepository.getSalesByDateRange(_startDate, _endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final result = snapshot.data;
        if (result == null) {
          return const SizedBox.shrink();
        }

        final sales = result.isSuccess ? (result.data ?? []) : <Sale>[];
        final productSales = <String, double>{};
        final productQuantities = <String, int>{};
        
        for (final sale in sales) {
          for (final item in sale.items) {
            productSales[item.productName] =
                (productSales[item.productName] ?? 0) + item.total;
            productQuantities[item.productName] =
                (productQuantities[item.productName] ?? 0) + item.quantity;
          }
        }
        
        final sortedProducts = productSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '売上上位商品',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sortedProducts.take(5).map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('${productQuantities[entry.key]}個'),
                    const SizedBox(width: 16),
                    Text(
                      currencyFormatter.format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesStats(List<Sale> sales) {
    final hourlyStats = <int, int>{};
    final dailyStats = <String, double>{};
    
    for (final sale in sales) {
      final hour = sale.createdAt.hour;
      hourlyStats[hour] = (hourlyStats[hour] ?? 0) + 1;
      
      final day = dateFormatter.format(sale.createdAt);
      dailyStats[day] = (dailyStats[day] ?? 0) + sale.finalTotal;
    }
    
    final peakHour = hourlyStats.entries.isEmpty 
        ? 0 
        : hourlyStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final bestDay = dailyStats.entries.isEmpty 
        ? '該当なし' 
        : dailyStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    return Row(
      children: [
        Expanded(
          child: AppInfoCard(
            title: 'ピーク時間',
            value: '$peakHour時台',
            icon: Icons.schedule,
            iconColor: Colors.blue,
          ),
        ),
        Expanded(
          child: AppInfoCard(
            title: '最高売上日',
            value: bestDay,
            icon: Icons.star,
            iconColor: Colors.orange,
          ),
        ),
        Expanded(
          child: AppInfoCard(
            title: '売上期間',
            value: '${_endDate.difference(_startDate).inDays + 1}日間',
            icon: Icons.calendar_month,
            iconColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesList(List<Sale> sales) {
    if (sales.isEmpty) {
      return const Center(
        child: Text('この期間に売上データがありません'),
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
                const Expanded(child: Text('日時', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text('顧客', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text('商品数', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text('金額', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
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
                        child: Text(DateFormat('MM/dd HH:mm').format(sale.createdAt)),
                      ),
                      Expanded(
                        child: Text(sale.customerName ?? 'ゲスト'),
                      ),
                      Expanded(
                        child: Text('${sale.items.length}個'),
                      ),
                      Expanded(
                        child: Text(
                          currencyFormatter.format(sale.finalTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAnalysis(List<Sale> sales, List<Product> products) {
    final productStats = <String, Map<String, dynamic>>{};
    
    // Initialize stats for all products
    for (final product in products) {
      productStats[product.name] = {
        'quantity': 0,
        'revenue': 0.0,
        'price': product.price,
      };
    }
    
    // Calculate sales stats
    for (final sale in sales) {
      for (final item in sale.items) {
        if (productStats.containsKey(item.productName)) {
          productStats[item.productName]!['quantity'] += item.quantity;
          productStats[item.productName]!['revenue'] += item.total;
        }
      }
    }
    
    final sortedByRevenue = productStats.entries.toList()
      ..sort((a, b) => (b.value['revenue'] as double).compareTo(a.value['revenue'] as double));
    
    final sortedByQuantity = productStats.entries.toList()
      ..sort((a, b) => (b.value['quantity'] as int).compareTo(a.value['quantity'] as int));
    
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '売上金額ランキング',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sortedByRevenue.take(10).map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value['quantity']}個'),
                    const SizedBox(width: 16),
                    Text(
                      currencyFormatter.format(entry.value['revenue']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '販売数量ランキング',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sortedByQuantity.take(10).map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value['quantity']}個'),
                    const SizedBox(width: 16),
                    Text(
                      currencyFormatter.format(entry.value['revenue']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerAnalysis(List<Sale> sales, List<Customer> customers) {
    final customerStats = <String, Map<String, dynamic>>{};
    
    for (final sale in sales) {
      final customerName = sale.customerName ?? 'ゲスト';
      if (!customerStats.containsKey(customerName)) {
        customerStats[customerName] = {
          'orders': 0,
          'revenue': 0.0,
          'items': 0,
        };
      }
      
      customerStats[customerName]!['orders']++;
      customerStats[customerName]!['revenue'] += sale.finalTotal;
      customerStats[customerName]!['items'] += sale.items.fold<int>(0, (sum, item) => sum + item.quantity);
    }
    
    final sortedCustomers = customerStats.entries.toList()
      ..sort((a, b) => (b.value['revenue'] as double).compareTo(a.value['revenue'] as double));

    final registeredCustomerSales = sales.where((s) => s.customerName != null).length;
    final guestSales = sales.length - registeredCustomerSales;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppInfoCard(
                title: '会員売上',
                value: '$registeredCustomerSales件',
                icon: Icons.card_membership,
                iconColor: Colors.blue,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: 'ゲスト売上',
                value: '$guestSales件',
                icon: Icons.person,
                iconColor: Colors.grey,
              ),
            ),
            Expanded(
              child: AppInfoCard(
                title: '会員率',
                value: '${sales.isEmpty ? 0 : (registeredCustomerSales / sales.length * 100).toStringAsFixed(1)}%',
                icon: Icons.percent,
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '顧客別売上ランキング',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sortedCustomers.take(10).map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value['orders']}回'),
                    const SizedBox(width: 16),
                    Text(
                      currencyFormatter.format(entry.value['revenue']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _exportReport() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('レポートをエクスポートしました'),
      ),
    );
  }
}