/// 受支持界面语言的**纯 Dart** 定义（core 层）。
///
/// 单独拆出来是为了让 domain 能声明「按语言取文案」而不依赖 Flutter：
/// domain / core 只认这个枚举，Flutter 侧的 `Locale` 转换、生成的
/// `AppLocalizations` 查找都留在 `shared/l10n/strings.dart` 的扩展里。
///
/// 放在 core 而非 shared：语言编码（BCP-47 子集）是与具体业务无关的基础词汇，
/// 换任何 app 都能原样复用。
enum AppLang {
  zh('zh'),
  zhHant('zh_Hant'),
  zhHantHK('zh_Hant_HK'),
  en('en');

  /// arb / 系统侧的语言编码。
  final String code;
  const AppLang(this.code);

  /// 按偏好编码解析语言：未知回退简体。
  static AppLang of(String? code) {
    final c = code?.trim().toLowerCase();
    return AppLang.values.firstWhere(
      (e) => e.code.toLowerCase() == c,
      orElse: () => AppLang.zh,
    );
  }

  /// 语言的自称（母语写法），不随界面语言变化。
  String get nativeName => switch (this) {
    AppLang.zh => '中文',
    AppLang.zhHant => '繁體中文（臺灣）',
    AppLang.zhHantHK => '繁體中文（香港）',
    AppLang.en => 'English',
  };
}
