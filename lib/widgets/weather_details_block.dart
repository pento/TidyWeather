import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WeatherDetailsBlock extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Text title;
  final Widget text;
  final Widget subtext;

  /// Constructor.
  const WeatherDetailsBlock(
      {Key key, this.icon, this.iconColor, this.title, this.text, this.subtext})
      : super(key: key);

  @override
  _WeatherDetailsBlockState createState() => _WeatherDetailsBlockState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('iconColor', iconColor))
      ..add(DiagnosticsProperty<IconData>('icon', icon));
  }
}

class _WeatherDetailsBlockState extends State<WeatherDetailsBlock> {
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onLongPress: _toggleCard,
          onTap: _toggleCard,
          child: FlipCard(
              key: _cardKey,
              direction: FlipDirection.VERTICAL,
              flipOnTouch: false,
              front: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: widget.iconColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          widget.text,
                          widget.subtext,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              back: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: widget.title,
                    ),
                  ],
                ),
              )),
        ),
      );

  void _toggleCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    _cardKey.currentState.toggleCard();
  }
}
