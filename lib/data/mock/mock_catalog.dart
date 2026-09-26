import '../models/category.dart';
import '../models/product.dart';
import '../models/supplier.dart';

abstract final class MockCatalog {
  static const categories = <Category>[
    Category(id: 'c1', name: 'أغذية ومشروبات', icon: CategoryIcon.food),
    Category(id: 'c2', name: 'مستلزمات المتاجر', icon: CategoryIcon.store),
    Category(id: 'c3', name: 'عناية ونظافة', icon: CategoryIcon.care),
    Category(id: 'c4', name: 'أدوات منزلية', icon: CategoryIcon.home),
    Category(id: 'c5', name: 'إلكترونيات', icon: CategoryIcon.electronics),
    Category(id: 'c6', name: 'قرطاسية', icon: CategoryIcon.stationery),
  ];

  static const suppliers = <Supplier>[
    Supplier(
      id: 's1',
      name: 'واحة الغذاء للجملة',
      city: 'الرياض',
      categoryIds: ['c1'],
      rating: 4.8,
      verified: true,
      about:
          'توريد أغذية جافة ومشروبات للمتاجر منذ عام 2012، مع التزام بمواعيد التسليم.',
    ),
    Supplier(
      id: 's2',
      name: 'صفاء للجملة',
      city: 'جدة',
      categoryIds: ['c2', 'c3'],
      rating: 4.6,
      verified: true,
      about:
          'مستلزمات تشغيل المتاجر ومنتجات العناية والنظافة بأسعار جملة واضحة.',
    ),
    Supplier(
      id: 's3',
      name: 'بيت الجملة',
      city: 'الدمام',
      categoryIds: ['c4', 'c5', 'c6'],
      rating: 4.5,
      verified: true,
      about:
          'أدوات منزلية وإلكترونيات وقرطاسية جاهزة للتوريد إلى المتاجر المتوسطة.',
    ),
  ];

  static const products = <Product>[
    Product(
      id: 'p1',
      name: 'أرز بسمتي هندي 10 كجم',
      description:
          'أرز بسمتي طويل الحبة، الكرتون يضم 4 أكياس. مناسب للبقالات والمطاعم الصغيرة.',
      wholesalePrice: 96,
      unit: ProductUnit.carton,
      minOrder: 2,
      stock: 80,
      supplierId: 's1',
      categoryId: 'c1',
      isPopular: true,
    ),
    Product(
      id: 'p2',
      name: 'زيت دوار الشمس 1.8 لتر',
      description:
          'صندوق من 6 عبوات زيت نباتي للطبخ. يُحفظ في مكان جاف بعيدًا عن الشمس.',
      wholesalePrice: 78,
      unit: ProductUnit.box,
      minOrder: 1,
      stock: 60,
      supplierId: 's1',
      categoryId: 'c1',
      isPopular: true,
    ),
    Product(
      id: 'p3',
      name: 'تمر سكري فاخر',
      description:
          'تمر سكري طازج يُباع بالكيلو. الحد الأدنى مناسب لتعبئة أرفف التمور.',
      wholesalePrice: 28,
      unit: ProductUnit.kilo,
      minOrder: 5,
      stock: 200,
      supplierId: 's1',
      categoryId: 'c1',
      isPopular: false,
    ),
    Product(
      id: 'p4',
      name: 'مياه شرب 330 مل',
      description:
          'صندوق مياه معبأ يضم 40 عبوة. خيار سريع لحركة البيع اليومية.',
      wholesalePrice: 16,
      unit: ProductUnit.box,
      minOrder: 10,
      stock: 150,
      supplierId: 's1',
      categoryId: 'c1',
      isPopular: false,
    ),
    Product(
      id: 'p5',
      name: 'أكياس تسوق وسط',
      description:
          'كرتون يضم 500 كيس تسوق متوسط للمتاجر. سماكة مناسبة للاستخدام اليومي.',
      wholesalePrice: 32,
      unit: ProductUnit.carton,
      minOrder: 3,
      stock: 90,
      supplierId: 's2',
      categoryId: 'c2',
      isPopular: false,
    ),
    Product(
      id: 'p6',
      name: 'رول حراري للكاشير',
      description:
          'صندوق من 50 رولًا بمقاس 80 ملم. متوافق مع أجهزة الكاشير الشائعة.',
      wholesalePrice: 45,
      unit: ProductUnit.box,
      minOrder: 2,
      stock: 40,
      supplierId: 's2',
      categoryId: 'c2',
      isPopular: true,
    ),
    Product(
      id: 'p7',
      name: 'صابون سائل لليدين 4 لتر',
      description:
          'عبوة عملية لدورات المياه وكاونتر الخدمة. رائحة خفيفة وسريعة الشطف.',
      wholesalePrice: 18,
      unit: ProductUnit.piece,
      minOrder: 6,
      stock: 70,
      supplierId: 's2',
      categoryId: 'c3',
      isPopular: true,
    ),
    Product(
      id: 'p8',
      name: 'مناديل ورقية 150 منديل',
      description: 'كرتون من 24 عبوة مناديل ناعمة. مناسب للبقالات والصيدليات.',
      wholesalePrice: 52,
      unit: ProductUnit.carton,
      minOrder: 2,
      stock: 55,
      supplierId: 's2',
      categoryId: 'c3',
      isPopular: true,
    ),
    Product(
      id: 'p9',
      name: 'طقم استكانات شاي',
      description:
          'صندوق يضم 12 طقمًا من الاستكانات الزجاجية. يتحمل التقديم اليومي.',
      wholesalePrice: 110,
      unit: ProductUnit.box,
      minOrder: 1,
      stock: 25,
      supplierId: 's3',
      categoryId: 'c4',
      isPopular: true,
    ),
    Product(
      id: 'p10',
      name: 'لمبة LED 12 واط',
      description:
          'كرتون من 20 لمبة إضاءة بيضاء. استهلاك منخفض وعمر تشغيلي طويل.',
      wholesalePrice: 64,
      unit: ProductUnit.carton,
      minOrder: 1,
      stock: 35,
      supplierId: 's3',
      categoryId: 'c5',
      isPopular: false,
    ),
    Product(
      id: 'p11',
      name: 'شاحن جداري منفذين',
      description:
          'شاحن مزدوج للهواتف. يُباع بالحبة مع حد أدنى يناسب رف الإكسسوارات.',
      wholesalePrice: 24,
      unit: ProductUnit.piece,
      minOrder: 8,
      stock: 100,
      supplierId: 's3',
      categoryId: 'c5',
      isPopular: false,
    ),
    Product(
      id: 'p12',
      name: 'أقلام حبر جاف أزرق',
      description:
          'صندوق من 50 قلمًا للكتابة اليومية. خيار ثابت لقسم القرطاسية.',
      wholesalePrice: 14,
      unit: ProductUnit.box,
      minOrder: 4,
      stock: 120,
      supplierId: 's3',
      categoryId: 'c6',
      isPopular: true,
    ),
  ];
}
