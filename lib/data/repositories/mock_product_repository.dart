import '../models/product.dart';
import '../models/enums.dart';
import 'product_repository.dart';
import '../../core/error/app_error.dart';
import '../../core/utils/result.dart';
import '../../core/validation/validators.dart';

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
  Future<Result<List<Product>>> getAllProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(List.from(_products));
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '商品リストの取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(ProductCategory category) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(_products.where((p) => p.category == category).toList());
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: 'カテゴリ商品の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final product = _products.where((p) => p.id == id).firstOrNull;
      return Result.success(product);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '商品の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final lowerQuery = query.toLowerCase();
      final results = _products.where((p) => 
        p.name.toLowerCase().contains(lowerQuery) ||
        p.description.toLowerCase().contains(lowerQuery)
      ).toList();
      return Result.success(results);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '商品検索に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Product>>> getActiveProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(_products.where((p) => p.isActive).toList());
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '有効な商品の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(_products.where((p) => p.isLowStock).toList());
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '在庫不足商品の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      // バリデーション
      final nameValidation = Validators.productName().validate(product.name, '商品名');
      if (nameValidation.isFailure) {
        return Result.failure(nameValidation.error!);
      }
      
      final priceValidation = Validators.price().validate(product.price, '価格');
      if (priceValidation.isFailure) {
        return Result.failure(priceValidation.error!);
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      _products.add(product);
      return Result.success(product);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '商品の作成に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      // バリデーション
      final nameValidation = Validators.productName().validate(product.name, '商品名');
      if (nameValidation.isFailure) {
        return Result.failure(nameValidation.error!);
      }
      
      final priceValidation = Validators.price().validate(product.price, '価格');
      if (priceValidation.isFailure) {
        return Result.failure(priceValidation.error!);
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product.copyWith(updatedAt: DateTime.now());
        return Result.success(_products[index]);
      }
      return Result.failure(
        NotFoundError(message: '商品が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '商品の更新に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        return Result.success(null);
      }
      return Result.failure(
        NotFoundError(message: '商品が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '商品の削除に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> updateStock(String id, int newQuantity) async {
    try {
      // バリデーション
      final stockValidation = Validators.stockQuantity().validate(newQuantity, '在庫数');
      if (stockValidation.isFailure) {
        return Result.failure(stockValidation.error!);
      }
      
      await Future.delayed(const Duration(milliseconds: 150));
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          stockQuantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        return Result.success(_products[index]);
      }
      return Result.failure(
        NotFoundError(message: '商品が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '在庫の更新に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Product>> reduceStock(String id, int quantity) async {
    try {
      if (quantity < 0) {
        return Result.failure(
          ValidationError(
            message: '減少数量は0以上である必要があります',
            fieldErrors: {'quantity': '減少数量は0以上である必要があります'},
          ),
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 150));
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        final currentStock = _products[index].stockQuantity;
        if (currentStock < quantity) {
          return Result.failure(
            BusinessError(
              message: '在庫が不足しています。現在の在庫: $currentStock, 必要数量: $quantity',
            ),
          );
        }
        
        final newQuantity = (currentStock - quantity).clamp(0, double.infinity).toInt();
        _products[index] = _products[index].copyWith(
          stockQuantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        return Result.success(_products[index]);
      }
      return Result.failure(
        NotFoundError(message: '商品が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '在庫の減少に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Map<ProductCategory, int>>> getProductCountByCategory() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final countMap = <ProductCategory, int>{};
      
      for (final category in ProductCategory.values) {
        countMap[category] = _products.where((p) => p.category == category && p.isActive).length;
      }
      
      return Result.success(countMap);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: 'カテゴリ別商品数の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }
}