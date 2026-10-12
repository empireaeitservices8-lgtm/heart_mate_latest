import '../../../models/dashboard_models.dart';
import '../../../providers/view_model.dart';
import '../../../services/dashboard_api_service.dart';

class DashboardViewModel extends ViewModel {
  final DashboardApiService _service = DashboardApiService();

  DeviceUserCountModel? _counts;
  DeviceUserCountModel? get counts => _counts;

  LicenseSummaryModel? _license;
  LicenseSummaryModel? get license => _license;

  DashboardViewModel() {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    await coverWithProgress(this, () async {
      final countsRes = await _service.fetchDeviceUserCount();
      if (countsRes.isSuccess) {
        _counts = countsRes.data;
      }

      final licenseRes = await _service.fetchLicenseSummary();
      if (licenseRes.isSuccess) {
        _license = licenseRes.data;
      }
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
