import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jiffy/jiffy.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '../data/config.dart';
import '../data/weather_model.dart';

/// A card for showing a rain radar animation.
class RadarCard extends StatefulWidget {
  /// Constructor.
  const RadarCard({Key key}) : super(key: key);

  @override
  _RadarCardState createState() => _RadarCardState();
}

class _RadarCardState extends State<RadarCard> {
  Timer _timer;
  int _mapTicks;
  MapController _mapController;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    setState(() => _mapTicks = 0);

    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (Timer timer) => setState(() => _mapTicks++),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Consumer<WeatherModel>(
          builder: (BuildContext context, WeatherModel weather, Widget child) {
            if (weather.today.radar == null ||
                weather.today.radar.overlays.isEmpty) {
              return Container();
            }

            // Pause for a second on the last image.
            int overlay = _mapTicks != null
                ? _mapTicks % (weather.today.radar.overlays.length + 1)
                : 0;
            if (overlay >= weather.today.radar.overlays.length) {
              overlay = weather.today.radar.overlays.length - 1;
            }

            final LatLng center = LatLng(weather.today.radar.location.latitude,
                weather.today.radar.location.longitude);

            return Column(
              children: <Widget>[
                SizedBox(
                  height: 400,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: center,
                      zoom: 8,
                      minZoom: 7,
                      maxZoom: 9,
                      interactiveFlags: InteractiveFlag.none,
                    ),
                    layers: <LayerOptions>[
                      TileLayerOptions(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/pento/ck8ljtx870q8z1iphvwes27kc/tiles/{z}/{x}/{y}{r}?access_token={accessToken}',
                        additionalOptions: <String, String>{
                          'accessToken': Config().item('mapbox_access_token'),
                        },
                      ),
                      OverlayImageLayerOptions(
                        overlayImages: <OverlayImage>[
                          OverlayImage(
                            bounds: LatLngBounds(
                              LatLng(weather.today.radar.mapMin.latitude,
                                  weather.today.radar.mapMin.longitude),
                              LatLng(weather.today.radar.mapMax.latitude,
                                  weather.today.radar.mapMax.longitude),
                            ),
                            imageProvider: NetworkImage(
                                weather.today.radar.overlays[overlay].url),
                            gaplessPlayback: true,
                          ),
                        ],
                      ),
                      TileLayerOptions(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/pento/ck8mdbur70gb61ipjxtbqmbcp/tiles/{z}/{x}/{y}{r}?access_token={accessToken}',
                        backgroundColor: Colors.transparent,
                        additionalOptions: <String, String>{
                          'accessToken': Config().item('mapbox_access_token'),
                        },
                        fastReplace: true,
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonPadding: const EdgeInsets.all(0),
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _mapController.ready && _mapController.zoom == 9
                                  ? Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.2)
                                  : null),
                      onPressed: () => _mapController.move(center, 9),
                      child: const Text('50km'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _mapController.ready && _mapController.zoom == 8
                                  ? Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.2)
                                  : null),
                      onPressed: () => _mapController.move(center, 8),
                      child: const Text('100km'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _mapController.ready && _mapController.zoom == 7
                                  ? Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.2)
                                  : null),
                      onPressed: () => _mapController.move(center, 7),
                      child: const Text('200km'),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(weather.today.radar.name),
                      ),
                      Text(Jiffy(weather.today.radar.overlays[overlay].dateTime)
                          .fromNow()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
}
