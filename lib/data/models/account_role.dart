enum AccountRole { shop, supplier }

String databaseRole(AccountRole role) =>
    role == AccountRole.supplier ? 'supplier' : 'customer';

AccountRole accountRoleFromDatabase(String? value) =>
    value == 'supplier' ? AccountRole.supplier : AccountRole.shop;
