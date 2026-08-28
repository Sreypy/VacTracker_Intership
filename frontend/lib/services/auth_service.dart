import 'package:dio/dio.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  
  AuthService() {
    // Add interceptor to include JWT token in requests
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // If 401 Unauthorized, clear storage and redirect to login
        if (error.response?.statusCode == 401) {
          await StorageService.clearAll();
        }
        return handler.next(error);
      },
    ));
  }

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

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get("/users/profile");

    return response.data;
  }

  Future<void> updateProfile(Map<String, String> updatedData) async {}
}
