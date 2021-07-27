import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:leaf/localization/languages/en.dart';
import 'package:leaf/localization/languages/nb.dart';

class Localization {
  final Locale locale;

  Localization(this.locale);

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': EN_LANG,
    'nb': NB_LANG,
  };

  String getTranslatedValue(String key){
    return _localizedValues[locale.languageCode]![key]!;
  }

  static const LocalizationsDelegate<Localization> delegate = _LocalizationDelegate();
}

class _LocalizationDelegate
    extends LocalizationsDelegate<Localization> {
  const _LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'nb'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<Localization>(Localization(locale));
  }

  @override
  bool shouldReload(_LocalizationDelegate old) => false;
}