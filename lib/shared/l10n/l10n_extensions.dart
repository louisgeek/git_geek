import 'package:flutter/widgets.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';

/// BuildContext 快捷访问：context.l10n。
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
