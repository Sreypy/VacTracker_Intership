import 'package:dio/dio.dart';
import '../config/api_config.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future sendOtp(String phone) async {
    final response = await dio.post("/auth/send-otp", data: {"phone": phone});

    return response.data;
  }
}
