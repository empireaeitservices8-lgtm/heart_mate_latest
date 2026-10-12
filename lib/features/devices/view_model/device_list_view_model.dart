import '../../../models/device_models.dart';
import '../../../providers/_base.dart';
import '../../../services/device_api_service.dart';

class DeviceListViewModel extends BaseListLoadMoreProvider<DeviceModel> {
  final DeviceApiService _service = DeviceApiService();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int? _selectedTypeId;
  int? get selectedTypeId => _selectedTypeId;

  List<DeviceTypeModel> _deviceTypes = [];
  List<DeviceTypeModel> get deviceTypes => _deviceTypes;

  DeviceListViewModel() {
    loadInitialData();
  }

  void onShowError(dynamic error) {
    if (error != null) {
      print('[DeviceListViewModel Error] $error');
    }
  }

  Future<void> loadInitialData() async {
    setLoading(true);
    try {
      final typesRes = await _service.fetchDeviceTypes();
      if (typesRes.isSuccess && typesRes.data != null) {
        _deviceTypes = typesRes.data!;
      }
      await refresh();
    } catch (e) {
      onShowError(e);
    } finally {
      setLoading(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setFilterType(int? typeId) {
    _selectedTypeId = typeId;
    notifyListeners();
  }

  List<DeviceModel> get filteredDevices {
    return items.where((device) {
      final matchesQuery = _searchQuery.isEmpty ||
          device.name.toLowerCase().contains(_searchQuery) ||
          device.serialNumber.toLowerCase().contains(_searchQuery) ||
          (device.assignedUserName?.toLowerCase().contains(_searchQuery) ?? false);

      final matchesType = _selectedTypeId == null || device.deviceTypeId == _selectedTypeId;

      return matchesQuery && matchesType;
    }).toList();
  }

  @override
  Future<void> refresh() async {
    resetPagination();
    try {
      final res = await _service.fetchDevices(page: 1);
      if (res.isSuccess && res.data != null) {
        setItems(res.data!);
        setHasMore(res.data!.length >= 10);
      }
    } catch (e) {
      onShowError(e);
    }
  }

  @override
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    setLoadingMore(true);

    try {
      final nextPage = currentPage + 1;
      final res = await _service.fetchDevices(page: nextPage);
      if (res.isSuccess && res.data != null) {
        appendItems(res.data!);
        setHasMore(res.data!.length >= 10);
      } else {
        setHasMore(false);
      }
    } catch (e) {
      onShowError(e);
      setHasMore(false);
    } finally {
      setLoadingMore(false);
    }
  }

  Future<bool> deleteDevice(int id) async {
    setLoading(true);
    try {
      final res = await _service.removeDevice(id);
      if (res.isSuccess) {
        final updated = items.where((d) => d.id != id).toList();
        setItems(updated);
        return true;
      }
      return false;
    } catch (e) {
      onShowError(e);
      return false;
    } finally {
      setLoading(false);
    }
  }
}
