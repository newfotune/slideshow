import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiHelper {
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8081';
    }
    
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:8081';
    } else if (Platform.isIOS) {
      // iOS simulator uses localhost
      return 'http://localhost:8081';
    }
    
    return 'http://localhost:8081';
  }
  
  static String getPostEndpoint() {
    return '${getBaseUrl()}/v1/post';
  }
}

