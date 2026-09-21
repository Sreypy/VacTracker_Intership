import 'package:dio/dio.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  AuthService() {
    // Add interceptor to include JWT token in requests
    dio.interceptors.add(
      InterceptorsWrapper(
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
      ),
    );
  }

  // Check if phone number already exists
  Future<bool> checkPhone(String phone) async {
    final response = await dio.post(
      "/auth/check-phone",
      data: {"phone": phone},
    );

    return response.data["exists"];
  }

  // Log in with phone number + password
  // Expects the backend to return { "access_token": ..., "user": {...} },
  // same shape verifyOtp() used to return, so LoginScreen doesn't need
  // to change how it handles the result.
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await dio.post(
      "/auth/login",
      data: {"phone": phone, "password": password},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  // Send OTP. Used by the forgot-password flow (ForgotPasswordScreen).
  // Kept available for a future OTP-login flow too, if you bring that back.
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await dio.post("/auth/send-otp", data: {"phone": phone});

    return Map<String, dynamic>.from(response.data as Map);
  }

  // Verify OTP and login — not currently wired up to any screen since
  // login now uses password, but kept for a future OTP-login flow.
  Future verifyOtp(String phone, String otp) async {
    final response = await dio.post(
      "/auth/verify-otp",
      data: {"phone": phone, "otp": otp},
    );

    return response.data;
  }

  // Forgot password: verifies the OTP and sets a new password.
  // Call sendOtp(phone) first to get the code, then this.
  Future<Map<String, dynamic>> resetPassword(
    String phone,
    String otp,
    String newPassword,
  ) async {
    final response = await dio.post(
      "/auth/reset-password",
      data: {"phone": phone, "otp": otp, "newPassword": newPassword},
    );

    return Map<String, dynamic>.from(response.data as Map);
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
