part of 'jk_appbar.dart';

typedef OnWidgetLayoutChanged = void Function(Offset offset, Size size);

class _JkWidgetLayoutNotifier extends SingleChildRenderObjectWidget {
  final OnWidgetLayoutChanged onLayoutChange;

  const _JkWidgetLayoutNotifier({
    Key? key,
    required this.onLayoutChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _JkWidgetLayoutRenderObject(onLayoutChange);
  }
}

class _JkWidgetLayoutRenderObject extends RenderProxyBox {
  final OnWidgetLayoutChanged onLayoutChange;

  _JkWidgetLayoutRenderObject(this.onLayoutChange);

  @override
  void performLayout() {
    super.performLayout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLayoutChange(localToGlobal(Offset.zero), size);
    });
  }
}
