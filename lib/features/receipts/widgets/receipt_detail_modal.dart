import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/enums.dart';
import '../../../shared/components/app_button.dart';

class ReceiptDetailModal extends StatelessWidget {
  final Sale sale;

  const ReceiptDetailModal({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
    final dateFormatter = DateFormat('yyyy年MM月dd日 HH:mm:ss');

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'レシート詳細',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Receipt body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildReceiptContent(
                      context,
                      currencyFormatter,
                      dateFormatter,
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: '印刷',
                    icon: Icons.print,
                    type: AppButtonType.outline,
                    size: AppButtonSize.small,
                    onPressed: () => _printReceipt(context),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: '閉じる',
                    size: AppButtonSize.small,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptContent(
    BuildContext context,
    NumberFormat currencyFormatter,
    DateFormat dateFormatter,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Store name
          Text(
            'Café Bloom',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'レシート',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Receipt info
          _buildInfoRow(context, '伝票番号', sale.id),
          _buildInfoRow(context, '日時', dateFormatter.format(sale.createdAt)),
          _buildInfoRow(
            context,
            'お客様',
            sale.customerName ?? 'ゲスト',
          ),
          _buildInfoRow(context, '決済方法', sale.paymentMethod.displayName),
          _buildStatusInfoRow(context, 'ステータス', sale.status),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Items
          ...sale.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      currencyFormatter.format(item.subtotal),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '  ${currencyFormatter.format(item.unitPrice)} × ${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '税 ${currencyFormatter.format(item.taxAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Summary
          _buildSummaryRow(
            context,
            '小計',
            currencyFormatter.format(sale.subtotal),
          ),
          _buildSummaryRow(
            context,
            '消費税',
            currencyFormatter.format(sale.totalTax),
          ),
          if (sale.discountAmount > 0)
            _buildSummaryRow(
              context,
              '割引',
              '-${currencyFormatter.format(sale.discountAmount)}',
              isDiscount: true,
            ),
          if (sale.loyaltyPointsUsed > 0)
            _buildSummaryRow(
              context,
              'ポイント使用',
              '-${currencyFormatter.format(sale.loyaltyPointsUsed)}',
              isDiscount: true,
            ),

          const SizedBox(height: 12),
          const Divider(thickness: 2),
          const SizedBox(height: 12),

          // Total
          _buildTotalRow(
            context,
            '合計',
            currencyFormatter.format(sale.finalTotal),
          ),

          if (sale.loyaltyPointsEarned > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '獲得ポイント: ${sale.loyaltyPointsEarned}pt',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          Text(
            'ご来店ありがとうございました',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'またのお越しをお待ちしております',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfoRow(BuildContext context, String label, SaleStatus status) {
    Color color;
    String statusText;

    switch (status) {
      case SaleStatus.pending:
        color = Colors.orange;
        statusText = '保留中';
        break;
      case SaleStatus.completed:
        color = Colors.green;
        statusText = '完了';
        break;
      case SaleStatus.cancelled:
        color = Colors.grey;
        statusText = 'キャンセル';
        break;
      case SaleStatus.refunded:
        color = Colors.red;
        statusText = '返金済み';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDiscount ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _printReceipt(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('印刷機能は今後実装予定です'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
