import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuple/tuple.dart';

import '../data/weather_model.dart';

class SimpleWeatherGraph extends StatelessWidget {
  static const int NUMBER_OF_ENTRIES = 8;

  final WeatherObservationsTemperature now;
  final List<WeatherForecastHourlyTemperature> forecast;
  final List<WeatherForecastHourlyRainfall> rainfall;
  final List<WeatherForecastHourlyWind> wind;

  SimpleWeatherGraph( this.now, this.forecast, this.rainfall, this.wind );

  @override
  Widget build( BuildContext context ) {
    return new CustomPaint(
      painter: new ChartPainter( _prepareEntryList( forecast ), rainfall, wind, context ),
    );
  }

  List<WeatherForecastHourlyTemperature> _prepareEntryList( List<WeatherForecastHourlyTemperature> initialEntries ) {
    DateTime _now = DateTime.now();
    WeatherForecastHourlyTemperature _nowForecast = new WeatherForecastHourlyTemperature.fromValues(
      now.temperature,
      _now,
    );
    List<WeatherForecastHourlyTemperature> _current = [ _nowForecast ];

    int count = 0;
    List<WeatherForecastHourlyTemperature> entries = _current + initialEntries
        .where( ( entry ) {
          if ( count == NUMBER_OF_ENTRIES - 1 ) {
            return false;
          }

          if ( entry.dateTime.compareTo( _now ) < 0 ) {
            return false;
          }

          if ( entry.dateTime.hour % 3 == 0 ) {
            if ( count == 0 ) {
              _current.first.dateTime = entry.dateTime.subtract( Duration( hours: 3 ) );
            }
            count++;
            return true;
          }

          return false;
        } )
        .toList();

    return entries;
  }
}

class ChartPainter extends CustomPainter {
  final List<WeatherForecastHourlyTemperature> entries;
  final List<WeatherForecastHourlyRainfall> rainfall;
  final List<WeatherForecastHourlyWind> wind;
  final BuildContext context;

  ChartPainter( this.entries, this.rainfall, this.wind, this.context );

  double topPadding;
  double drawingHeight;
  double drawingWidth;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  @override
  void paint( Canvas canvas, Size size ) {
    if ( entries.length < SimpleWeatherGraph.NUMBER_OF_ENTRIES ) {
      return;
    }

    topPadding = 40;

    if ( wind != null ) {
      topPadding += 40;
    }

    drawingHeight = size.height - 50 - topPadding;
    drawingWidth = size.width;

    Tuple2<int, int> borderLineValues = _getMinAndMaxValues( entries );

    _drawVerticalLines( canvas, size );
    _drawBottomLabels( canvas, size );
    _drawLines( canvas, borderLineValues.item1, borderLineValues.item2 );
    _drawRainfall( canvas, size );
    _drawWind( canvas, size );
  }

  Tuple2<int, int> _getMinAndMaxValues( List<WeatherForecastHourlyTemperature> entries ) {
    double maxTemp = entries.map( ( entry ) => entry.temperature ).reduce( max );
    double minTemp = entries.map( ( entry ) => entry.temperature ).reduce( min );

    int maxValue = maxTemp.floor();
    int minValue = minTemp.floor();

    maxValue += 1 + ( ( maxValue - minValue ) / 5 ).ceil();
    minValue -= ( ( maxValue - minValue ) / 10 ).ceil();

    return new Tuple2( minValue, maxValue );
  }

  void _drawVerticalLines( Canvas canvas, Size size ) {
    final paint = new Paint()
      ..color = Colors.grey[ 300 ];

    double offsetStep = drawingWidth / entries.length;

    canvas.drawLine(
      new Offset( 0, drawingHeight + topPadding ),
      new Offset( size.width, drawingHeight + topPadding ),
      paint,
    );

    for ( int line = 1; line < entries.length; line++ ) {
      double xOffset = line * offsetStep;

      _drawVerticalLine( canvas, xOffset, size, paint );
    }
  }


  void _drawVerticalLine( ui.Canvas canvas, double xOffset, ui.Size size, ui.Paint paint ) {
    canvas.drawLine(
      new Offset( xOffset, 0 ),
      new Offset( xOffset, size.height ),
      paint,
    );
  }

  void _drawBottomLabels( Canvas canvas, Size size ) {
    for ( int entries = SimpleWeatherGraph.NUMBER_OF_ENTRIES - 1; entries >= 0; entries-- ) {
      double offsetXbyEntry = drawingWidth / SimpleWeatherGraph.NUMBER_OF_ENTRIES;
      double offsetX = offsetXbyEntry * entries + offsetXbyEntry / 2;

      ui.Paragraph paragraph = _buildParagraphForBottomLabel( entries );

      canvas.drawParagraph(
        paragraph,
        new Offset( offsetX - 25.0, 17.0 + drawingHeight + topPadding ),
      );
    }
  }

  ui.Paragraph _buildParagraphForBottomLabel( int entry ) {
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle( fontSize: 14.0, textAlign: TextAlign.center ) )
      ..pushStyle( new ui.TextStyle( color: Theme.of( context ).textTheme.body1.color ) );

