part of 'jk_appbar.dart';

class _JkAppBarController extends InheritedWidget {
  final ValueNotifier<double> collapsedRatio;

  // the extent when collapsable top bar expanded
  final double appBarExpandExtent;

  // the extent when collapsable bottom bar expanded
  final double bottomBarExpandExtent;

  const _JkAppBarController({
    Key? key,
    required this.appBarExpandExtent,
    required this.bottomBarExpandExtent,
    required this.collapsedRatio,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant _JkAppBarController oldWidget) {
    return appBarExpandExtent != oldWidget.appBarExpandExtent ||
        bottomBarExpandExtent != oldWidget.bottomBarExpandExtent;
  }

  static _JkAppBarController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_JkAppBarController>();
  }
}
