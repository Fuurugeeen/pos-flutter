import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pos/screens/pos_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/products/screens/product_edit_screen.dart';
import '../../features/members/screens/customer_list_screen.dart';
import '../../features/members/screens/customer_edit_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../layout/main_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/pos',
            name: 'pos',
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'product-add',
                builder: (context, state) => const ProductEditScreen(),
              ),
              GoRoute(
                path: '/edit/:id',
                name: 'product-edit',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return ProductEditScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            name: 'customers',
            builder: (context, state) => const CustomerListScreen(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'customer-add',
                builder: (context, state) => const CustomerEditScreen(),
              ),
              GoRoute(
                path: '/edit/:id',
                name: 'customer-edit',
                builder: (context, state) {
                  final customerId = state.pathParameters['id']!;
                  return CustomerEditScreen(customerId: customerId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'ページが見つかりません',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'パス: ${state.location}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('ダッシュボードに戻る'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Navigation helper extensions
extension AppRouterExtension on BuildContext {
  void goToDashboard() => go('/dashboard');
  void goToPos() => go('/pos');
  void goToProducts() => go('/products');
  void goToCustomers() => go('/customers');
  void goToReports() => go('/reports');
  void goToInventory() => go('/inventory');
  
  void goToProductAdd() => go('/products/add');
  void goToProductEdit(String productId) => go('/products/edit/$productId');
  void goToCustomerAdd() => go('/customers/add');
  void goToCustomerEdit(String customerId) => go('/customers/edit/$customerId');
}