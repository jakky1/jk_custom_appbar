// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

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

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final scrollController = ScrollController();
  final scrollControllers = <ScrollController>[
    ScrollController(),
    ScrollController(),
    ScrollController()
  ];
  late final TabController _tabController;
  static const myTabs = <Tab>[
    Tab(text: 'List'),
    Tab(text: 'Grid'),
    Tab(text: 'Column'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget horizontalText(String text) {
    return RotatedBox(quarterTurns: 3, child: Text(text));
  }

  Widget roundedButton(String text) {
    Widget child = TextButton(
      style: ButtonStyle(
          //padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor:
              MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.3)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            //side: BorderSide(color: Colors.red),
          ))),
      onPressed: () {},
      child: Text(text),
    );

    child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
        child: child);
    return child;
  }

  @override
  Widget build(BuildContext context) {
    const Axis scrollDirection = Axis.vertical;
    //const Axis scrollDirection = Axis.horizontal;

    var listView = JkAppBarListView.builder(
      scrollDirection: scrollDirection,
      controller: scrollControllers[0],
      //reverse: true,
      //separatorBuilder: (_, __) => const Divider(),
      //gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //  crossAxisCount: 2, mainAxisExtent: 30),
      itemCount: 300,
      itemBuilder: (context, index) => Text("List Item $index"),
    );
    var gridView = JkAppBarGridView.builder(
      scrollDirection: scrollDirection,
      controller: scrollControllers[1],
      //reverse: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisExtent: 30),
      itemCount: 300,
      itemBuilder: (context, index) => Text("Grid Item $index"),
    );
    var singleChildScrollView = JkAppBarSingleChildScrollView(
        scrollDirection: scrollDirection,
        controller: scrollControllers[2],
        //reverse: true,
        child: Flex(
          direction: scrollDirection,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(100, (index) => Text("Column $index")),
        ));

    Widget tabBar = TabBar(
      controller: _tabController,
      tabs: myTabs,
      isScrollable: true,
    );
    var tabBarView = TabBarView(controller: _tabController, children: [
      listView,
      gridView,
      singleChildScrollView,
      /*
      listView,
      gridView,
      singleChildScrollView,
      listView,
      gridView,
      singleChildScrollView
      */
    ]);

    Widget child = JkAppBarLayout(
      applySafeArea: true,
      scrollDirection: scrollDirection,
      snap: true,
      floating: true,

      //appBar: TextButton(onPressed: () {}, child: Text("AppBar")),
/*
      appBar: AppBar(
        leading: Icon(Icons.call),
        title: Text("This is flutter official AppBar"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.cabin)),
          TextButton(onPressed: () {}, child: Text("button")),
          Icon(Icons.cached),
        ],
      ),*/
      appBar: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(
          "Hairy Woodpecker@pexels",
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 70),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.home, size: 38),
            Icon(Icons.fullscreen, size: 38),
          ],
        )
      ]),
      appBarPinned:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        //Material(color: Colors.transparent, child: IconButton(onPressed: () {}, icon: Icon(Icons.cabin))),
        IconButton(onPressed: () {}, icon: Icon(Icons.call)),
        IconButton(onPressed: () {}, icon: Icon(Icons.star)),
        Expanded(child: SizedBox()),
        Text("Hummingbird"),
        Expanded(child: SizedBox()),
        IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
        IconButton(onPressed: () {}, icon: Icon(Icons.info)),
      ]),
      bottomBarPinned: tabBar,
      bottomBar: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: [
            "Animal",
            "Bird",
            "Butterfly",
            "Fly",
            "Flower",
            "Feather",
            "Color"
          ].map<Widget>((e) => roundedButton(e)).toList())),

      //appBarBackgroundColor: Colors.red,
      backgroundIncludingAppBarPinned: true,
      appBarBackgroundBuilder: (collapsedRatio) {
        return Opacity(
            opacity: 1 - collapsedRatio,
            child: Image.asset("assets/test_appbar_background.jpg",
                fit: BoxFit.cover));
      },

      //child: tabBarView,
      child: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleLarge!, child: tabBarView),
    );

    /*
    child = Scrollbar(
      controller: scrollControllers[0],
      child: child,
    );
    */

    child = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: child);

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        //brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }
}
