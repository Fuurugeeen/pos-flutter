import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/product.dart';
import '../../../data/models/enums.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';
import 'package:go_router/go_router.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final String? productId;

  const ProductEditScreen({super.key, this.productId});

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  Product? _existingProduct;
  ProductCategory _selectedCategory = ProductCategory.coffee;

  bool get isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadProduct();
    } else {
      // Set default values for new product
      _lowStockThresholdController.text = '10';
      _stockQuantityController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
    _barcodeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final product = await ref
          .read(productRepositoryProvider)
          .getProductById(widget.productId!);
      
      if (product != null) {
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _descriptionController.text = product.description ?? '';
          _priceController.text = product.price.toString();
          _stockQuantityController.text = product.stockQuantity.toString();
          _lowStockThresholdController.text = product.lowStockThreshold.toString();
          _barcodeController.text = product.barcode ?? '';
          _imageUrlController.text = product.imageUrl ?? '';
          _selectedCategory = product.category;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品データの読み込みに失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '商品編集' : '新規商品追加'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteProduct(),
              tooltip: '削除',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInfoCard(),
            const SizedBox(height: 24),
            _buildPricingCard(),
            const SizedBox(height: 24),
            _buildInventoryCard(),
            const SizedBox(height: 24),
            _buildAdditionalInfoCard(),
            const SizedBox(height: 32),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEdit ? '商品情報編集' : '新規商品登録',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isEdit && _existingProduct != null) ...[
          const SizedBox(height: 8),
          Text(
            '商品ID: ${_existingProduct!.id}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本情報',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '商品名',
            controller: _nameController,
            hint: '商品名を入力してください',
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '商品名は必須です';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppDropdownField<ProductCategory>(
            label: 'カテゴリー',
            value: _selectedCategory,
            isRequired: true,
            items: ProductCategory.values.map((category) =>
              DropdownMenuItem<ProductCategory>(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              ),
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '商品説明',
            controller: _descriptionController,
            hint: '商品の詳細説明を入力してください',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '価格設定',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '販売価格',
            controller: _priceController,
            hint: '0',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money,
            isRequired: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '販売価格は必須です';
              }
              final price = double.tryParse(value);
              if (price == null || price < 0) {
                return '0以上の数値を入力してください';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '在庫管理',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppFormField(
                  label: '在庫数量',
                  controller: _stockQuantityController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '在庫数量は必須です';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 0) {
                      return '0以上の数値を入力してください';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormField(
                  label: '在庫少閾値',
                  controller: _lowStockThresholdController,
                  hint: '10',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '在庫少閾値は必須です';
                    }
                    final threshold = int.tryParse(value);
                    if (threshold == null || threshold < 0) {
                      return '0以上の数値を入力してください';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '在庫数量が閾値以下になると「在庫少」として警告表示されます',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '追加情報',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'バーコード',
            controller: _barcodeController,
            hint: 'バーコード番号（任意）',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '画像URL',
            controller: _imageUrlController,
            hint: 'https://example.com/image.jpg（任意）',
            keyboardType: TextInputType.url,
          ),
          if (_imageUrlController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'プレビュー:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrlController.text,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'キャンセル',
            type: AppButtonType.outline,
            onPressed: _isSaving ? null : () => context.pop(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: _isSaving 
                ? '保存中...' 
                : (isEdit ? '更新' : '登録'),
            icon: isEdit ? Icons.update : Icons.add_box,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveProduct,
          ),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(ProductCategory category) {
    return switch (category) {
      ProductCategory.coffee => 'コーヒー',
      ProductCategory.tea => '紅茶',
      ProductCategory.food => 'フード',
      ProductCategory.dessert => 'デザート',
      ProductCategory.other => 'その他',
    };
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final price = double.parse(_priceController.text.trim());
      final stockQuantity = int.parse(_stockQuantityController.text.trim());
      final lowStockThreshold = int.parse(_lowStockThresholdController.text.trim());
      
      if (isEdit && _existingProduct != null) {
        // Update existing product
        final updatedProduct = _existingProduct!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          price: price,
          category: _selectedCategory,
          stockQuantity: stockQuantity,
          lowStockThreshold: lowStockThreshold,
          barcode: _barcodeController.text.trim().isEmpty 
              ? null 
              : _barcodeController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
        );
        
        await ref
            .read(productRepositoryProvider)
            .updateProduct(updatedProduct);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('商品情報を更新しました'),
            ),
          );
          context.pop();
        }
      } else {
        // Create new product
        final newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          price: price,
          category: _selectedCategory,
          stockQuantity: stockQuantity,
          lowStockThreshold: lowStockThreshold,
          barcode: _barcodeController.text.trim().isEmpty 
              ? null 
              : _barcodeController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
          createdAt: DateTime.now(),
        );
        
        await ref
            .read(productRepositoryProvider)
            .createProduct(newProduct);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('新規商品を登録しました'),
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    if (!isEdit || _existingProduct == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品削除'),
        content: Text(
          '${_existingProduct!.name}を削除しますか？\n'
          'この操作は取り消せません。',
        ),
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
        await ref
            .read(productRepositoryProvider)
            .deleteProduct(_existingProduct!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_existingProduct!.name}を削除しました'),
            ),
          );
          context.pop();
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
}