part of 'jk_appbar.dart';

/// A clone of official ListView but support bars collapsed/expanded).
/// All the parameters are the same with ListView.
class JkAppBarListView extends StatefulWidget {
  /// When this is under a TabView,
  /// set to true to keep state even if user changes tab to another view,
  /// set to false to recreate this view each time user go back to this tab.
  final bool keepAlive;

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollBehavior? scrollBehavior;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final double? itemExtent;
  final Widget? prototypeItem;

  final SliverChildDelegate childrenDelegate;

  JkAppBarListView.builder({
    super.key,
    this.keepAlive = true,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemExtent,
    this.prototypeItem,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  })  : assert(itemCount == null || itemCount >= 0),
        assert(semanticChildCount == null || semanticChildCount <= itemCount!),
        assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both.',
        ),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        );

  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  JkAppBarListView.separated({
    super.key,
    this.keepAlive = true,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  })  : assert(itemCount >= 0),
        itemExtent = null,
        prototypeItem = null,
        childrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            if (index.isEven) {
              return itemBuilder(context, itemIndex);
            }
            return separatorBuilder(context, itemIndex);
          },
          findChildIndexCallback: findChildIndexCallback,
          childCount: _computeActualChildCount(itemCount),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget widget, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        );

  const JkAppBarListView.custom({
    super.key,
    this.keepAlive = true,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemExtent,
    this.prototypeItem,
    required this.childrenDelegate,
  }) : assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both',
        );

  @override
  State<JkAppBarListView> createState() => _JkAppBarListViewState();
}

class _JkAppBarListViewState extends State<JkAppBarListView>
    with AutomaticKeepAliveClientMixin {
  final helper = priv__JkAppBarScrollableHelper();

  @override
  void initState() {
    super.initState();
    helper.setWidgetProperties(widget.reverse, widget.controller);
  }

  @override
  void didUpdateWidget(covariant JkAppBarListView oldWidget) {
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

    late Widget sliverList;
    if (widget.itemExtent != null) {
      sliverList = SliverFixedExtentList(
        delegate: widget.childrenDelegate,
        itemExtent: widget.itemExtent!,
      );
    } else if (widget.prototypeItem != null) {
      sliverList = SliverPrototypeExtentList(
        delegate: widget.childrenDelegate,
        prototypeItem: widget.prototypeItem!,
      );
    } else {
      sliverList = SliverList(delegate: widget.childrenDelegate);
    }

    return CustomScrollView(
      controller: helper.getScrollController(),
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      scrollBehavior: widget.scrollBehavior,
      shrinkWrap: widget.shrinkWrap,
      center: widget.center,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        SliverPadding(
            padding: EdgeInsets.only(
                top: helper.firstPadding, left: helper.firstPadding)),
        sliverList,
        /*
        SliverPadding(
            padding: EdgeInsets.only(
                top: helper.lastPadding, left: helper.lastPadding)),
                */
      ],
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
