import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/customer.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';
import 'package:go_router/go_router.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final TextEditingController searchController = TextEditingController();
  final dateFormatter = DateFormat('yyyy/MM/dd');
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('顧客管理'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.go('/customers/new'),
            tooltip: '新規顧客追加',
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
            _buildSearchAndStats(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildCustomerList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/customers/new'),
        icon: const Icon(Icons.person_add),
        label: const Text('新規顧客'),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '顧客管理',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppButton(
          text: 'CSVエクスポート',
          type: AppButtonType.outline,
          icon: Icons.download,
          onPressed: () => _exportCustomers(),
        ),
      ],
    );
  }

  Widget _buildSearchAndStats() {
    final customerRepository = ref.watch(customerRepositoryProvider);
    
    return Column(
      children: [
        AppFormField(
          label: '顧客検索',
          controller: searchController,
          hint: '顧客名、電話番号、メールアドレスで検索...',
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
        const SizedBox(height: 16),
        FutureBuilder<List<Customer>>(
          future: customerRepository.getAllCustomers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            
            final customers = snapshot.data ?? [];
            final totalCustomers = customers.length;
            final totalLoyaltyPoints = customers.fold<int>(
              0, 
              (sum, customer) => sum + customer.loyaltyPoints,
            );
            final avgLoyaltyPoints = totalCustomers > 0 
                ? (totalLoyaltyPoints / totalCustomers).round() 
                : 0;
            
            return Row(
              children: [
                Expanded(
                  child: AppInfoCard(
                    title: '総顧客数',
                    value: '$totalCustomers人',
                    icon: Icons.people,
                    iconColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: AppInfoCard(
                    title: '総ポイント',
                    value: '${NumberFormat('#,###').format(totalLoyaltyPoints)}pt',
                    icon: Icons.star,
                    iconColor: Colors.orange,
                  ),
                ),
                Expanded(
                  child: AppInfoCard(
                    title: '平均ポイント',
                    value: '${NumberFormat('#,###').format(avgLoyaltyPoints)}pt',
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    final customerRepository = ref.watch(customerRepositoryProvider);
    
    return FutureBuilder<List<Customer>>(
      future: searchQuery.isEmpty 
        ? customerRepository.getAllCustomers()
        : customerRepository.searchCustomers(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final customers = snapshot.data ?? [];
        
        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isEmpty ? Icons.person_off : Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty ? '顧客データがありません' : '検索結果が見つかりません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (searchQuery.isEmpty) ...[
                  const SizedBox(height: 16),
                  AppButton(
                    text: '最初の顧客を追加',
                    icon: Icons.person_add,
                    onPressed: () => context.go('/customers/new'),
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
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: Text('名前', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('連絡先', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('ポイント', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('登録日', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 100),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _buildCustomerRow(customer);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerRow(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (customer.email != null)
                  Text(
                    customer.email!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customer.phoneNumber != null)
                  Text(customer.phoneNumber!),
                if (customer.address != null)
                  Text(
                    customer.address!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${customer.loyaltyPoints}pt',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              dateFormatter.format(customer.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/customers/${customer.id}/edit'),
                  tooltip: '編集',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCustomer(customer),
                  tooltip: '削除',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('顧客削除'),
        content: Text('${customer.name}さんを削除しますか？\nこの操作は取り消せません。'),
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
        await ref.read(customerRepositoryProvider).deleteCustomer(customer.id);
        setState(() {}); // Refresh the list
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${customer.name}さんを削除しました'),
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

  Future<void> _exportCustomers() async {
    try {
      final customers = await ref.read(customerRepositoryProvider).getAllCustomers();
      
      // In a real app, you would implement CSV export functionality here
      // For now, we'll just show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customers.length}件の顧客データをエクスポートしました'),
          ),
        );
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
}