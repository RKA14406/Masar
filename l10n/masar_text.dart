import 'package:flutter/widgets.dart';

class MasarText {
  const MasarText._();

  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static String t(BuildContext context, String en, String ar) {
    return isArabic(context) ? ar : en;
  }
}
