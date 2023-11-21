import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'jk_appbar_listview.dart';
part 'jk_appbar_gridview.dart';
part 'jk_appbar_single_child_scrollview.dart';
part 'jk_appbar_style.dart';
part 'jk_appbar_scrollable_helper.dart';
part 'jk_appbar_controller.dart';
part 'jk_widget_layout_wrapper.dart';
part 'jk_tab_scrollbar.dart';

typedef JkAppBarBackgroundBuilder = Widget Function(double collapsedRatio);

/// A container that manages appBar, bottomBar, and a scrollable child Widget.
/// AppBar will be collapsed/expanded accordding to scrolling offset.
/// All the bars are customizable widgets.
/// The scrollable child must be one of the following widget:
///     * JkAppBarListView (a clone of official ListView but support bars collapsed/expanded)
///     * JkAppBarGridView (a clone of official GridView but support bars collapsed/expanded)
///     * JkAppBarSingleChildScrollView (a clone of official SingleChildScrollView but support bars collapsed/expanded)
/// Any other scrollable widget won't make app bars collapsed/expanded during scrolling.
class JkAppBarLayout extends StatefulWidget {
  final Axis scrollDirection;

  /// Top app bar that can be collapsed/expanded by scrolling.
  /// It's a widget so you can customize it.
  final Widget? appBar;

  /// below [appBar], won't collapsed/expanded, always shown, which known as 'pinned'
  /// It's a widget so you can customize it.
  final Widget? appBarPinned;

  /// Called to build background for [appBar].
  /// Widget return by this function will become the backgroud of [appBar].
  /// If this is set, [appBar] could NOT set background.
  /// This function provide a parameter [collapsedRatio],
  /// which is between 0(fully expanded) and 1(fully collapsed).
  /// You can make some effects (ex. fading) according to 'collapsedRatio'.
  final JkAppBarBackgroundBuilder? appBarBackgroundBuilder;

  /// If true, make widget returned by [appBarBackgroundBuilder] also cover
  /// the area of both [appBarPinned] and [appBar].
  /// This parameter only works if [appBarBackgroundBuilder] provided
  final bool backgroundIncludingAppBarPinned;

  /// bottom bar that can be collapsed/expanded by scrolling.
  /// It's a widget so you can customize it.
  final Widget? bottomBar;

  /// above [bottomBar], won't collapsed/expanded, always shown, which known as 'pinned'
  /// It's a widget so you can customize it.
  final Widget? bottomBarPinned;

  /// Whether the app bar should become visible as soon as the user scrolls towards the beginning of the list.
  final bool floating;

  /// Automatically collapse bar if collapsed ratio >= 50%
  /// Automatically expand bar if collapsed ratio < 50%
  /// false means disable automatically collapse/expand.
  /// It won't work when dragging scrollbar by mouse,
  /// which depends on flutter issue: https://github.com/flutter/flutter/issues/138536
  final bool snap;

  /// enable SafeArea
  final bool applySafeArea;

  final Color? appBarBackgroundColor;
  final bool appBarDefaultTheme;

  /// set to 'true' if there is any [InkWell] effect widget inside.
  /// if not set to 'true', all the [InkWell] effect may be invisible.
  final bool enableInkWell;

  /// A widget shows the content
  final Widget child;

  const JkAppBarLayout(
      {super.key,
      this.appBar,
      this.appBarPinned,
      this.bottomBar,
      this.bottomBarPinned,
      this.appBarBackgroundBuilder,
      this.backgroundIncludingAppBarPinned = false,
      this.floating = true,
      this.snap = true,
      this.scrollDirection = Axis.vertical,
      this.applySafeArea = true,
      this.appBarBackgroundColor,
      this.appBarDefaultTheme = true,
      this.enableInkWell = true,
      required this.child});

  @override
  State<StatefulWidget> createState() => _JkAppBarLayoutState();
}

