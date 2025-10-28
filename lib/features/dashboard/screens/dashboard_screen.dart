import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/sale.dart';
import '../../../core/utils/result.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime selectedDate = DateTime.now();
  final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
  final dateFormatter = DateFormat('yyyy年MM月dd日', 'ja_JP');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダッシュボード'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: '更新',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildTodaysStats(),
            const SizedBox(height: 24),
            _buildRecentSales(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Café Bloom POS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dateFormatter.format(selectedDate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () => _selectDate(),
          icon: const Icon(Icons.calendar_today),
          label: const Text('日付選択'),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クイックアクション',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'POS レジ',
                icon: Icons.point_of_sale,
                onPressed: () => context.go('/pos'),
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: '商品管理',
                type: AppButtonType.outline,
                icon: Icons.inventory_2,
                onPressed: () => context.go('/products'),
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: '顧客管理',
                type: AppButtonType.outline,
                icon: Icons.people,
                onPressed: () => context.go('/customers'),
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaysStats() {
    final saleRepository = ref.watch(saleRepositoryProvider);
    
    return FutureBuilder<Result<List<Sale>>>(
      future: saleRepository.getSalesByDateRange(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final salesResult = snapshot.data;
        if (salesResult == null || !salesResult.isSuccess) {
          return const Center(child: Text('データの取得に失敗しました'));
        }
        final sales = salesResult.data!;
        final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.finalTotal);
        final totalOrders = sales.length;
        final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本日の売上',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
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
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSales() {
    final saleRepository = ref.watch(saleRepositoryProvider);
    
    return FutureBuilder<Result<List<Sale>>>(
      future: saleRepository.getTodaysSales(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final salesResult = snapshot.data;
        if (salesResult == null || !salesResult.isSuccess) {
          return const Center(child: Text('データの取得に失敗しました'));
        }
        final sales = salesResult.data!.take(10).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近の売上',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/reports'),
                  child: const Text('すべて見る'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
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
                        const Expanded(child: Text('時間', style: TextStyle(fontWeight: FontWeight.bold))),
                        const Expanded(child: Text('顧客', style: TextStyle(fontWeight: FontWeight.bold))),
                        const Expanded(child: Text('金額', style: TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  ...sales.map((sale) => _buildSaleRow(sale)),
                  if (sales.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('売上データがありません'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaleRow(Sale sale) {
    final timeFormatter = DateFormat('HH:mm');
    
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
            child: Text(timeFormatter.format(sale.createdAt)),
          ),
          Expanded(
            child: Text(sale.customerName ?? 'ゲスト'),
          ),
          Expanded(
            child: Text(
              currencyFormatter.format(sale.finalTotal),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => _showSaleDetails(sale),
            tooltip: '詳細を見る',
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void _showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('売上詳細 #${sale.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('日時: ${DateFormat('yyyy/MM/dd HH:mm').format(sale.createdAt)}'),
            Text('顧客: ${sale.customerName ?? 'ゲスト'}'),
            Text('商品数: ${sale.items.length}個'),
            Text('小計: ${currencyFormatter.format(sale.subtotal)}'),
            Text('税額: ${currencyFormatter.format(sale.totalTax)}'),
            Text('合計: ${currencyFormatter.format(sale.finalTotal)}'),
            const SizedBox(height: 16),
            const Text('商品明細:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...sale.items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('${item.productName} x ${item.quantity} = ${currencyFormatter.format(item.total)}'),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}