    if ( entry == 0 ) {
      builder.addText( 'Now' );
    } else {
      builder.addText( Jiffy( entries[ entry ].dateTime ).format( 'H:mm' ) );
    }

    final ui.Paragraph paragraph = builder.build()
      ..layout( new ui.ParagraphConstraints( width: 50.0 ) );

    return paragraph;
  }

  void _drawLines( ui.Canvas canvas, int minLineValue, int maxLineValue ) {
    final linePaint = new Paint()
      ..color = Colors.grey[ 350 ]
      ..strokeWidth = 2.0;

    Paint dotPaint = new Paint()
      ..strokeWidth = 3.0;

    DateTime beginningOfChart = entries[ 0 ].dateTime;

    for ( int i = 0; i < entries.length - 1; i++ ) {
      Offset startEntryOffset = _getLineOffset( i, i + 1, beginningOfChart, minLineValue, maxLineValue, true );
      Offset endEntryOffset = _getLineOffset( i + 1, i, beginningOfChart, minLineValue, maxLineValue, false );
      Offset entryOffset = _getEntryOffset( i + 1, beginningOfChart, minLineValue, maxLineValue );

      canvas.drawLine( startEntryOffset, endEntryOffset, linePaint );

      dotPaint.color = convertTempToColor( entries[ i + 1 ].temperature );
      canvas.drawCircle( entryOffset, 3.0, dotPaint );

      canvas.drawParagraph(
        _buildParagraphForEntry( i + 1 ),
        _getEntryParagraphOffset( i + 1, beginningOfChart, minLineValue, maxLineValue ),
      );
    }

    dotPaint.color = convertTempToColor( entries.first.temperature );
    canvas.drawCircle(
        _getEntryOffset( 0, beginningOfChart, minLineValue, maxLineValue ),
        3.0,
        dotPaint
    );

    canvas.drawParagraph(
      _buildParagraphForEntry( 0 ),
      _getEntryParagraphOffset( 0, beginningOfChart, minLineValue, maxLineValue ),
    );
  }

  ui.Paragraph _buildParagraphForEntry( int entry ) {
    String temperature;
    if ( entry == 0 ) {
      temperature = entries[ entry ].temperature.toString();
    } else {
      temperature = entries[ entry ].temperature.floor().toString();
    }
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle( fontSize: 14.0, textAlign: TextAlign.center ) )
      ..pushStyle( new ui.TextStyle( color: convertTempToColor( entries[ entry ].temperature ) ) )
      ..addText( temperature );


    final ui.Paragraph paragraph = builder.build()
      ..layout( new ui.ParagraphConstraints( width: 50.0 ) );

    return paragraph;
  }

  Color convertTempToColor( double temp ) {
    MaterialColor _color;

    if ( temp < 15 ) {
      _color = Colors.lightBlue;
    } else if ( temp < 25 ) {
      _color = Colors.lightGreen;
    } else if ( temp < 35 ) {
      _color = Colors.orange;
    } else if ( temp < 45 ) {
      _color = Colors.red;
    } else {
      _color = Colors.deepPurple;
    }

    return _color;
  }

  Offset _getLineOffset( int entry, int otherEntry, DateTime beginningOfChart, int minLineValue, int maxLineValue, bool start ) {
    Offset current = _getEntryOffset( entry, beginningOfChart, minLineValue, maxLineValue );
    Offset other = _getEntryOffset( otherEntry, beginningOfChart, minLineValue, maxLineValue );

    double lineDistance = drawingWidth / SimpleWeatherGraph.NUMBER_OF_ENTRIES;
    double lineHeight = ( other.dy - current.dy ).abs();
    double lineLength = sqrt( pow( lineDistance, 2 ) + pow( lineHeight, 2 ) );

    double xPoint, yPoint;
    if ( start ) {
      xPoint = current.dx + ( 8 * ( other.dx - current.dx ) ) / lineLength;
      yPoint = current.dy + ( 8 * ( other.dy - current.dy ) ) / lineLength;
    } else {
      xPoint = current.dx - ( 8 * ( current.dx - other.dx ) ) / lineLength;
      yPoint = current.dy - ( 8 * ( current.dy - other.dy ) ) / lineLength;
    }

    return new Offset( xPoint, yPoint );
  }

  Offset _getEntryOffset( int entry, DateTime beginningOfChart, int minLineValue, int maxLineValue ) {
    double columnWidth = drawingWidth / SimpleWeatherGraph.NUMBER_OF_ENTRIES;
    double xOffset = entry * columnWidth + 0.5 * columnWidth;
    double relativeYposition = ( entries[ entry ].temperature - minLineValue ) / ( maxLineValue - minLineValue );
    double yOffset = drawingHeight - relativeYposition * drawingHeight + topPadding;

    return new Offset( xOffset, yOffset );
  }

  Offset _getEntryParagraphOffset( int entry, DateTime beginningOfChart, int minLineValue, int maxLineValue ) {
    Offset entryOffset = _getEntryOffset( entry, beginningOfChart, minLineValue, maxLineValue );

    return new Offset( entryOffset.dx - 25, entryOffset.dy - 30 );
  }

  void _drawRainfall( Canvas canvas, Size size ) {
    double columnWidth = drawingWidth / SimpleWeatherGraph.NUMBER_OF_ENTRIES;
    int entry = 0;

    rainfall.forEach( ( rainfallData ) {
      if ( rainfallData.dateTime.compareTo( entries [ 0 ].dateTime ) < 0 ) {
        return;
      }

      if ( rainfallData.probability == 0 ) {
        return;
      }

      Paint bubbleStyle = new Paint();
      bubbleStyle.style = PaintingStyle.fill;
      bubbleStyle.color = _convertRainfallToBubbleFillColor( rainfallData.probability );

      double left = entry * columnWidth + 0.5 * columnWidth - 16;
      double top = 42;
      double right = entry * columnWidth + 0.5 * columnWidth + 16;
      double bottom = 62;
      Radius radius = Radius.circular( 10 );

      canvas.drawRRect(
          RRect.fromLTRBR( left, top, right, bottom, radius ),
          bubbleStyle
      );

      bubbleStyle.style = PaintingStyle.stroke;
      bubbleStyle.color = _convertRainfallToBubbleStrokeColor( rainfallData.probability );

      canvas.drawRRect(
          RRect.fromLTRBR( left, top, right, bottom, radius ),
          bubbleStyle
      );

      canvas.drawParagraph(
          _buildParagraphForRainfall( rainfallData.probability ),
          new Offset( entry * columnWidth, 45.0 )
      );

      entry++;
    } );
  }

  void _drawWind( Canvas canvas, Size size ) {
    double columnWidth = drawingWidth / SimpleWeatherGraph.NUMBER_OF_ENTRIES;
    int entry = 0;

    if ( wind == null ) {
      return;
    }

    wind.forEach( ( wind ) {
      if ( wind.dateTime.compareTo( entries [ 0 ].dateTime ) < 0 ) {
        return;
      }

      if ( wind.speed == 0 ) {
        return;
      }

      Paint arrowStyle = new Paint();
      arrowStyle.color = Colors.lightGreen;
      arrowStyle.strokeWidth = 2;

      double centerX = entry * columnWidth + 0.2 * columnWidth;
      double centerY = 18;
      double radius = 7;

      double endX = centerX + radius * cos( wind.direction * pi / 180 );
      double endY = centerY + radius * sin( wind.direction * pi / 180 );

      double startX = centerX + radius * cos( ( wind.direction + 180 ) * pi / 180 );
      double startY = centerY + radius * sin( ( wind.direction + 180 ) * pi / 180 );

      canvas.drawLine( Offset( startX, startY ), Offset( endX, endY ), arrowStyle );

      double arrowSize = 2;

      double dx = endX - startX;
      double dy = endY - startY;

      double unitDx = dx / radius;
      double unitDy = dy / radius;

      double p1x = endX - unitDx * arrowSize - unitDy * arrowSize;
      double p1y = endY - unitDy * arrowSize + unitDx * arrowSize;

      canvas.drawLine( Offset( p1x, p1y ), Offset( endX, endY ), arrowStyle );

      double p2x = endX - unitDx * arrowSize + unitDy * arrowSize;
      double p2y = endY - unitDy * arrowSize - unitDx * arrowSize;

      canvas.drawLine( Offset( p2x, p2y ), Offset( endX, endY ), arrowStyle );

      canvas.drawParagraph(
          _buildParagraphForWind( wind.speed ),
          new Offset( centerX, centerY - 5 )
      );

      entry++;
    } );
  }

  Color _convertRainfallToBubbleFillColor( int probability ) {
    if ( probability == 5 ) {
      return Colors.white;
    }

    int shade = ( probability / 20 ).ceil() * 100;

    return Colors.blue[ shade ];
  }

  Color _convertRainfallToBubbleStrokeColor( int probability ) {
    if ( probability == 5 ) {
      return Colors.blue;
    }

    int shade = ( probability / 20 ).ceil() * 100 + 500;

    if ( shade > 900 ) {
      shade = 900;
    }

    return Colors.blue[ shade ];
  }

  ui.Paragraph _buildParagraphForRainfall( int probability ) {
    String percentage = probability.toString() + '%';
    Color color = Colors.white;
    if ( probability < 40 ) {
      color = Colors.black;
    }

    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle( fontSize: 12.0, textAlign: TextAlign.center ) )
      ..pushStyle( new ui.TextStyle( color: color ) )
      ..addText( percentage );


    final ui.Paragraph paragraph = builder.build()
      ..layout( new ui.ParagraphConstraints( width: 50.0 ) );

    return paragraph;
  }

  ui.Paragraph _buildParagraphForWind( double speed ) {
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle( fontSize: 12.0, textAlign: TextAlign.center ) )
      ..pushStyle( new ui.TextStyle( color: Theme.of( context ).textTheme.body1.color ) )
      ..addText( speed.toString() );


    final ui.Paragraph paragraph = builder.build()
      ..layout( new ui.ParagraphConstraints( width: 50.0 ) );

    return paragraph;
  }

  @override
  bool shouldRepaint( ChartPainter old ) => true;
}
