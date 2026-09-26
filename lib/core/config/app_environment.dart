enum AppEnvironment { demo, production }

/// البناء الافتراضي للعرض يعمل محليًا بالكامل.
abstract final class AppConfig {
  static const environment = AppEnvironment.demo;

  static bool get isDemo => environment == AppEnvironment.demo;
}
