import 'package:dio/dio.dart';

class Authenticatie {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<Response?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } on DioException catch (e) {
      print('Login fout: ${e.message}');
      return e.response;
    }
  }
}
