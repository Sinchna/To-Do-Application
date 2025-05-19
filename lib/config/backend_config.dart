/// ---------------- lib/config/backend_config.dart ----------------

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
class BackendConfig {
  static Future<void> initParse() async {
    const keyApplicationId = 'ppvgQr85EAo5VK6laMVgWEfXNkpok0YNTh1bUv1m';
    const keyClientKey = 'Ne8oLnOFpCrHwqidgTqgBCGaKbGR9G9RqXITFPbA';
    const keyParseServerUrl = 'https://parseapi.back4app.com';

    await Parse().initialize(
      keyApplicationId,
      keyParseServerUrl,
      clientKey: keyClientKey,
      autoSendSessionId: true,
      debug: true,
    );
  }
}