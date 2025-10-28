import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/customer.dart';

// Current selected customer provider
final selectedCustomerProvider = StateProvider<Customer?>((ref) => null);

// Loading state providers
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Error state provider
final errorProvider = StateProvider<String?>((ref) => null);

// Success message provider
final successMessageProvider = StateProvider<String?>((ref) => null);

// App theme mode provider
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Current page provider for navigation
final currentPageProvider = StateProvider<int>((ref) => 0);

// Navigation history for breadcrumbs
final navigationHistoryProvider = StateProvider<List<String>>((ref) => ['ダッシュボード']);