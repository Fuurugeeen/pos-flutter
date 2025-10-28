import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/customer.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';
import 'package:go_router/go_router.dart';

class CustomerEditScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const CustomerEditScreen({super.key, this.customerId});

  @override
  ConsumerState<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends ConsumerState<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _loyaltyPointsController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  Customer? _existingCustomer;

  bool get isEdit => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadCustomer();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _loyaltyPointsController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customerResult = await ref
          .read(customerRepositoryProvider)
          .getCustomerById(widget.customerId!);

      if (customerResult.isSuccess && customerResult.data != null) {
        final customer = customerResult.data!;
        setState(() {
          _existingCustomer = customer;
          _nameController.text = customer.name;
          _emailController.text = customer.email ?? '';
          _phoneController.text = customer.phone ?? '';
          _addressController.text = customer.address ?? '';
          _loyaltyPointsController.text = customer.loyaltyPoints.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('顧客データの読み込みに失敗しました: $e'),
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
        title: Text(isEdit ? '顧客編集' : '新規顧客追加'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCustomer(),
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
            _buildContactInfoCard(),
            const SizedBox(height: 24),
            _buildLoyaltyCard(),
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
          isEdit ? '顧客情報編集' : '新規顧客登録',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isEdit && _existingCustomer != null) ...[
          const SizedBox(height: 8),
          Text(
            '顧客ID: ${_existingCustomer!.id}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
            label: '氏名',
            controller: _nameController,
            hint: '顧客の氏名を入力してください',
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '氏名は必須です';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '連絡先情報',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'メールアドレス',
            controller: _emailController,
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegExp.hasMatch(value)) {
                  return '有効なメールアドレスを入力してください';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '電話番号',
            controller: _phoneController,
            hint: '03-1234-5678',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\(\)\+\s]')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final phoneRegExp = RegExp(r'^[0-9\-\(\)\+\s]+$');
                if (!phoneRegExp.hasMatch(value)) {
                  return '有効な電話番号を入力してください';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: '住所',
            controller: _addressController,
            hint: '東京都渋谷区...',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ポイント情報',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'ポイント残高',
            controller: _loyaltyPointsController,
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final points = int.tryParse(value);
                if (points == null || points < 0) {
                  return '0以上の数値を入力してください';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'ポイントは手動で調整できます。通常は購入時に自動で付与されます。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
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
            icon: isEdit ? Icons.update : Icons.person_add,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveCustomer,
          ),
        ),
      ],
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final loyaltyPoints = int.tryParse(_loyaltyPointsController.text.trim()) ?? 0;
      
      if (isEdit && _existingCustomer != null) {
        // Update existing customer
        final updatedCustomer = _existingCustomer!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty 
              ? null 
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty 
              ? null 
              : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty 
              ? null 
              : _addressController.text.trim(),
          loyaltyPoints: loyaltyPoints,
        );
        
        await ref
            .read(customerRepositoryProvider)
            .updateCustomer(updatedCustomer);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('顧客情報を更新しました'),
            ),
          );
          context.pop();
        }
      } else {
        // Create new customer
        final newCustomer = Customer.create(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          loyaltyPoints: loyaltyPoints,
        );

        await ref
            .read(customerRepositoryProvider)
            .createCustomer(newCustomer);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('新規顧客を登録しました'),
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

  Future<void> _deleteCustomer() async {
    if (!isEdit || _existingCustomer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('顧客削除'),
        content: Text(
          '${_existingCustomer!.name}さんを削除しますか？\n'
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
            .read(customerRepositoryProvider)
            .deleteCustomer(_existingCustomer!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_existingCustomer!.name}さんを削除しました'),
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