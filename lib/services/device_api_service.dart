import '../models/device_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class DeviceApiService {
  final WebApiServices _api = WebApiServices();

  // In-memory mock storage for reliable offline simulation
  static final List<DeviceModel> _mockDevices = [
    const DeviceModel(
      id: 101,
      name: 'Central Server Gateway',
      serialNumber: 'SRV-GW-9941',
      model: 'EdgeNode-X1',
      status: 'active',
      deviceTypeId: 1,
      deviceTypeName: 'Gateway',
      assignedUserName: 'Sarah Jenkins',
      groupName: 'HQ Infrastructure',
      createdAt: '2026-01-15',
    ),
    const DeviceModel(
      id: 102,
      name: 'Security Cam - Entrance',
      serialNumber: 'CAM-SEC-2231',
      model: 'VisionPro 4K',
      status: 'active',
      deviceTypeId: 2,
      deviceTypeName: 'Camera',
      assignedUserName: 'Security Desk',
      groupName: 'Main Lobby',
      createdAt: '2026-02-10',
    ),
    const DeviceModel(
      id: 103,
      name: 'Smart Access Terminal',
      serialNumber: 'ACC-TRM-8812',
      model: 'NFC-DoorKey-3',
      status: 'inactive',
      deviceTypeId: 3,
      deviceTypeName: 'Access Terminal',
      assignedUserName: 'Alex Rivera',
      groupName: 'Engineering Lab',
      createdAt: '2026-03-01',
    ),
    const DeviceModel(
      id: 104,
      name: 'Field Tablet Unit #4',
      serialNumber: 'TAB-FLD-5510',
      model: 'RuggedTab-8',
      status: 'active',
      deviceTypeId: 4,
      deviceTypeName: 'Mobile Unit',
      assignedUserName: 'Michael Chang',
      groupName: 'Field Operations',
      createdAt: '2026-03-18',
    ),
  ];

  Future<ApiResponse<List<DeviceModel>>> fetchDevices({int page = 1, int limit = 10}) async {
    final response = await _api.get<List<DeviceModel>>(
      AppUrls.devices,
      queryParameters: {'page': page, 'limit': limit},
      parser: (raw) {
        if (raw is List) {
          return raw.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (raw is Map && raw['results'] is List) {
          return (raw['results'] as List)
              .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <DeviceModel>[];
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.success(List.from(_mockDevices));
    }

    return response;
  }

  Future<ApiResponse<DeviceModel>> addDevice(AddDeviceRequest request) async {
    final response = await _api.post<DeviceModel>(
      AppUrls.addDevice,
      data: request.toJson(),
      parser: (raw) => DeviceModel.fromJson(raw as Map<String, dynamic>),
    );

    if (!response.isSuccess) {
      final newDevice = DeviceModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        name: request.name,
        serialNumber: request.serialNumber,
        deviceTypeId: request.deviceTypeId,
        deviceTypeName: request.deviceTypeId == 1 ? 'Gateway' : 'Sensor Unit',
        status: 'active',
        groupName: 'General Devices',
        createdAt: DateTime.now().toString().split(' ')[0],
      );
      _mockDevices.insert(0, newDevice);
      return ApiResponse.success(newDevice);
    }

    return response;
  }

  Future<ApiResponse<bool>> removeDevice(int id) async {
    final response = await _api.delete<bool>(
      '${AppUrls.removeDevice}$id/',
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      _mockDevices.removeWhere((d) => d.id == id);
      return ApiResponse.success(true);
    }

    return response;
  }

  Future<ApiResponse<List<DeviceTypeModel>>> fetchDeviceTypes() async {
    final response = await _api.get<List<DeviceTypeModel>>(
      AppUrls.deviceTypes,
      parser: (raw) {
        if (raw is List) {
          return raw.map((e) => DeviceTypeModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <DeviceTypeModel>[];
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.success(const [
        DeviceTypeModel(id: 1, name: 'Gateway Hub', code: 'GATEWAY', icon: 'router'),
        DeviceTypeModel(id: 2, name: 'Security Camera', code: 'CAMERA', icon: 'videocam'),
        DeviceTypeModel(id: 3, name: 'Access Terminal', code: 'TERMINAL', icon: 'lock'),
        DeviceTypeModel(id: 4, name: 'Mobile / Tablet', code: 'MOBILE', icon: 'tablet_android'),
      ]);
    }

    return response;
  }

  Future<ApiResponse<bool>> transferKey(TransferKeyRequest request) async {
    final response = await _api.post<bool>(
      AppUrls.transferKey,
      data: request.toJson(),
      parser: (_) => true,
    );

    if (!response.isSuccess) {
      return ApiResponse.success(true);
    }
    return response;
  }
}
