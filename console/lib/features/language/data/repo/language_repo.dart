import 'package:console/app_exporter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageRepo {
  static final String languageKey = 'language.key';
  final FlutterSecureStorage storage;

  LanguageRepo({required this.storage});

  Future save({required LanguageModel model}) async {
    await storage.write(key: languageKey, value: model.key);
    BrowserWindow.rememberLanguage(model.key);
  }

  Future<String?> loadKey() async {
    final key = await storage.read(key: languageKey);
    // a language saved before the splash read it
    if (key != null) BrowserWindow.rememberLanguage(key);
    return key;
  }
}