class _JkAppBarLayoutState extends State<JkAppBarLayout>
    with SingleTickerProviderStateMixin {
  double lastScrollOffset = 0;
  double appBarExtent = 0;
  final appBarPinnedExtent = ValueNotifier<double>(0);
  double bottomBarExtent = 0;
  final bottomBarPinnedExtent = ValueNotifier<double>(0);
  double collapsedExtent = 0;
  final collapsedRatio = ValueNotifier<double>(0);
  double get maxCollapsibleExtent =>
      widget.appBar != null ? appBarExtent : bottomBarExtent;

  // notify to rebuild & translate bars
  final collapsedExtentNotifier = ValueNotifier<double>(0);

  // notify to rebuild JkAppBarLayout
  final barsExtentChangeNotifier = ValueNotifier<int>(0);

  late final AnimationController controller;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
    animation.addListener(animationListener);

    if (widget.snap) {
      log("[JkAppBar] JkAppBarLayout.snap=true won't work when dragging scrollbar by mouse. It depend on flutter issue: https://github.com/flutter/flutter/issues/138536");
    }
  }

  EdgeInsets mediaQueryPadding = EdgeInsets.zero;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mediaQueryPadding = MediaQuery.of(context).padding;
  }

  @override
  void dispose() {
    animation.removeListener(animationListener);
    controller.dispose();
    super.dispose();
  }

  void animationListener() {
    collapsedExtent = animation.value * maxCollapsibleExtent;
    onCollapseExtentChanged();
  }

  Future<void> startCollapseExpandAnimation(bool collapse) async {
    if (collapse) {
      await controller.forward(from: collapsedRatio.value);
    } else {
      await controller.reverse(from: collapsedRatio.value);
    }
  }

  void onScrollEnd(ScrollMetrics metrics) {
    if (widget.snap == false) return;
    if (collapsedRatio.value == 0 || collapsedRatio.value >= 1) return;

    // special case: if the list all content's extent is just a little more than
    // the display extent when bars collapsed,
    // then the list have no enough space let user scroll to collapse all the bars.
    // if user scroll to end, and the bars collapsedRatio < 0.5, then expand all
    if (metrics.maxScrollExtent - metrics.pixels < 2) {
      startCollapseExpandAnimation(true); // force expand bars
    } else {
      startCollapseExpandAnimation(collapsedRatio.value > 0.5);
    }
  }

  void onBarExtentChanged() {
    collapsedExtent = collapsedExtent.clamp(0, maxCollapsibleExtent);
    barsExtentChangeNotifier.value++;
  }

  void onCollapseExtentChanged() {
    collapsedRatio.value =
        maxCollapsibleExtent == 0 ? 0 : collapsedExtent / maxCollapsibleExtent;
    collapsedExtentNotifier.value = collapsedExtent; //rebuild bars offset
  }

  void onScrollChanged(double newScrollOffset) {
    if (lastScrollOffset == newScrollOffset) return;

    double diff = newScrollOffset - lastScrollOffset;
    lastScrollOffset = newScrollOffset;

    if (!widget.floating) {
      if (newScrollOffset > maxCollapsibleExtent && diff < 0) return;
    }

    double newCollapsedExtent = collapsedExtent + diff;
    newCollapsedExtent = newCollapsedExtent.clamp(0, maxCollapsibleExtent);
    if (collapsedExtent != newCollapsedExtent) {
      collapsedExtent = newCollapsedExtent;
      onCollapseExtentChanged();
    }
  }

  Widget myFlex({required List<Widget> children}) {
    return Flex(
        direction: widget.scrollDirection,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children);
  }

  bool get isVertical => widget.scrollDirection == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    Widget child = ValueListenableBuilder<int>(
        valueListenable: barsExtentChangeNotifier,
        builder: (_, __, ___) {
          return _JkAppBarController(
              appBarExpandExtent: appBarExtent,
              bottomBarExpandExtent: bottomBarExtent,
              collapsedRatio: collapsedRatio,
              child: widget.child);
        });

    child = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (widget.scrollDirection == Axis.vertical &&
            notification.metrics.axisDirection != AxisDirection.down &&
            notification.metrics.axisDirection != AxisDirection.up) {
          return true;
        }
        if (widget.scrollDirection == Axis.horizontal &&
            notification.metrics.axisDirection != AxisDirection.right &&
            notification.metrics.axisDirection != AxisDirection.left) {
          return true;
        }
        log("notification.runtimeType: ${notification.runtimeType}, pixels: ${notification.metrics.pixels}");
        switch (notification.runtimeType) {
          case ScrollStartNotification:
            lastScrollOffset = notification.metrics.pixels;
            break;
          case ScrollUpdateNotification:
            if (notification.metrics.pixels == 0) break;
            onScrollChanged(notification.metrics.pixels);
            break;
          case ScrollEndNotification:
            onScrollEnd(notification.metrics);
            break;
          case OverscrollNotification:
            break;
        }
        return true;
      },
      child: child,
    );

    Widget? appBarWrapper;
    if (widget.appBar != null) {
      appBarWrapper = _JkWidgetLayoutNotifier(
        onLayoutChange: (_, size) {
          if (widget.appBar == null) return;
          double newExtent = isVertical ? size.height : size.width;
          if (appBarExtent != newExtent) {
            appBarExtent = newExtent;
            onBarExtentChanged();
          }
        },
        child: widget.appBar!,
      );
      appBarWrapper = ValueListenableBuilder<double>(
          valueListenable: collapsedExtentNotifier,
          child: appBarWrapper,
          builder: (_, __, child) {
            return Opacity(opacity: 1 - collapsedRatio.value, child: child);
          });
    } else if (appBarExtent != 0) {
      appBarExtent = 0;
      onBarExtentChanged();
    }

    Widget? appBarPinnedWrapper;
    if (widget.appBarPinned != null) {
      appBarPinnedWrapper = _JkWidgetLayoutNotifier(
        onLayoutChange: (_, size) {
          if (widget.appBarPinned == null) return;
          double newExtent = isVertical ? size.height : size.width;
          if (appBarPinnedExtent.value != newExtent) {
            appBarPinnedExtent.value = newExtent;
            onBarExtentChanged();
          }
        },
        child: widget.appBarPinned!,
      );
    } else if (appBarPinnedExtent.value != 0) {
      appBarPinnedExtent.value = 0;
      onBarExtentChanged();
    }

    Widget? bottomBarWrapper;
    if (widget.bottomBar != null) {
      bottomBarWrapper = _JkWidgetLayoutNotifier(
        onLayoutChange: (_, size) {
          double newExtent = isVertical ? size.height : size.width;
          if (bottomBarExtent != newExtent) {
            bottomBarExtent = newExtent;
            onBarExtentChanged();
          }
        },
        child: widget.bottomBar!,
      );
    } else if (bottomBarExtent != 0) {
      bottomBarExtent = 0;
      onBarExtentChanged();
    }

    Widget? bottomBarPinnedWrapper;
    if (widget.bottomBarPinned != null) {
      bottomBarPinnedWrapper = _JkWidgetLayoutNotifier(
        onLayoutChange: (_, size) {
          double newExtent = isVertical ? size.height : size.width;
          if (bottomBarPinnedExtent.value != newExtent) {
            bottomBarPinnedExtent.value = newExtent;
            onBarExtentChanged();
          }
        },
        child: widget.bottomBarPinned!,
      );
    } else if (bottomBarPinnedExtent.value != 0) {
      bottomBarPinnedExtent.value = 0;
      onBarExtentChanged();
    }

    double safeAreaListPaddingTop =
        widget.scrollDirection == Axis.horizontal ? 0 : mediaQueryPadding.top;
    var topChildPadding = ValueListenableBuilder(
        valueListenable: appBarPinnedExtent,
        builder: (_, __, ___) {
          return SizedBox(
              width: appBarPinnedExtent.value + safeAreaListPaddingTop,
              height: appBarPinnedExtent.value + safeAreaListPaddingTop);
        });

    var bottomChildPadding = ValueListenableBuilder(
        valueListenable: bottomBarPinnedExtent,
        builder: (_, __, ___) {
          return SizedBox(
              width: bottomBarPinnedExtent.value,
              height: bottomBarPinnedExtent.value);
        });

    Widget? appBarsUserBackground;
    if (widget.appBarBackgroundBuilder != null &&
        (appBarWrapper != null ||
            (widget.backgroundIncludingAppBarPinned &&
                appBarPinnedWrapper != null))) {
      appBarsUserBackground = ValueListenableBuilder<double>(
          valueListenable: collapsedRatio,
          builder: (context, _, child) {
            return widget.appBarBackgroundBuilder!(collapsedRatio.value);
          });

      if (!widget.backgroundIncludingAppBarPinned) {
        if (isVertical) {
          appBarsUserBackground = Padding(
              padding: EdgeInsets.only(bottom: appBarPinnedExtent.value),
              child: appBarsUserBackground);
        } else {
          appBarsUserBackground = Padding(
              padding: EdgeInsets.only(right: appBarPinnedExtent.value),
              child: appBarsUserBackground);
        }
      }
    }

    Widget? appBarsAll;
    if (appBarWrapper != null || appBarPinnedWrapper != null) {
      appBarsAll = myFlex(
        children: [
          if (appBarWrapper != null) appBarWrapper,
          if (appBarPinnedWrapper != null) appBarPinnedWrapper,
        ],
      );

      if (widget.applySafeArea && isVertical) {
        appBarsAll = SafeArea(child: appBarsAll);
      }

      if (widget.appBarDefaultTheme) {
        appBarsAll = _JkAppBarStyle(
            enableInkWell: widget.enableInkWell,
            backgroundColor: appBarsUserBackground == null
                ? widget.appBarBackgroundColor
                : Colors.transparent,
            child: appBarsAll);
      } else {
        if (appBarsUserBackground != null && widget.enableInkWell) {
          appBarsAll =
              Material(type: MaterialType.transparency, child: appBarsAll);
        }
      }

      appBarsAll = Stack(
        children: [
          if (widget.appBarDefaultTheme)
            Positioned.fill(
                child: _JkAppBarStyle(
                    enableInkWell: widget.enableInkWell,
                    backgroundColor: widget.appBarBackgroundColor,
                    child: const SizedBox())),
          if (!widget.appBarDefaultTheme &&
              widget.appBarBackgroundColor != null)
            Positioned.fill(
                child: Container(color: widget.appBarBackgroundColor)),
          if (appBarsUserBackground != null)
            Positioned.fill(child: appBarsUserBackground),
          appBarsAll,
        ],
      );

      if (appBarWrapper != null) {
        appBarsAll = ValueListenableBuilder<double>(
            valueListenable: collapsedExtentNotifier,
            child: appBarsAll,
            builder: (_, __, child) {
              double dx = isVertical ? 0 : collapsedRatio.value * appBarExtent;
              double dy = !isVertical ? 0 : collapsedRatio.value * appBarExtent;
              return Transform.translate(
                  offset: Offset(-dx, -dy), child: child);
            });
      }
    }

    Widget? bottomBarsAll;
    if (bottomBarPinnedWrapper != null || bottomBarWrapper != null) {
      bottomBarsAll = myFlex(children: [
        if (bottomBarPinnedWrapper != null) bottomBarPinnedWrapper,
        if (bottomBarWrapper != null) bottomBarWrapper,
      ]);
      bottomBarsAll = _JkAppBarStyle(
          enableInkWell: widget.enableInkWell,
          backgroundColor: widget.appBarBackgroundColor,
          applyAppBarTheme: widget.appBarDefaultTheme,
          child: bottomBarsAll);
      if (bottomBarWrapper != null) {
        bottomBarsAll = ValueListenableBuilder<double>(
            valueListenable: collapsedExtentNotifier,
            child: bottomBarsAll,
            builder: (_, __, child) {
              double dx =
                  isVertical ? 0 : collapsedRatio.value * bottomBarExtent;
              double dy =
                  !isVertical ? 0 : collapsedRatio.value * bottomBarExtent;
              return Transform.translate(offset: Offset(dx, dy), child: child);
            });
      }
    }

    Widget bars = myFlex(
      children: [
        if (appBarsAll != null) appBarsAll,
        const Expanded(child: SizedBox()),
        if (bottomBarsAll != null) bottomBarsAll,
      ],
    );

    child = myFlex(
      children: [
        topChildPadding,
        Expanded(child: child),
        bottomChildPadding,
      ],
    );

    child = Stack(
      fit: StackFit.expand,
      children: [
        child,
        bars,
      ],
    );

    if (widget.applySafeArea && !isVertical) {
      child = SafeArea(child: child);
    }

    return child;
  }
}
