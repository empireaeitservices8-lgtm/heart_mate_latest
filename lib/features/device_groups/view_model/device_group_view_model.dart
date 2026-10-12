import '../../../models/device_group_models.dart';
import '../../../providers/view_model.dart';
import '../../../services/device_group_api_service.dart';

class DeviceGroupViewModel extends ViewModel {
  final DeviceGroupApiService _service = DeviceGroupApiService();

  List<DeviceGroupModel> _groups = [];
  List<DeviceGroupModel> get groups => _groups;

  DeviceGroupViewModel() {
    loadGroups();
  }

  Future<void> loadGroups() async {
    await coverWithProgress(this, () async {
      final res = await _service.fetchDeviceGroups();
      if (res.isSuccess && res.data != null) {
        _groups = res.data!;
        notifyListeners();
      }
    });
  }

  Future<bool> createGroup(String name, String description) async {
    if (name.isEmpty) return false;
    final res = await coverWithProgress(this, () async {
      final response = await _service.addDeviceGroup(
        AddDeviceGroupRequest(name: name, description: description),
      );
      if (response.isSuccess) {
        await loadGroups();
        return true;
      }
      return false;
    });
    return res ?? false;
  }

  Future<bool> renameGroup(int id, String newName) async {
    if (newName.isEmpty) return false;
    final res = await coverWithProgress(this, () async {
      final response = await _service.renameGroup(id, newName);
      if (response.isSuccess) {
        await loadGroups();
        return true;
      }
      return false;
    });
    return res ?? false;
  }

  Future<bool> deleteGroup(int id) async {
    final res = await coverWithProgress(this, () async {
      final response = await _service.deleteGroup(id);
      if (response.isSuccess) {
        _groups.removeWhere((g) => g.id == id);
        notifyListeners();
        return true;
      }
      return false;
    });
    return res ?? false;
  }
}
