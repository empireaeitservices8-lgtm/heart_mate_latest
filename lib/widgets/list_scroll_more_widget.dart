import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class ListScrollMoreWidget<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics physics;

  const ListScrollMoreWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.emptyWidget,
    this.padding = const EdgeInsets.all(16.0),
    this.physics = const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
  });

  @override
  State<ListScrollMoreWidget<T>> createState() => _ListScrollMoreWidgetState<T>();
}

class _ListScrollMoreWidgetState<T> extends State<ListScrollMoreWidget<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return RefreshIndicator(
        color: AppPalette.primaryRose,
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: widget.physics,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: widget.emptyWidget ??
                const Center(
                  child: Text(
                    'No items found',
                    style: TextStyle(
                      color: AppPalette.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppPalette.primaryRose,
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppPalette.primaryRose,
                  ),
                ),
              ),
            );
          }

          return widget.itemBuilder(context, widget.items[index], index);
        },
      ),
    );
  }
}
