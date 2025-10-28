import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // サイドナビゲーション
          const _SideNavigation(),
          // メインコンテンツ
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation();

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).location;
    
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // ロゴエリア
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.local_cafe,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Café Bloom',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // ナビゲーションメニュー
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'ダッシュボード',
                  path: '/dashboard',
                  isSelected: currentLocation == '/dashboard',
                  onTap: () => context.goToDashboard(),
                ),
                _NavItem(
                  icon: Icons.point_of_sale,
                  label: '会計',
                  path: '/pos',
                  isSelected: currentLocation == '/pos',
                  onTap: () => context.goToPos(),
                ),
                _NavItem(
                  icon: Icons.inventory_2,
                  label: '商品管理',
                  path: '/products',
                  isSelected: currentLocation.startsWith('/products'),
                  onTap: () => context.goToProducts(),
                ),
                _NavItem(
                  icon: Icons.people,
                  label: '会員管理',
                  path: '/customers',
                  isSelected: currentLocation.startsWith('/customers'),
                  onTap: () => context.goToCustomers(),
                ),
                _NavItem(
                  icon: Icons.assessment,
                  label: 'レポート',
                  path: '/reports',
                  isSelected: currentLocation == '/reports',
                  onTap: () => context.goToReports(),
                ),
                _NavItem(
                  icon: Icons.storage,
                  label: '在庫管理',
                  path: '/inventory',
                  isSelected: currentLocation == '/inventory',
                  onTap: () => context.goToInventory(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // フッターエリア
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }
}