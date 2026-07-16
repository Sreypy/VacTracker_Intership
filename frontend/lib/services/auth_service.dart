import 'package:dio/dio.dart';
import 'package:frontend/config/api_config.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future sendOtp(String phone) async {
    final response = await dio.post("/auth/send-otp", data: {"phone": phone});

    return response.data;
  }

  Future verifyOtp(String phone, String otp) async {
    final response = await dio.post(
      "/auth/verify-otp",
      data: {"phone": phone, "otp": otp},
    );

    return response.data;
  }

  Future register(Map<String, dynamic> data) async {
    final response = await dio.post("/users", data: data);

    return response.data;
  }
}
