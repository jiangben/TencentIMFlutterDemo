import 'package:dio/dio.dart';
import 'package:listen/utils/config.dart';

var options = BaseOptions(
  baseUrl: Config.server_base_url,
  connectTimeout: 50000,
  receiveTimeout: 30000,
);
var dio = Dio(options);
