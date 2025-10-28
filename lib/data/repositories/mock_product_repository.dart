import '../models/product.dart';
import '../models/enums.dart';
import 'product_repository.dart';

class MockProductRepository implements ProductRepository {
  final List<Product> _products = [];

  MockProductRepository() {
    _initializeSampleData();
  }

  // Getter for accessing products synchronously (for testing and initialization)
  List<Product> get products => List.from(_products);

  void _initializeSampleData() {
    _products.addAll([
      // Coffee products
      Product.create(
        name: 'ブレンドコーヒー',
        description: '当店オリジナルのブレンドコーヒー',
        price: 300.0,
        category: ProductCategory.coffee,
        stockQuantity: 50,
        lowStockThreshold: 10,
      ),
      Product.create(
        name: 'アメリカンコーヒー',
        description: 'すっきりとした味わいのアメリカンコーヒー',
        price: 280.0,
        category: ProductCategory.coffee,
        stockQuantity: 45,
        lowStockThreshold: 10,
      ),
      Product.create(
        name: 'エスプレッソ',
        description: '濃厚なエスプレッソ',
        price: 320.0,
        category: ProductCategory.coffee,
        stockQuantity: 30,
        lowStockThreshold: 8,
      ),
      Product.create(
        name: 'カフェラテ',
        description: 'クリーミーなカフェラテ',
        price: 380.0,
        category: ProductCategory.coffee,
        stockQuantity: 40,
        lowStockThreshold: 10,
      ),
      Product.create(
        name: 'カプチーノ',
        description: 'ふわふわの泡が特徴のカプチーノ',
        price: 400.0,
        category: ProductCategory.coffee,
        stockQuantity: 35,
        lowStockThreshold: 8,
      ),

      // Tea products
      Product.create(
        name: 'アールグレイ',
        description: 'ベルガモットの香りが爽やかな紅茶',
        price: 350.0,
        category: ProductCategory.tea,
        stockQuantity: 25,
        lowStockThreshold: 5,
      ),
      Product.create(
        name: 'ダージリン',
        description: '上品な香りのダージリン紅茶',
        price: 380.0,
        category: ProductCategory.tea,
        stockQuantity: 20,
        lowStockThreshold: 5,
      ),
      Product.create(
        name: 'ハーブティー',
        description: 'カモミールベースのハーブティー',
        price: 320.0,
        category: ProductCategory.tea,
        stockQuantity: 15,
        lowStockThreshold: 3,
      ),
      Product.create(
        name: 'ジャスミン茶',
        description: '香り高いジャスミン茶',
        price: 300.0,
        category: ProductCategory.tea,
        stockQuantity: 18,
        lowStockThreshold: 5,
      ),

      // Pastry products
      Product.create(
        name: 'クロワッサン',
        description: 'バターの香りが豊かなクロワッサン',
        price: 200.0,
        category: ProductCategory.pastry,
        stockQuantity: 12,
        lowStockThreshold: 3,
      ),
      Product.create(
        name: 'デニッシュ',
        description: 'フルーツがのったデニッシュ',
        price: 250.0,
        category: ProductCategory.pastry,
        stockQuantity: 8,
        lowStockThreshold: 2,
      ),
      Product.create(
        name: 'マフィン',
        description: 'ブルーベリーマフィン',
        price: 220.0,
        category: ProductCategory.pastry,
        stockQuantity: 15,
        lowStockThreshold: 4,
      ),
      Product.create(
        name: 'スコーン',
        description: 'プレーンスコーン',
        price: 180.0,
        category: ProductCategory.pastry,
        stockQuantity: 10,
        lowStockThreshold: 3,
      ),

      // Sandwich products
      Product.create(
        name: 'ハムサンド',
        description: 'ハムとレタスのサンドイッチ',
        price: 450.0,
        category: ProductCategory.sandwich,
        stockQuantity: 6,
        lowStockThreshold: 2,
      ),
      Product.create(
        name: 'BLTサンド',
        description: 'ベーコン、レタス、トマトのサンドイッチ',
        price: 520.0,
        category: ProductCategory.sandwich,
        stockQuantity: 5,
        lowStockThreshold: 2,
      ),
      Product.create(
        name: 'ツナサンド',
        description: 'ツナとマヨネーズのサンドイッチ',
        price: 400.0,
        category: ProductCategory.sandwich,
        stockQuantity: 7,
        lowStockThreshold: 2,
      ),

      // Dessert products
      Product.create(
        name: 'チーズケーキ',
        description: 'なめらかなチーズケーキ',
        price: 380.0,
        category: ProductCategory.dessert,
        stockQuantity: 4,
        lowStockThreshold: 1,
      ),
      Product.create(
        name: 'チョコレートケーキ',
        description: '濃厚なチョコレートケーキ',
        price: 420.0,
        category: ProductCategory.dessert,
        stockQuantity: 3,
        lowStockThreshold: 1,
      ),
      Product.create(
        name: 'ティラミス',
        description: 'イタリアンデザート・ティラミス',
        price: 450.0,
        category: ProductCategory.dessert,
        stockQuantity: 2,
        lowStockThreshold: 1,
      ),

      // Beverage products
      Product.create(
        name: '100%オレンジジュース',
        description: 'フレッシュオレンジジュース',
        price: 280.0,
        category: ProductCategory.beverage,
        stockQuantity: 20,
        lowStockThreshold: 5,
      ),
      Product.create(
        name: 'アップルジュース',
        description: '100%アップルジュース',
        price: 280.0,
        category: ProductCategory.beverage,
        stockQuantity: 18,
        lowStockThreshold: 5,
      ),
      Product.create(
        name: 'ミネラルウォーター',
        description: '天然水',
        price: 150.0,
        category: ProductCategory.beverage,
        stockQuantity: 30,
        lowStockThreshold: 8,
      ),
      Product.create(
        name: 'アイスティー',
        description: '冷たい紅茶',
        price: 250.0,
        category: ProductCategory.beverage,
        stockQuantity: 15,
        lowStockThreshold: 5,
      ),
    ]);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_products);
  }

  @override
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.category == category).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return _products.where((p) => 
      p.name.toLowerCase().contains(lowerQuery) ||
      p.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isActive).toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isLowStock).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _products.add(product);
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product.copyWith(updatedAt: DateTime.now());
      return _products[index];
    }
    throw Exception('Product not found');
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Product> updateStock(String id, int newQuantity) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        stockQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      return _products[index];
    }
    throw Exception('Product not found');
  }

  @override
  Future<Product> reduceStock(String id, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newQuantity = (_products[index].stockQuantity - quantity).clamp(0, double.infinity).toInt();
      _products[index] = _products[index].copyWith(
        stockQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      return _products[index];
    }
    throw Exception('Product not found');
  }

  @override
  Future<Map<ProductCategory, int>> getProductCountByCategory() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final countMap = <ProductCategory, int>{};
    
    for (final category in ProductCategory.values) {
      countMap[category] = _products.where((p) => p.category == category && p.isActive).length;
    }
    
    return countMap;
  }
}