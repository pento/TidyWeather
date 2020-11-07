import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import '../pages/home.dart';
import '../widgets/drawer.dart';
import '../widgets/weatherGradient.dart';

class FadingAppBarScaffold extends StatefulWidget {
  const FadingAppBarScaffold({
    Key key,
    this.body,
    this.title,
    this.weatherCode,
    this.controller,
  }) : super(key: key);

  final Widget body;
  final String title;
  final String weatherCode;
  final ScrollController controller;

  @override
  State<StatefulWidget> createState() => FadingAppBarScaffoldState();
}

class FadingAppBarScaffoldState extends State<FadingAppBarScaffold> {
  double _opacity;

  @override
  void initState() {
    super.initState();
    _opacity = 0;
    widget.controller.addListener(_updateOpacity);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateOpacity);
    super.dispose();
  }

  void _updateOpacity() {
    double newOpacity;
    if (widget.controller.position.pixels >= 200) {
      newOpacity = 1;
    } else {
      newOpacity = widget.controller.position.pixels / 200;
    }

    if (_opacity != newOpacity) {
      setState(() => _opacity = newOpacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.body,
      drawer: buildDrawer(context, HomePage.route),
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: Text(widget.title),
        gradient: weatherGradient(context, widget.weatherCode, _opacity),
        elevation: 0,
      ),
    );
  }
}
