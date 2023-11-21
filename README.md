# jk_custom_appbar

Easy to use any custom widget as app bar / bottom bar. Support floating / pinned bars with scrolling behavior. Support in horizontal screen.

<img src="https://github.com/jakky1/jk_custom_appbar/releases/download/screenshot/jk_appbar_vertical_demo.gif" style="width:200px;"/>

## Features

- Support bottom bar / app bar.
- Use any custom widget as app bar / bottom bar.
- Support reverse scrolling.
- Support image background in app bar.
- Support in horizontal mode.

# Quick Start

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  jk_custom_appbar: ^1.0.0
```

# Usage

## Custom app bar / bottom bar

Both `appBar` and `bottomBar` can be expanded / collapsed during scrolling.

But `appBarPinned` and `bottomBarPinned` will not be expanded / collapsed during scrolling, and always shown on screen.

All these bars can be `null` (not shown) or put any your custom widget.

```
var layout = JkAppBarLayout(
  appBar: Text("custom appBar widget here"),                   // optional
  appBarPinned: Text("custom appBarPinned widget here"),       // optional
  bottomBar: Text("custom bottomBar widget here"),             // optional
  bottomBarPinned: Text("custom bottomBarPinned widget here"), // optional
);
```

## Show ListView / GridView as content (Important !)

To show a ListView / GridView / SingleChildScrollView as content, we need to use `JkAppBarListView` / `JkAppBarGridView` / `JkAppBarSingleChildScrollView`.

The API of all the new three classes are all the same with flutter official classes, but only the class name changes.

NOTE: use flutter official ListView / GridView / SingleChildScrollView won't make app bars expand/collapse.

```
var layout = JkAppBarLayout(
  ...
  child: JkAppBarListView.builder( // API are the same with ListView
    itemCount: 300,
    itemBuilder: (context, index) => Text("List Item $index"),
  ),
);
```

```
var layout = JkAppBarLayout(
  ...
  child: JkAppBarGridView.builder( // API are the same with GridView
    itemCount: 300,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisExtent: 30),
    itemCount: 300,
    itemBuilder: (context, index) => Text("Grid Item $index"),
  ),
);
```

```
var layout = JkAppBarLayout(
  ...
  child: JkAppBarSingleChildScrollView( // API are the same with SingleChildScrollView
    child: Column(
      children: List.generate(100, (index) => Text("Column $index")),
    ),
  ),
);
```

## Snapping & Floating

`floating`=true means the `appBar` and `bottomBar` will be expanded anywhere when scrolling backward.

`floating`=false means the `appBar` and `bottomBar` ONLY be expanded anywhere when scrolling back to beginning of list.

`snap`=true means the `appBar` and `bottomBar` will be automatically expanded/collapseed when tapUp if bars not fully expanded/collapsed.

```
var layout = JkAppBarLayout(
  ...
  floating: true,
  snap: true,
);
```

## Image background

Return an Image widget in `appBarBackgroundBuilder` to show an image as background of `appBar`.

`appBarBackgroundBuilder` is called every time when collapsed size changed, so typically we can make a fading effect for the image background here.

Set `backgroundIncludingAppBarPinned` as `true` makes the image also covers the area of `appBarPinned`.

```
var layout = JkAppBarLayout(
  ...
  backgroundIncludingAppBarPinned: true,
  appBarBackgroundBuilder: (collapsedRatio) {
    return Opacity(
      opacity: 1 - collapsedRatio,
      child: Image.asset("assets/your_background.jpg",
        fit: BoxFit.cover));
  },
);
```

## Colored background

By default, we apply the color of system default AppBar as background.

You can customize the color by `appBarBackgroundColor`:

```
var layout = JkAppBarLayout(
  ...
  appBarBackgroundColor: Colors.green,
);
```

## Default text size/color and icon color

By default, all the text size/color and icon color on the `appBar`, `appBarPinned`, `bottomBar`, `bottomBarPinned` will be the same with default system AppBar.

If you want to ignore these default theme/style, set `appBarDefaultTheme` as false:

```
var layout = JkAppBarLayout(
  ...
  appBarDefaultTheme: false,
);
```

## Horizontal support

Set `scrollDirection` as `Axis.horizontal` to show app bars in horizontal mode.

Don't forget to set the `scrollDirection` in `JkAppBarListView` / `JkAppBarGridView` / `JkAppBarSingleChildScrollView` at the same time.

```
var layout = JkAppBarLayout(
  ...
  scrollDirection: Axis.horizontal,

  child: JkAppBarListView.builder(
    scrollDirection: Axis.horizontal,    // Don't forget this
    itemCount: 300,
    itemBuilder: (context, index) => Text("List Item $index"),
  ),
);
```

## Sample code

```
import 'package:flutter/material.dart';
import 'package:jk_custom_appbar/jk_appbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Widget child = JkAppBarLayout(
      appBar: Text("appBar"),                   // optional
      appBarPinned: Text("appBarPinned"),       // optional
      bottomBarPinned: Text("bottomBarPinned"), // optional
      bottomBar: Text("bottomBar"),             // optional
      child: JkAppBarListView.builder(
        itemCount: 300,
        itemBuilder: (_, index) => Text("Item $index"),
      )
    );

    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
```
