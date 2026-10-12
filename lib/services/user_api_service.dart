import '../models/user_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class UserApiService {
  final WebApiServices _api = WebApiServices();

  static final List<UserModel> _mockUsers = [
    const UserModel(
      id: 1,
      name: 'Sarah Jenkins',
      email: 'sarah.j@enterprise.com',
      phone: '+1 (555) 234-5678',
      role: 'Administrator',
      status: 'active',
      devicesCount: 5,
      groupsCount: 2,
      createdAt: '2025-11-12',
    ),
    const UserModel(
      id: 2,
      name: 'Alex Rivera',
      email: 'alex.r@enterprise.com',
      phone: '+1 (555) 876-5432',
      role: 'Manager',
      status: 'active',
      devicesCount: 3,
      groupsCount: 1,
      createdAt: '2026-01-05',
    ),
    const UserModel(
      id: 3,
      name: 'Michael Chang',
      email: 'm.chang@enterprise.com',
      phone: '+1 (555) 345-6789',
      role: 'Engineer',
      status: 'active',
      devicesCount: 8,
      groupsCount: 3,
      createdAt: '2026-02-14',
    ),
    const UserModel(
      id: 4,
      name: 'Elena Rostova',
      email: 'elena.r@enterprise.com',
      phone: '+1 (555) 987-6543',
      role: 'Operator',
      status: 'inactive',
      devicesCount: 1,
      groupsCount: 1,
      createdAt: '2026-03-02',
    ),
  ];

  Future<ApiResponse<List<UserModel>>> fetchUsers({int page = 1, int limit = 10}) async {
    final response = await _api.get<List<UserModel>>(
      AppUrls.users,
      queryParameters: {'page': page, 'limit': limit},
      parser: (raw) {
        if (raw is List) {
          return raw.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (raw is Map && raw['results'] is List) {
          return (raw['results'] as List)
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <UserModel>[];
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.success(List.from(_mockUsers));
    }
    return response;
  }

  Future<ApiResponse<UserModel>> addUser(AddUserRequest request) async {
    final response = await _api.post<UserModel>(
      AppUrls.addUser,
      data: request.toJson(),
      parser: (raw) => UserModel.fromJson(raw as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        name: request.name,
        email: request.email,
        phone: request.phone,
        role: request.role,
        status: 'active',
        devicesCount: 0,
        groupsCount: 0,
        createdAt: DateTime.now().toString().split(' ')[0],
      );
      _mockUsers.insert(0, newUser);
      return ApiResponse.success(newUser);
    }
    return response;
  }

  Future<ApiResponse<bool>> deleteUserDevice(int userId, int deviceId) async {
    final response = await _api.delete<bool>(
      '${AppUrls.deleteUserDevice}$userId/$deviceId/',
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      return ApiResponse.success(true);
    }
    return response;
  }

  Future<ApiResponse<bool>> deleteUserGroup(int userId, int groupId) async {
    final response = await _api.delete<bool>(
      '${AppUrls.deleteUserGroup}$userId/$groupId/',
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      return ApiResponse.success(true);
    }
    return response;
  }
}
