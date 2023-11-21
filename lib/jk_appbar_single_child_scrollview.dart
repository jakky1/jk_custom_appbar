part of 'jk_appbar.dart';

/// A clone of official SingleChildScrollView but support bars collapsed/expanded).
/// All the parameters are the same with SingleChildScrollView.
class JkAppBarSingleChildScrollView extends StatefulWidget {
  /// When this is under a TabView,
  /// set to true to keep state even if user changes tab to another view,
  /// set to false to recreate this view each time user go back to this tab.
  final bool keepAlive;

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Widget child;

  const JkAppBarSingleChildScrollView({
    super.key,
    this.keepAlive = true,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.controller,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  }) : assert(
          !(controller != null && (primary ?? false)),
          'Primary ScrollViews obtain their ScrollController via inheritance '
          'from a PrimaryScrollController widget. You cannot both set primary to '
          'true and pass an explicit controller.',
        );

  @override
  State<JkAppBarSingleChildScrollView> createState() =>
      _JkAppBarSingleChildScrollView();
}

class _JkAppBarSingleChildScrollView
    extends State<JkAppBarSingleChildScrollView>
    with AutomaticKeepAliveClientMixin {
  final helper = priv__JkAppBarScrollableHelper();

  @override
  void initState() {
    super.initState();
    helper.setWidgetProperties(widget.reverse, widget.controller);
  }

  @override
  void didUpdateWidget(covariant JkAppBarSingleChildScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    helper.setWidgetProperties(widget.reverse, widget.controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    helper.onWidgetDidChangeDependencies(context);
  }

  @override
  void dispose() {
    helper.onWidgetDispose();
    super.dispose();
  }

  // --------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    helper.updateAppBarInfo(context);

    var children = <Widget>[
      SizedBox(width: helper.firstPadding, height: helper.firstPadding),
      widget.child,
      //SizedBox(width: helper.lastPadding, height: helper.lastPadding),
    ];

    Widget child = Flex(
      direction: widget.scrollDirection,
      children: children,
    );

    return SingleChildScrollView(
      controller: helper.getScrollController(),
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      primary: widget.primary,
      physics: widget.physics,
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
