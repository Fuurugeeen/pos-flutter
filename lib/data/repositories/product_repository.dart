import '../models/product.dart';
import '../models/enums.dart';

abstract class ProductRepository {
  /// Get all products
  Future<List<Product>> getAllProducts();
  
  /// Get products by category
  Future<List<Product>> getProductsByCategory(ProductCategory category);
  
  /// Get product by ID
  Future<Product?> getProductById(String id);
  
  /// Search products by name or description
  Future<List<Product>> searchProducts(String query);
  
  /// Get active products only
  Future<List<Product>> getActiveProducts();
  
  /// Get low stock products
  Future<List<Product>> getLowStockProducts();
  
  /// Create a new product
  Future<Product> createProduct(Product product);
  
  /// Update an existing product
  Future<Product> updateProduct(Product product);
  
  /// Delete a product (soft delete - mark as inactive)
  Future<void> deleteProduct(String id);
  
  /// Update product stock quantity
  Future<Product> updateStock(String id, int newQuantity);
  
  /// Reduce stock quantity (e.g., after sale)
  Future<Product> reduceStock(String id, int quantity);
  
  /// Get products count by category
  Future<Map<ProductCategory, int>> getProductCountByCategory();
}