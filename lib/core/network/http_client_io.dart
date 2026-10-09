import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

Client getSecurityClient() {
  final ioc = HttpClient();
  ioc.badCertificateCallback = (X509Certificate cert, String host, int port) {
    return host == '10.39.57.127';
  };
  return IOClient(ioc);
}
