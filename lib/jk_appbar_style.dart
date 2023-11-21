part of 'jk_appbar.dart';

class _JkAppBarStyle extends StatelessWidget {
  final Widget child;

  /// set to 'true' if there is any [InkWell] effect widget inside.
  /// if not set to 'true', all the [InkWell] effect may be invisible.
  final bool enableInkWell;
  final Color? backgroundColor;
  final bool applyAppBarTheme;

  const _JkAppBarStyle(
      {required this.child,
      this.enableInkWell = true,
      this.backgroundColor,
      this.applyAppBarTheme = true});

  @override
  Widget build(BuildContext context) {
    final appBarTheme = AppBarTheme.of(context);
    final theme = Theme.of(context);

    Color? bgColor = appBarTheme.backgroundColor;
    bgColor ??= theme.useMaterial3
        //? theme.colorScheme.surface
        ? theme.colorScheme.surface
        : theme.colorScheme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.colorScheme.primary;
    //bgColor = MaterialStateProperty.resolveAs<Color?>(bgColor, {MaterialState.scrolledUnder});

    Color? surfaceTintColor = appBarTheme.surfaceTintColor;
    surfaceTintColor ??=
        theme.useMaterial3 ? theme.colorScheme.surfaceTint : null;

    double? effectiveElevation = appBarTheme.scrolledUnderElevation;
    effectiveElevation ??= theme.useMaterial3 ? 3 : 4;

    Color? fgColor = appBarTheme.foregroundColor;
    fgColor ??= theme.useMaterial3
        ? theme.colorScheme.onSurface
        : theme.colorScheme.brightness == Brightness.dark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onPrimary;

    TextStyle? titleTextStyle = appBarTheme.titleTextStyle;
    titleTextStyle ??= theme.textTheme.titleLarge?.copyWith(color: fgColor);

    Widget body = child;

    if (applyAppBarTheme) {
      body = DefaultTextStyle(style: titleTextStyle!, child: body);
    }

    if (applyAppBarTheme) {
      body = IconTheme.merge(data: IconThemeData(color: fgColor), child: body);
    }

    //body = Padding(padding: EdgeInsets.only(left: 4, right: 4), child: body);
    // use Material instead of Container enables splash effect of IconButton in Material2
    if (backgroundColor != null) {
      if (enableInkWell) {
        body = Material(type: MaterialType.transparency, child: body);
      }
      body = Container(color: backgroundColor, child: body);
    } else if (enableInkWell) {
      body = Material(
          type: applyAppBarTheme
              ? MaterialType.canvas
              : MaterialType.transparency,
          color: bgColor,
          surfaceTintColor: surfaceTintColor,
          elevation: 3,
          child: body);
    } else if (applyAppBarTheme) {
      body = Container(color: bgColor, child: body);
    }

    return body;
  }
}
