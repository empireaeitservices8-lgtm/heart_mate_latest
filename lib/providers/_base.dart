import 'package:flutter/material.dart';
import '_mixins.dart';
import '../services/web_api_services.dart';

abstract class BaseProvider extends ChangeNotifier with MixinProgressProvider, MixinApiProvider {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final WebApiServices api = WebApiServices();

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

abstract class BaseSimpleAPIProvider<T> extends BaseProvider {
  T? _data;
  T? get data => _data;
  bool get hasData => _data != null;

  void setData(T? data) {
    _data = data;
    clearError();
    notifyListeners();
  }

  Future<void> fetchData();
}

abstract class BaseListLoadMoreProvider<T> extends BaseProvider {
  final List<T> _items = [];
  List<T> get items => List.unmodifiable(_items);

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  void setItems(List<T> newItems) {
    _items.clear();
    _items.addAll(newItems);
    notifyListeners();
  }

  void appendItems(List<T> moreItems) {
    _items.addAll(moreItems);
    notifyListeners();
  }

  void setHasMore(bool hasMore) {
    _hasMore = hasMore;
    notifyListeners();
  }

  void setLoadingMore(bool loadingMore) {
    _isLoadingMore = loadingMore;
    notifyListeners();
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _items.clear();
  }

  Future<void> refresh();
  Future<void> loadMore();
}
