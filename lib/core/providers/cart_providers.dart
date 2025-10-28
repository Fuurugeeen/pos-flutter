import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale.dart';
import '../../data/models/sale_item.dart';
import '../../data/models/product.dart';
import '../../data/models/enums.dart';

// Cart state notifier
class CartNotifier extends StateNotifier<Sale> {
  CartNotifier() : super(Sale.create(
    items: [],
    paymentMethod: PaymentMethod.cash,
  ));

  void addItem(Product product, {int quantity = 1, String? notes}) {
    final saleItem = SaleItem.fromProduct(product, quantity, notes: notes);
    state = state.addItem(saleItem);
  }

  void removeItem(String productId) {
    state = state.removeItem(productId);
  }

  void updateItemQuantity(String productId, int quantity) {
    state = state.updateItemQuantity(productId, quantity);
  }

  void setPaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(paymentMethod: paymentMethod);
  }

  void setCustomer(String? customerId, String? customerName) {
    state = state.copyWith(
      customerId: customerId,
      customerName: customerName,
    );
  }

  void applyDiscount(double discountAmount) {
    state = state.copyWith(discountAmount: discountAmount);
  }

  void useLoyaltyPoints(int points) {
    state = state.copyWith(loyaltyPointsUsed: points);
  }

  void setLoyaltyPointsEarned(int points) {
    state = state.copyWith(loyaltyPointsEarned: points);
  }

  void addNote(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void clearCart() {
    state = Sale.create(
      items: [],
      paymentMethod: PaymentMethod.cash,
    );
  }

  Sale completeSale() {
    final completedSale = state.copyWith(
      status: SaleStatus.completed,
      updatedAt: DateTime.now(),
    );
    clearCart();
    return completedSale;
  }
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, Sale>((ref) {
  return CartNotifier();
});

// Cart derived state providers
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotal;
});

final cartTotalTaxProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalTax;
});

final cartFinalTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.finalTotal;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.isEmpty;
});

// Selected payment method provider
final selectedPaymentMethodProvider = StateProvider<PaymentMethod>((ref) => PaymentMethod.cash);

// Discount amount provider
final discountAmountProvider = StateProvider<double>((ref) => 0.0);

// Loyalty points to use provider
final loyaltyPointsToUseProvider = StateProvider<int>((ref) => 0);