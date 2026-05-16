import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _token;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Future<Map<String, dynamic>> register(String phone, String password, String nickname) async {
    final response = await _dio.post('/auth/register', data: {
      'phone': phone,
      'password': password,
      'nickname': nickname,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createFamily(String name) async {
    final response = await _dio.post('/family/create', data: {'name': name});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinFamily(String inviteCode) async {
    final response = await _dio.post('/family/join', data: {'inviteCode': inviteCode});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyFamily() async {
    final response = await _dio.get('/family/mine');
    return response.data as Map<String, dynamic>;
  }

  Future<void> leaveFamily() async {
    await _dio.post('/family/leave');
  }
}
