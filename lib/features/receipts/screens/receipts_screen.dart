import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/enums.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../widgets/receipt_detail_modal.dart';

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
  final dateFormatter = DateFormat('yyyy/MM/dd HH:mm');

  DateTime? startDate;
  DateTime? endDate;
  SaleStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('伝票参照'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildSalesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return AppCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '絞り込み',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateRangeSelector(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusFilter(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'クリア',
                type: AppButtonType.outline,
                size: AppButtonSize.small,
                onPressed: _clearFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '期間',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  startDate != null
                    ? DateFormat('yyyy/MM/dd').format(startDate!)
                    : '開始日',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: () => _selectDate(isStart: true),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('〜'),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  endDate != null
                    ? DateFormat('yyyy/MM/dd').format(endDate!)
                    : '終了日',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: () => _selectDate(isStart: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ステータス',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SaleStatus?>(
          value: statusFilter,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem<SaleStatus?>(
              value: null,
              child: Text('すべて'),
            ),
            ...SaleStatus.values.map((status) => DropdownMenuItem(
              value: status,
              child: Text(_getStatusLabel(status)),
            )),
          ],
          onChanged: (value) {
            setState(() {
              statusFilter = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSalesList() {
    final saleRepository = ref.watch(saleRepositoryProvider);

    return FutureBuilder(
      future: _fetchFilteredSales(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final salesResult = snapshot.data;
        if (salesResult == null || !salesResult.isSuccess) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '伝票の読み込みに失敗しました',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final sales = salesResult.data ?? [];

        if (sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  '伝票が見つかりません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return _buildSaleCard(sale);
          },
        );
      },
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showReceiptDetail(sale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No. ${sale.id.substring(0, 8)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusChip(sale.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                dateFormatter.format(sale.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 16),
              if (sale.customerName != null) ...[
                Icon(
                  Icons.person,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  sale.customerName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'ゲスト',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sale.totalItems}点',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                currencyFormatter.format(sale.finalTotal),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                sale.paymentMethod.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SaleStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case SaleStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case SaleStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case SaleStatus.cancelled:
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      case SaleStatus.refunded:
        color = Colors.red;
        icon = Icons.refresh;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(SaleStatus status) {
    switch (status) {
      case SaleStatus.pending:
        return '保留中';
      case SaleStatus.completed:
        return '完了';
      case SaleStatus.cancelled:
        return 'キャンセル';
      case SaleStatus.refunded:
        return '返金済み';
    }
  }

  Future<dynamic> _fetchFilteredSales() async {
    final saleRepository = ref.read(saleRepositoryProvider);

    if (startDate != null && endDate != null) {
      return saleRepository.getSalesByDateRange(startDate!, endDate!);
    }

    if (statusFilter != null) {
      return saleRepository.getSalesByStatus(statusFilter!);
    }

    return saleRepository.getAllSales();
  }

  void _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        } else {
          endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      statusFilter = null;
    });
  }

  void _showReceiptDetail(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => ReceiptDetailModal(sale: sale),
    );
  }
}
