/// 跨 feature 共用的 String 判空扩展（纯 Dart，不依赖 BuildContext）。
extension StringBlankX on String {
  /// 去空白后非空。
  bool get isNotBlank => trim().isNotEmpty;

  /// 去空白后为空。
  bool get isBlank => trim().isEmpty;
}
