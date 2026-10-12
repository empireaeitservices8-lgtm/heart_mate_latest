import '../../../models/user_models.dart';
import '../../../providers/_base.dart';
import '../../../services/user_api_service.dart';

class UserViewModel extends BaseListLoadMoreProvider<UserModel> {
  final UserApiService _service = UserApiService();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedRole;
  String? get selectedRole => _selectedRole;

  UserViewModel() {
    refresh();
  }

  void onShowError(dynamic error) {
    if (error != null) {
      print('[UserViewModel Error] $error');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setSelectedRole(String? role) {
    _selectedRole = role;
    notifyListeners();
  }

  List<UserModel> get filteredUsers {
    return items.where((user) {
      final matchesQuery = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery) ||
          user.phone.contains(_searchQuery);

      final matchesRole = _selectedRole == null || user.role == _selectedRole;

      return matchesQuery && matchesRole;
    }).toList();
  }

  @override
  Future<void> refresh() async {
    resetPagination();
    setLoading(true);
    try {
      final res = await _service.fetchUsers(page: 1);
      if (res.isSuccess && res.data != null) {
        setItems(res.data!);
        setHasMore(res.data!.length >= 10);
      }
    } catch (e) {
      onShowError(e);
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    setLoadingMore(true);

    try {
      final nextPage = currentPage + 1;
      final res = await _service.fetchUsers(page: nextPage);
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

  Future<bool> addUser(AddUserRequest request) async {
    setLoading(true);
    try {
      final res = await _service.addUser(request);
      if (res.isSuccess && res.data != null) {
        await refresh();
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
