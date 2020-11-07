import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuple/tuple.dart';

import '../data/weather_model.dart';

class SimpleWeatherGraph extends StatelessWidget {
  static const int numberOfEntries = 8;

  final WeatherObservations now;
  final List<WeatherForecastHourlyTemperature> forecast;
  final List<WeatherForecastHourlyRainfall> rainfall;
  final List<WeatherForecastHourlyWind> wind;

  final String display;

  /// Constructor
  const SimpleWeatherGraph({
    Key key,
    this.now,
    this.forecast,
    this.rainfall,
    this.wind,
    this.display
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _data;

    switch (display) {
      case 'wind':
        _data = _prepareWindData();
        break;

      default:
        _data = _prepareTemperatureData();
    }

    return CustomPaint(
      painter: ChartPainter(
        entries: _data,
        rainfall: rainfall,
        display: display,
        context: context,
      ),
    );
  }

  ///
  /// Normalise the wind data into standard data that the graph can use.
  ///
  List<Map<String, dynamic>> _prepareWindData() {
    final DateTime _now = DateTime.now();

    final Map<String, dynamic> _nowTemp = <String, dynamic>{};

    if (wind == null) {
      return <Map<String, dynamic>>[];
    }

    _nowTemp[ 'value' ] = now.wind.speed;
    _nowTemp[ 'direction' ] = now.wind.direction;
    _nowTemp[ 'dateTime' ] = _now;

    final List<Map<String, dynamic>> _data = <Map<String, dynamic>>[ _nowTemp];

    int count = 0;
    return _data + wind.map((WeatherForecastHourlyWind _windDatum) {
      if (count == numberOfEntries - 1) {
        return false;
      }

      if (_windDatum.dateTime.compareTo(_now) < 0) {
        return false;
      }

      if (_windDatum.dateTime.hour % 3 != 0) {
        return false;
      }

      count++;

      final Map<String, dynamic> _datum = <String, dynamic>{};

      _datum[ 'value' ] = _windDatum.speed;
      _datum[ 'direction' ] = _windDatum.direction;
      _datum[ 'dateTime' ] = _windDatum.dateTime;

      return _datum;
    }).whereType<Map<String, dynamic>>().toList();
  }

  ///
  /// Normalise the temperature data into standard data that the graph can use.
  ///
  List<Map<String, dynamic>> _prepareTemperatureData() {
    final DateTime _now = DateTime.now();

    final Map<String, dynamic> _nowTemp = <String, dynamic>{};

    _nowTemp[ 'value' ] = now.temperature.temperature;
    _nowTemp[ 'dateTime' ] = _now;

    final List<Map<String, dynamic>> _data = <Map<String, dynamic>>[ _nowTemp];

    int count = 0;
    return _data + forecast.map(
            (WeatherForecastHourlyTemperature _temperatureDatum) {
          if (count == numberOfEntries - 1) {
            return false;
          }

          if (_temperatureDatum.dateTime.compareTo(_now) < 0) {
            return false;
          }

          if (_temperatureDatum.dateTime.hour % 3 != 0) {
            return false;
          }

          count++;

          final Map<String, dynamic> _datum = <String, dynamic>{};

          _datum[ 'value' ] = _temperatureDatum.temperature;
          _datum[ 'dateTime' ] = _temperatureDatum.dateTime;

          return _datum;
        }
    ).whereType<Map<String, dynamic>>().toList();
  }
}

class ChartPainter extends CustomPainter {
  final List<Map> entries;
  final List<WeatherForecastHourlyRainfall> rainfall;

  final String display;
  final BuildContext context;

  /// Constructor.
  ChartPainter({ this.entries, this.rainfall, this.display, this.context });

  double topPadding;
  double drawingHeight;
  double drawingWidth;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < SimpleWeatherGraph.numberOfEntries) {
      return;
    }

    topPadding = 40;
    drawingHeight = size.height - 50 - topPadding;
    drawingWidth = size.width;

    Tuple2<int, int> borderLineValues = _getMinAndMaxValues(entries);

