import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_form_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Store settings
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _taxRateController = TextEditingController();
  
  // System settings
  bool _enableNotifications = true;
  bool _enableAutoBackup = false;
  bool _enableLoyaltyProgram = true;
  String _selectedLanguage = 'ja';
  String _selectedCurrency = 'JPY';
  
  // Receipt settings
  final _receiptHeaderController = TextEditingController();
  final _receiptFooterController = TextEditingController();
  bool _printReceipts = true;
  bool _emailReceipts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    _taxRateController.dispose();
    _receiptHeaderController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final storage = await SharedPreferencesStorage.getInstance();
    
    _storeNameController.text = await storage.getString('store_name') ?? 'Café Bloom';
    _storeAddressController.text = await storage.getString('store_address') ?? '東京都渋谷区...';
    _storePhoneController.text = await storage.getString('store_phone') ?? '03-1234-5678';
    _taxRateController.text = (await storage.getDouble('tax_rate') ?? 0.1).toString();
    
    _enableNotifications = await storage.getBool('enable_notifications') ?? true;
    _enableAutoBackup = await storage.getBool('enable_auto_backup') ?? false;
    _enableLoyaltyProgram = await storage.getBool('enable_loyalty_program') ?? true;
    _selectedLanguage = await storage.getString('language') ?? 'ja';
    _selectedCurrency = await storage.getString('currency') ?? 'JPY';
    
    _receiptHeaderController.text = await storage.getString('receipt_header') ?? 'いらっしゃいませ';
    _receiptFooterController.text = await storage.getString('receipt_footer') ?? 'ありがとうございました';
    _printReceipts = await storage.getBool('print_receipts') ?? true;
    _emailReceipts = await storage.getBool('email_receipts') ?? false;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '設定を保存',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: '店舗'),
            Tab(icon: Icon(Icons.settings), text: 'システム'),
            Tab(icon: Icon(Icons.receipt), text: 'レシート'),
            Tab(icon: Icon(Icons.info), text: 'その他'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoreTab(),
          _buildSystemTab(),
          _buildReceiptTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildStoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '店舗情報',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
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
                  label: '店舗名',
                  controller: _storeNameController,
                  hint: '店舗名を入力してください',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: '住所',
                  controller: _storeAddressController,
                  hint: '店舗住所を入力してください',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: '電話番号',
                  controller: _storePhoneController,
                  hint: '03-1234-5678',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: '消費税率',
                  controller: _taxRateController,
                  hint: '0.1',
                  keyboardType: TextInputType.number,
                  suffixIcon: const Icon(Icons.percent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '営業情報',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('営業時間'),
                  subtitle: const Text('9:00 - 21:00'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBusinessHoursDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('定休日'),
                  subtitle: const Text('年中無休'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClosedDaysDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'システム設定',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '通知設定',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('通知を有効にする'),
                  subtitle: const Text('在庫切れや売上目標の通知'),
                  value: _enableNotifications,
                  onChanged: (value) {
                    setState(() {
                      _enableNotifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('自動バックアップ'),
                  subtitle: const Text('データの自動バックアップ'),
                  value: _enableAutoBackup,
                  onChanged: (value) {
                    setState(() {
                      _enableAutoBackup = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('ポイントプログラム'),
                  subtitle: const Text('顧客ポイントシステム'),
                  value: _enableLoyaltyProgram,
                  onChanged: (value) {
                    setState(() {
                      _enableLoyaltyProgram = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '地域設定',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppDropdownField<String>(
                  label: '言語',
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'ja', child: Text('日本語')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppDropdownField<String>(
                  label: '通貨',
                  value: _selectedCurrency,
                  items: const [
                    DropdownMenuItem(value: 'JPY', child: Text('日本円 (¥)')),
                    DropdownMenuItem(value: 'USD', child: Text('US Dollar (\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'データ管理',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('データバックアップ'),
                  subtitle: const Text('データを手動でバックアップ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBackupDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('データ復元'),
                  subtitle: const Text('バックアップからデータを復元'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRestoreDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('データ初期化', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('全データを削除して初期状態に戻す'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showResetDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'レシート設定',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'レシート内容',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'ヘッダーメッセージ',
                  controller: _receiptHeaderController,
                  hint: 'いらっしゃいませ',
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'フッターメッセージ',
                  controller: _receiptFooterController,
                  hint: 'ありがとうございました',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '出力設定',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('レシート印刷'),
                  subtitle: const Text('会計時にレシートを印刷'),
                  value: _printReceipts,
                  onChanged: (value) {
                    setState(() {
                      _printReceipts = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('メールレシート'),
                  subtitle: const Text('顧客にレシートをメール送信'),
                  value: _emailReceipts,
                  onChanged: (value) {
                    setState(() {
                      _emailReceipts = value;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('プリンター設定'),
                  subtitle: const Text('レシートプリンターの設定'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrinterDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'プレビュー',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'レシートプレビュー',
                  icon: Icons.preview,
                  isFullWidth: true,
                  onPressed: () => _showReceiptPreview(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'アプリ情報',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE8B4B8),
                  child: Icon(
                    Icons.local_cafe,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Café Bloom POS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'バージョン 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'カフェ向けPOSシステム\nFlutter製のクロスプラットフォーム対応',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'サポート',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('ヘルプ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHelpDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: const Text('フィードバック'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFeedbackDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('プライバシーポリシー'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.gavel),
                  title: const Text('利用規約'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTermsDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      final storage = await SharedPreferencesStorage.getInstance();
      
      await storage.saveString('store_name', _storeNameController.text);
      await storage.saveString('store_address', _storeAddressController.text);
      await storage.saveString('store_phone', _storePhoneController.text);
      await storage.saveDouble('tax_rate', double.tryParse(_taxRateController.text) ?? 0.1);
      
      await storage.saveBool('enable_notifications', _enableNotifications);
      await storage.saveBool('enable_auto_backup', _enableAutoBackup);
      await storage.saveBool('enable_loyalty_program', _enableLoyaltyProgram);
      await storage.saveString('language', _selectedLanguage);
      await storage.saveString('currency', _selectedCurrency);
      
      await storage.saveString('receipt_header', _receiptHeaderController.text);
      await storage.saveString('receipt_footer', _receiptFooterController.text);
      await storage.saveBool('print_receipts', _printReceipts);
      await storage.saveBool('email_receipts', _emailReceipts);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定を保存しました'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定の保存に失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showBusinessHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('営業時間設定'),
        content: const Text('営業時間設定機能は準備中です'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClosedDaysDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('定休日設定'),
        content: const Text('定休日設定機能は準備中です'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データバックアップ'),
        content: const Text('データをバックアップしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: 'バックアップ',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('バックアップが完了しました')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ復元'),
        content: const Text('バックアップからデータを復元しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: '復元',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データ復元が完了しました')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ初期化'),
        content: const Text('全てのデータが削除されます。この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: '初期化',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データ初期化が完了しました')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPrinterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プリンター設定'),
        content: const Text('プリンター設定機能は準備中です'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReceiptPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レシートプレビュー'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _storeNameController.text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(_storeAddressController.text),
              Text(_storePhoneController.text),
              const Divider(),
              Text(_receiptHeaderController.text),
              const SizedBox(height: 16),
              const Text('ブレンドコーヒー     ¥380\n×1'),
              const Divider(),
              const Text('小計: ¥380\n税額: ¥38\n合計: ¥418'),
              const SizedBox(height: 16),
              Text(_receiptFooterController.text),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ヘルプ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('基本操作:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• ダッシュボード: 売上状況を確認'),
              Text('• POS: 商品販売と会計処理'),
              Text('• 商品管理: 商品の登録・編集'),
              Text('• 顧客管理: 会員情報の管理'),
              Text('• レポート: 売上分析'),
              Text('• 在庫管理: 在庫の確認・調整'),
              SizedBox(height: 16),
              Text('お困りの際は:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('support@cafebloom.com までご連絡ください'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フィードバック'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('アプリの改善にご協力ください'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'ご意見・ご要望',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          AppButton(
            text: '送信',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('フィードバックを送信しました')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プライバシーポリシー'),
        content: const SingleChildScrollView(
          child: Text(
            'プライバシーポリシー\n\n'
            '当アプリケーションは、お客様のプライバシーを尊重し、個人情報の適切な保護に努めます。\n\n'
            '収集する情報:\n'
            '• 店舗運営に必要な顧客情報\n'
            '• 商品・売上データ\n'
            '• アプリ使用状況\n\n'
            '情報の利用目的:\n'
            '• サービスの提供・改善\n'
            '• 顧客サポート\n'
            '• 統計分析\n\n'
            '第三者への提供:\n'
            '法令に基づく場合を除き、お客様の同意なく第三者に個人情報を提供することはありません。'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('利用規約'),
        content: const SingleChildScrollView(
          child: Text(
            '利用規約\n\n'
            '第1条（適用）\n'
            '本規約は、当アプリケーション「Café Bloom POS」の利用に関する条件を定めるものです。\n\n'
            '第2条（利用条件）\n'
            '利用者は、本規約に同意した上でサービスを利用するものとします。\n\n'
            '第3条（禁止事項）\n'
            '• 不正アクセス\n'
            '• 他者への迷惑行為\n'
            '• 法令違反行為\n\n'
            '第4条（免責事項）\n'
            '当社は、サービスの利用により生じた損害について、一切の責任を負いません。\n\n'
            '第5条（規約の変更）\n'
            '当社は、必要に応じて本規約を変更できるものとします。'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}