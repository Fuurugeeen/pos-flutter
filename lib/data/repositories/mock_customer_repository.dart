import '../models/customer.dart';
import 'customer_repository.dart';

class MockCustomerRepository implements CustomerRepository {
  final List<Customer> _customers = [];

  MockCustomerRepository() {
    _initializeSampleData();
  }

  // Getter for accessing customers synchronously (for testing and initialization)
  List<Customer> get customers => List.from(_customers);

  void _initializeSampleData() {
    _customers.addAll([
      Customer.create(
        name: '田中 太郎',
        email: 'tanaka@example.com',
        phone: '090-1234-5678',
        address: '東京都渋谷区神宮前1-1-1',
        loyaltyPoints: 150,
        dateOfBirth: DateTime(1985, 3, 15),
      ),
      Customer.create(
        name: '佐藤 花子',
        email: 'sato@example.com',
        phone: '090-2345-6789',
        address: '大阪府大阪市中央区1-2-3',
        loyaltyPoints: 230,
        dateOfBirth: DateTime(1992, 7, 22),
      ),
      Customer.create(
        name: '鈴木 一郎',
        email: 'suzuki@example.com',
        phone: '090-3456-7890',
        address: '神奈川県横浜市西区4-5-6',
        loyaltyPoints: 85,
        dateOfBirth: DateTime(1978, 11, 8),
      ),
      Customer.create(
        name: '高橋 美咲',
        email: 'takahashi@example.com',
        phone: '090-4567-8901',
        address: '愛知県名古屋市中区7-8-9',
        loyaltyPoints: 320,
        dateOfBirth: DateTime(1995, 5, 30),
      ),
      Customer.create(
        name: '伊藤 健太',
        email: 'ito@example.com',
        phone: '090-5678-9012',
        address: '福岡県福岡市博多区10-11-12',
        loyaltyPoints: 45,
        dateOfBirth: DateTime(1988, 9, 14),
      ),
      Customer.create(
        name: '渡辺 さくら',
        email: 'watanabe@example.com',
        phone: '090-6789-0123',
        address: '北海道札幌市中央区13-14-15',
        loyaltyPoints: 180,
        dateOfBirth: DateTime(1991, 4, 3),
      ),
      Customer.create(
        name: '山本 大輔',
        email: 'yamamoto@example.com',
        phone: '090-7890-1234',
        address: '京都府京都市下京区16-17-18',
        loyaltyPoints: 95,
        dateOfBirth: DateTime(1983, 12, 25),
      ),
      Customer.create(
        name: '中村 あゆみ',
        email: 'nakamura@example.com',
        phone: '090-8901-2345',
        address: '兵庫県神戸市中央区19-20-21',
        loyaltyPoints: 275,
        dateOfBirth: DateTime(1987, 6, 18),
      ),
      Customer.create(
        name: '小林 正人',
        email: 'kobayashi@example.com',
        phone: '090-9012-3456',
        address: '埼玉県さいたま市大宮区22-23-24',
        loyaltyPoints: 120,
        dateOfBirth: DateTime(1976, 8, 7),
      ),
      Customer.create(
        name: '加藤 美穂',
        email: 'kato@example.com',
        phone: '090-0123-4567',
        address: '千葉県千葉市中央区25-26-27',
        loyaltyPoints: 65,
        dateOfBirth: DateTime(1994, 10, 12),
      ),
      Customer.create(
        name: '吉田 拓也',
        email: 'yoshida@example.com',
        phone: '080-1234-5678',
        address: '宮城県仙台市青葉区28-29-30',
        loyaltyPoints: 200,
        dateOfBirth: DateTime(1989, 1, 9),
      ),
      Customer.create(
        name: '森 智子',
        email: 'mori@example.com',
        phone: '080-2345-6789',
        address: '広島県広島市中区31-32-33',
        loyaltyPoints: 340,
        dateOfBirth: DateTime(1982, 3, 27),
      ),
      Customer.create(
        name: '清水 健一',
        email: 'shimizu@example.com',
        phone: '080-3456-7890',
        address: '静岡県静岡市駿河区34-35-36',
        loyaltyPoints: 15,
        dateOfBirth: DateTime(1993, 7, 6),
      ),
      Customer.create(
        name: '三浦 理恵',
        email: 'miura@example.com',
        phone: '080-4567-8901',
        address: '茨城県水戸市37-38-39',
        loyaltyPoints: 155,
        dateOfBirth: DateTime(1986, 11, 21),
      ),
      Customer.create(
        name: '橋本 和也',
        email: 'hashimoto@example.com',
        phone: '080-5678-9012',
        address: '群馬県前橋市40-41-42',
        loyaltyPoints: 285,
        dateOfBirth: DateTime(1979, 5, 16),
      ),
      Customer.create(
        name: '藤田 まりな',
        email: 'fujita@example.com',
        phone: '080-6789-0123',
        address: '栃木県宇都宮市43-44-45',
        loyaltyPoints: 75,
        dateOfBirth: DateTime(1990, 2, 4),
      ),
      Customer.create(
        name: '岡田 慎太郎',
        email: 'okada@example.com',
        phone: '080-7890-1234',
        address: '岡山県岡山市北区46-47-48',
        loyaltyPoints: 110,
        dateOfBirth: DateTime(1984, 8, 13),
      ),
      Customer.create(
        name: '松本 ゆかり',
        email: 'matsumoto@example.com',
        phone: '080-8901-2345',
        address: '長野県長野市49-50-51',
        loyaltyPoints: 395,
        dateOfBirth: DateTime(1977, 12, 2),
      ),
      Customer.create(
        name: '前田 俊介',
        email: 'maeda@example.com',
        phone: '080-9012-3456',
        address: '石川県金沢市52-53-54',
        loyaltyPoints: 25,
        dateOfBirth: DateTime(1996, 4, 19),
      ),
      Customer.create(
        name: '坂本 奈々',
        email: 'sakamoto@example.com',
        phone: '080-0123-4567',
        address: '熊本県熊本市中央区55-56-57',
        loyaltyPoints: 165,
        dateOfBirth: DateTime(1981, 6, 11),
      ),
    ]);
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_customers);
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return _customers.where((c) => 
      c.name.toLowerCase().contains(lowerQuery) ||
      (c.email?.toLowerCase().contains(lowerQuery) ?? false) ||
      (c.phone?.contains(query) ?? false)
    ).toList();
  }

  @override
  Future<List<Customer>> getCustomersWithPoints(int minPoints) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _customers.where((c) => c.loyaltyPoints >= minPoints).toList();
  }

  @override
  Future<List<Customer>> getActiveCustomers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _customers.where((c) => c.isActive).toList();
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _customers.add(customer);
    return customer;
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer.copyWith(updatedAt: DateTime.now());
      return _customers[index];
    }
    throw Exception('Customer not found');
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      _customers[index] = _customers[index].copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Customer> addLoyaltyPoints(String customerId, int points) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      _customers[index] = _customers[index].addPoints(points);
      return _customers[index];
    }
    throw Exception('Customer not found');
  }

  @override
  Future<Customer> subtractLoyaltyPoints(String customerId, int points) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      _customers[index] = _customers[index].subtractPoints(points);
      return _customers[index];
    }
    throw Exception('Customer not found');
  }

  @override
  Future<Customer?> getCustomerByPhone(String phone) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _customers.firstWhere((c) => c.phone == phone);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Customer?> getCustomerByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _customers.firstWhere((c) => c.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getTotalCustomerCount() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _customers.where((c) => c.isActive).length;
  }

  @override
  Future<List<Customer>> getBirthdayCustomers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return _customers.where((c) => 
      c.dateOfBirth?.month == now.month &&
      c.isActive
    ).toList();
  }
}