import 'package:flutter/foundation.dart';

import '../../core/constants/madad_brand.dart';
import '../../data/models/business_profile.dart';

enum AccountRole { shop, supplier }

class SessionController extends ChangeNotifier {
  bool onboardingDone = false;
  bool isLoggedIn = false;
  AccountRole role = AccountRole.shop;
  String? supplierId;
  BusinessProfile? profile;

  bool get isSupplier => role == AccountRole.supplier;

  void completeOnboarding() {
    onboardingDone = true;
    notifyListeners();
  }

  Future<void> login(
    String phone, {
    AccountRole role = AccountRole.shop,
  }) async {
    if (role == AccountRole.supplier) {
      this.role = AccountRole.supplier;
      supplierId = MadadBrand.demoSupplierId;
      profile = BusinessProfile(
        businessName: 'واحة الغذاء للجملة',
        ownerName: 'مسؤول التوريد',
        phone: phone,
        city: 'الرياض',
        addresses: const ['المستودع، حي السلي، الرياض'],
      );
    } else {
      this.role = AccountRole.shop;
      supplierId = null;
      profile = BusinessProfile(
        businessName: 'بقالة النور',
        ownerName: 'خالد العمري',
        phone: phone,
        city: 'الرياض',
        addresses: const ['حي النسيم، شارع الأمير بندر، الرياض'],
      );
    }
    isLoggedIn = true;
    notifyListeners();
  }

  Future<bool> restore() async => false;

  Future<void> logout() async {
    isLoggedIn = false;
    role = AccountRole.shop;
    supplierId = null;
    profile = null;
    notifyListeners();
  }
}
