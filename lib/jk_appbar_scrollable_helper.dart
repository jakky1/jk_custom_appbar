part of 'jk_appbar.dart';

// ignore: camel_case_types
class priv__JkAppBarScrollableHelper {
  bool _widgetIsReverse = false;
  ScrollController? _widgetScrollController;

  _JkAppBarController? _appBarController;
  ScrollController? _scrollController;
  double firstPadding = 0;
  double lastPadding = 0;

  void setWidgetProperties(bool reverse, ScrollController? controller) {
    _widgetIsReverse = reverse;
    _widgetScrollController = controller;

    if (_widgetScrollController != null) {
      _scrollController?.dispose();
      _scrollController = null;
    } else {
      _scrollController ??= ScrollController();
    }

    // if this scrollController is not attached yet,
    // it means this scrollable view is being constructed now,
    // and we want to set the initial scrollOffset if the app bar collapsed
    if (getScrollController().positions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onCollapsedRatioChanged();
      });
    }
  }

  ScrollController getScrollController() {
    return _widgetScrollController ?? _scrollController!;
  }

  void onWidgetDidChangeDependencies(BuildContext context) {
    _appBarController = _JkAppBarController.of(context);
    assert(_appBarController != null,
        "[JkCustomAppBar] $runtimeType must be a descendant of JkAppBarLayout");
    _appBarController!.collapsedRatio.addListener(onCollapsedRatioChanged);
  }

  void onWidgetDispose() {
    _scrollController?.dispose();
    _appBarController?.collapsedRatio.removeListener(onCollapsedRatioChanged);
  }

  void onCollapsedRatioChanged() {
    if (getScrollController().positions.isEmpty) return;

    double startBarExtent = !_widgetIsReverse
        ? _appBarController!.appBarExpandExtent
        : _appBarController!.bottomBarExpandExtent;
    double startBarNowCollapsedExtent =
        startBarExtent * _appBarController!.collapsedRatio.value;
    double pixels = getScrollController().position.pixels;
    double minScrollExtent = getScrollController().position.minScrollExtent;
    double listScrollOffsetFromMin = pixels - minScrollExtent;
    if (listScrollOffsetFromMin <= startBarExtent &&
        (listScrollOffsetFromMin - startBarNowCollapsedExtent).abs() > 2) {
      getScrollController()
          .position
          // ignore: invalid_use_of_protected_member
          .forcePixels(minScrollExtent + startBarNowCollapsedExtent);
    }
  }

  void updateAppBarInfo(BuildContext context) {
    double appBarExpandExtent = _appBarController?.appBarExpandExtent ?? 0;
    double bottomBarExpandExtent =
        _appBarController?.bottomBarExpandExtent ?? 0;

    firstPadding =
        !_widgetIsReverse ? appBarExpandExtent : bottomBarExpandExtent;
    lastPadding =
        !_widgetIsReverse ? bottomBarExpandExtent : appBarExpandExtent;
  }
}
