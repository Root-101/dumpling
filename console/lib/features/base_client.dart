import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

abstract class BaseClient {
  /// Every route of the service is under `/api`
  String get baseUrl => '${Environment.serviceUrl}/api';

  final Dio dio;

  BaseClient(this.dio);

  Options options({String? token}) {
    return Options(
      headers: <String, dynamic>{
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}