    _drawVerticalLines(canvas, size);
    _drawBottomLabels(canvas, size);
    _drawLines(canvas, borderLineValues.item1, borderLineValues.item2);
    _drawRainfall(canvas, size);
  }

  Tuple2<int, int> _getMinAndMaxValues(List<Map<String, dynamic>> entries) {
    final double maxTemp = entries.map<double>(
            (Map<String, dynamic> entry) =>
            double.parse(entry[ 'value' ].toString())
    ).reduce(max);
    final double minTemp = entries.map<double>(
            (Map<String, dynamic> entry) =>
            double.parse(entry[ 'value' ].toString())
    ).reduce(min);

    int maxValue = maxTemp.floor();
    int minValue = minTemp.floor();

    maxValue += 1 + ((maxValue - minValue) / 5).ceil();
    minValue -= ((maxValue - minValue) / 10).ceil();

    return Tuple2<int, int>(minValue, maxValue);
  }

  void _drawVerticalLines(Canvas canvas, Size size) {
    final ui.Paint paint = Paint()
      ..color = Colors.grey[ 300 ];

    final double offsetStep = drawingWidth / entries.length;

    canvas.drawLine(
      Offset(0, drawingHeight + topPadding),
      Offset(size.width, drawingHeight + topPadding),
      paint,
    );

    for (int line = 1; line < entries.length; line++) {
      final double xOffset = line * offsetStep;

      canvas.drawLine(
        Offset(xOffset, 0),
        Offset(xOffset, size.height),
        paint,
      );
    }
  }

  void _drawBottomLabels(Canvas canvas, Size size) {
    for (
    int entries = SimpleWeatherGraph.numberOfEntries - 1;
    entries >= 0;
    entries--
    ) {
      final double offsetXbyEntry =
          drawingWidth / SimpleWeatherGraph.numberOfEntries;
      final double offsetX = offsetXbyEntry * entries + offsetXbyEntry / 2;

      final ui.Paragraph paragraph = _buildParagraphForBottomLabel(entries);

      canvas.drawParagraph(
        paragraph,
        Offset(offsetX - 25.0, 17.0 + drawingHeight + topPadding),
      );
    }
  }

  ui.Paragraph _buildParagraphForBottomLabel(int entry) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(fontSize: 14, textAlign: TextAlign.center))
      ..pushStyle(
          ui.TextStyle(color: Theme
              .of(context)
              .textTheme
              .bodyText2
              .color)
      );

    if (entry == 0) {
      builder.addText('Now');
    } else {
      builder.addText(
          Jiffy(entries[ entry ][ 'dateTime' ]).format('H:mm')
      );
    }

    final ui.Paragraph paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 50));

    return paragraph;
  }

  void _drawLines(ui.Canvas canvas, int minLineValue, int maxLineValue) {
    final ui.Paint linePaint = Paint()
      ..color = Colors.grey[ 350 ]
      ..strokeWidth = 2.0;

    final ui.Paint dotPaint = Paint()
      ..strokeWidth = 3.0;

    final DateTime beginningOfChart = DateTime.parse(
        entries[ 0 ][ 'dateTime' ].toString()
    )

    for (int i = 0; i < entries.length - 1; i++) {
      final Offset startEntryOffset = _getLineOffset(
          i,
          i + 1,
          beginningOfChart,
          minLineValue,
          maxLineValue,
          true
      );
      final Offset endEntryOffset = _getLineOffset(
          i + 1,
          i,
          beginningOfChart,
          minLineValue,
          maxLineValue,
          false
      );
      final Offset entryOffset = _getEntryOffset(
          i + 1,
          beginningOfChart,
          minLineValue,
          maxLineValue
      );

      canvas.drawLine(startEntryOffset, endEntryOffset, linePaint);

      dotPaint.color = _convertValueToColor(
          double.parse(entries[ i + 1 ][ 'value' ].toString())
      );

      switch (display) {
        case 'wind':
          _drawWindPoint(entries[ i + 1 ], entryOffset, canvas);
          break;

        default:
          canvas.drawCircle(entryOffset, 3, dotPaint);
      }

      canvas.drawParagraph(
        _buildParagraphForEntry(i + 1),
        _getEntryParagraphOffset(
            i + 1,
            beginningOfChart,
            minLineValue,
            maxLineValue
        ),
      );
    }

    dotPaint.color = _convertValueToColor(
        double.parse(entries.first[ 'value' ].toString())
    );

    switch (display) {
      case 'wind':
        _drawWindPoint(entries.first,
            _getEntryOffset(0, beginningOfChart, minLineValue, maxLineValue),
            canvas);
        break;

      default:
        canvas.drawCircle(
            _getEntryOffset(0, beginningOfChart, minLineValue, maxLineValue),
            3,
            dotPaint
        );
    }

    canvas.drawParagraph(
      _buildParagraphForEntry(0),
      _getEntryParagraphOffset(0, beginningOfChart, minLineValue, maxLineValue),
    );
  }

  ui.Paragraph _buildParagraphForEntry(int entry) {
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: 14.0, textAlign: TextAlign.center))
      ..pushStyle(new ui.TextStyle(
          color: _convertValueToColor(entries[ entry ][ 'value' ])))
      ..addText(entries[ entry ][ 'value' ].floor().toString());


    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: 50.0));

    return paragraph;
  }

  Color _convertValueToColor(double value) {
    Color _color;

    switch (display) {
      case 'wind':
        if (value < 2) {
          _color = Colors.grey.shade300;
        } else if (value < 6) {
          _color = Colors.cyan.shade200;
        } else if (value < 12) {
          _color = Colors.teal.shade200;
        } else if (value < 20) {
          _color = Colors.green.shade200;
        } else if (value < 29) {
          _color = Colors.lightGreen.shade300;
        } else if (value < 39) {
          _color = Colors.lightGreen.shade500;
        } else if (value < 50) {
          _color = Colors.lime.shade500;
        } else if (value < 62) {
          _color = Colors.lime.shade700;
        } else if (value < 75) {
          _color = Colors.amber.shade400;
        } else if (value < 89) {
          _color = Colors.orange.shade400;
        } else if (value < 103) {
          _color = Colors.orange.shade800;
        } else if (value < 118) {
          _color = Colors.red;
        } else {
          _color = Colors.deepPurple;
        }
        break;

      default:
        if (value < 15) {
          _color = Colors.lightBlue;
        } else if (value < 25) {
          _color = Colors.lightGreen;
        } else if (value < 35) {
          _color = Colors.orange;
        } else if (value < 45) {
          _color = Colors.red;
        } else {
          _color = Colors.deepPurple;
        }
    }

    return _color;
  }

  Offset _getLineOffset(int entry, int otherEntry, DateTime beginningOfChart,
      int minLineValue, int maxLineValue, bool start) {
    Offset current = _getEntryOffset(
        entry, beginningOfChart, minLineValue, maxLineValue);
    Offset other = _getEntryOffset(
        otherEntry, beginningOfChart, minLineValue, maxLineValue);

    double lineDistance = drawingWidth / SimpleWeatherGraph.numberOfEntries;
    double lineHeight = (other.dy - current.dy).abs();
    double lineLength = sqrt(pow(lineDistance, 2) + pow(lineHeight, 2));

    double xPoint, yPoint;
    if (start) {
      xPoint = current.dx + (8 * (other.dx - current.dx)) / lineLength;
      yPoint = current.dy + (8 * (other.dy - current.dy)) / lineLength;
    } else {
      xPoint = current.dx - (8 * (current.dx - other.dx)) / lineLength;
      yPoint = current.dy - (8 * (current.dy - other.dy)) / lineLength;
    }

    return new Offset(xPoint, yPoint);
  }

  Offset _getEntryOffset(int entry, DateTime beginningOfChart, int minLineValue,
      int maxLineValue) {
    double columnWidth = drawingWidth / SimpleWeatherGraph.numberOfEntries;
    double xOffset = entry * columnWidth + 0.5 * columnWidth;
    double relativeYposition = (entries[ entry ][ 'value' ] - minLineValue) /
        (maxLineValue - minLineValue);
    double yOffset = drawingHeight - relativeYposition * drawingHeight +
        topPadding;

    return new Offset(xOffset, yOffset);
  }

  Offset _getEntryParagraphOffset(int entry, DateTime beginningOfChart,
      int minLineValue, int maxLineValue) {
    Offset entryOffset = _getEntryOffset(
        entry, beginningOfChart, minLineValue, maxLineValue);

    return new Offset(entryOffset.dx - 25, entryOffset.dy - 30);
  }

  void _drawRainfall(Canvas canvas, Size size) {
    double columnWidth = drawingWidth / SimpleWeatherGraph.numberOfEntries;
    int entry = 0;

    rainfall.forEach((rainfallData) {
      if (rainfallData.dateTime.compareTo(entries[ 0 ][ 'dateTime' ]) < 0) {
        return;
      }

      if (rainfallData.probability == 0) {
        entry++;
        return;
      }

      Paint bubbleStyle = new Paint();
      bubbleStyle.style = PaintingStyle.fill;
      bubbleStyle.color =
          _convertRainfallToBubbleFillColor(rainfallData.probability);

      double left = entry * columnWidth + 0.5 * columnWidth - 16;
      double top = 12;
      double right = entry * columnWidth + 0.5 * columnWidth + 16;
      double bottom = 32;
      Radius radius = Radius.circular(10);

      canvas.drawRRect(
          RRect.fromLTRBR(left, top, right, bottom, radius),
          bubbleStyle
      );

      bubbleStyle.style = PaintingStyle.stroke;
      bubbleStyle.color =
          _convertRainfallToBubbleStrokeColor(rainfallData.probability);

      canvas.drawRRect(
          RRect.fromLTRBR(left, top, right, bottom, radius),
          bubbleStyle
      );

      canvas.drawParagraph(
          _buildParagraphForRainfall(rainfallData.probability),
          new Offset(entry * columnWidth, 15.0)
      );

      entry++;
    });
  }

  void _drawWindPoint(Map datum, Offset entryOffset, Canvas canvas) {
    Paint arrowStyle = new Paint();
    arrowStyle.color = _convertValueToColor(datum[ 'value' ]);

    if (datum[ 'value' ] == 0) {
      canvas.drawCircle(entryOffset, 3.0, arrowStyle);
      return;
    }

    arrowStyle.strokeWidth = 2;

    double radius = 5;

    double endX = entryOffset.dx +
        radius * cos(datum[ 'direction' ] * pi / 180);
    double endY = entryOffset.dy +
        radius * sin(datum[ 'direction' ] * pi / 180);

    double startX = entryOffset.dx +
        radius * cos((datum[ 'direction' ] + 180) * pi / 180);
    double startY = entryOffset.dy +
        radius * sin((datum[ 'direction' ] + 180) * pi / 180);

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), arrowStyle);

    double arrowSize = 1.5;

    double dx = endX - startX;
    double dy = endY - startY;

    double unitDx = dx / radius;
    double unitDy = dy / radius;

    double p1x = endX - unitDx * arrowSize - unitDy * arrowSize;
    double p1y = endY - unitDy * arrowSize + unitDx * arrowSize;

    canvas.drawLine(Offset(p1x, p1y), Offset(endX, endY), arrowStyle);

    double p2x = endX - unitDx * arrowSize + unitDy * arrowSize;
    double p2y = endY - unitDy * arrowSize - unitDx * arrowSize;

    canvas.drawLine(Offset(p2x, p2y), Offset(endX, endY), arrowStyle);
  }

  Color _convertRainfallToBubbleFillColor(int probability) {
    if (probability == 5) {
      return Colors.white;
    }

    int shade = (probability / 20).ceil() * 100;

    return Colors.blue[ shade ];
  }

  Color _convertRainfallToBubbleStrokeColor(int probability) {
    if (probability == 5) {
      return Colors.blue;
    }

    int shade = (probability / 20).ceil() * 100 + 500;

    if (shade > 900) {
      shade = 900;
    }

    return Colors.blue[ shade ];
  }

  ui.Paragraph _buildParagraphForRainfall(int probability) {
    String percentage = probability.toString() + '%';
    Color color = Colors.white;
    if (probability < 40) {
      color = Colors.black;
    }

    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: 12.0, textAlign: TextAlign.center))
      ..pushStyle(new ui.TextStyle(color: color))
      ..addText(percentage);


    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: 50.0));

    return paragraph;
  }

  @override
  bool shouldRepaint(ChartPainter old) => true;
}
