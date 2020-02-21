import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class WeatherDetailsBlock extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Text title;
  final Widget text;
  final Widget subtext;

  WeatherDetailsBlock( { this.icon, this.iconColor, this.title, this.text, this.subtext } );


  @override
  _WeatherDetailsBlockState createState() => _WeatherDetailsBlockState();
}

class _WeatherDetailsBlockState extends State<WeatherDetailsBlock> {

  GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  bool _isFlipped = false;

  @override
  Widget build( BuildContext context ) {
    return  Expanded(
      child: GestureDetector(
        onLongPress: _onLongPress,
        onTap: _onTap,
        child: FlipCard(
            key: _cardKey,
            direction: FlipDirection.VERTICAL,
            flipOnTouch: false,
            front: Container(
              padding: EdgeInsets.symmetric( vertical: 5, horizontal: 12 ),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all( 6 ),
                        decoration: BoxDecoration(
                          color: widget.iconColor,
                          borderRadius: BorderRadius.circular( 20 ),
                        ),

                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only( left: 10 ),
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
              padding: EdgeInsets.symmetric( vertical: 5, horizontal: 12 ),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all( 6 ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular( 20 ),
                        ),

                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only( left: 10 ),
                    child: widget.title,
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

  void _onLongPress() {
    setState( () {
      _isFlipped = ! _isFlipped;
    } );
    _cardKey.currentState.toggleCard();
  }

  void _onTap() {
    if ( _isFlipped ) {
      _onLongPress();
    }
  }
}
