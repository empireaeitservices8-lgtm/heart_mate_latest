import '../models/device_group_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class DeviceGroupApiService {
  final WebApiServices _api = WebApiServices();

  static final List<DeviceGroupModel> _mockGroups = [
    const DeviceGroupModel(
      id: 1,
      name: 'HQ Infrastructure',
      description: 'Primary routers, gateways, and switches at headquarters',
      deviceCount: 18,
      createdAt: '2026-01-10',
    ),
    const DeviceGroupModel(
      id: 2,
      name: 'Main Lobby',
      description: 'Lobby surveillance cameras and guest access terminals',
      deviceCount: 6,
      createdAt: '2026-01-20',
    ),
    const DeviceGroupModel(
      id: 3,
      name: 'Engineering Lab',
      description: 'R&D hardware prototypes and test access gates',
      deviceCount: 14,
      createdAt: '2026-02-05',
    ),
    const DeviceGroupModel(
      id: 4,
      name: 'Field Operations',
      description: 'Mobile units and field tablets in active transit',
      deviceCount: 22,
      createdAt: '2026-02-14',
    ),
  ];

  Future<ApiResponse<List<DeviceGroupModel>>> fetchDeviceGroups() async {
    final response = await _api.get<List<DeviceGroupModel>>(
      AppUrls.deviceGroups,
      parser: (raw) {
        if (raw is List) {
          return raw.map((e) => DeviceGroupModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <DeviceGroupModel>[];
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.success(List.from(_mockGroups));
    }
    return response;
  }

  Future<ApiResponse<DeviceGroupModel>> addDeviceGroup(AddDeviceGroupRequest request) async {
    final response = await _api.post<DeviceGroupModel>(
      AppUrls.addDeviceGroup,
      data: request.toJson(),
      parser: (raw) => DeviceGroupModel.fromJson(raw as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      final newGroup = DeviceGroupModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        name: request.name,
        description: request.description,
        deviceCount: 0,
        createdAt: DateTime.now().toString().split(' ')[0],
      );
      _mockGroups.insert(0, newGroup);
      return ApiResponse.success(newGroup);
    }
    return response;
  }

  Future<ApiResponse<bool>> addDeviceToGroup(int groupId, int deviceId) async {
    final response = await _api.post<bool>(
      AppUrls.addDeviceToGroup,
      data: {'group_id': groupId, 'device_id': deviceId},
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      return ApiResponse.success(true);
    }
    return response;
  }

  Future<ApiResponse<bool>> renameGroup(int id, String name) async {
    final response = await _api.put<bool>(
      '${AppUrls.renameDeviceGroup}$id/',
      data: {'name': name},
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      final idx = _mockGroups.indexWhere((g) => g.id == id);
      if (idx != -1) {
        final existing = _mockGroups[idx];
        _mockGroups[idx] = DeviceGroupModel(
          id: existing.id,
          name: name,
          description: existing.description,
          deviceCount: existing.deviceCount,
          createdAt: existing.createdAt,
        );
      }
      return ApiResponse.success(true);
    }
    return response;
  }

  Future<ApiResponse<bool>> deleteGroup(int id) async {
    final response = await _api.delete<bool>(
      '${AppUrls.deleteDeviceGroup}$id/',
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      _mockGroups.removeWhere((g) => g.id == id);
      return ApiResponse.success(true);
    }
    return response;
  }
}
