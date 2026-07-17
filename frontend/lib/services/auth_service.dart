import 'package:dio/dio.dart';
import 'package:frontend/config/api_config.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  // Check if phone number already exists
  Future<bool> checkPhone(String phone) async {
    final response = await dio.post(
      "/auth/check-phone",
      data: {"phone": phone},
    );

    return response.data["exists"];
  }

  // Send OTP for existing users
  Future sendOtp(String phone) async {
    final response = await dio.post("/auth/send-otp", data: {"phone": phone});

    return response.data;
  }

  // Verify OTP and login
  Future verifyOtp(String phone, String otp) async {
    final response = await dio.post(
      "/auth/verify-otp",
      data: {"phone": phone, "otp": otp},
    );

    return response.data;
  }

  // Register new farmer/vet
  Future register(Map<String, dynamic> data) async {
    final response = await dio.post("/users", data: data);

    return response.data;
  }
}
