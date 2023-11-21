part of 'jk_appbar.dart';

typedef TabScrollControllerGetter = ScrollController Function(int tabIndex);

class JkTabScrollbar extends StatefulWidget {
  final TabController tabController;
  final TabScrollControllerGetter scrollControllerGet;
  final Widget child;

  const JkTabScrollbar(
      {super.key,
      required this.child,
      required this.tabController,
      required this.scrollControllerGet});

  @override
  State<JkTabScrollbar> createState() => _JkTabScrollbarState();
}

class _JkTabScrollbarState extends State<JkTabScrollbar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(onTabChanged);
    super.dispose();
  }

  void onTabChanged() {
    log("tab changed: ${widget.tabController.index}, isChangeing: ${widget.tabController.indexIsChanging}");
    if (widget.tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int tabIndex = widget.tabController.index;
    var scrollController = widget.scrollControllerGet(tabIndex);
    return Scrollbar(controller: scrollController, child: widget.child);
  }
}
