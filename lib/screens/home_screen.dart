import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/controllers_mixin.dart';
import '../models/temple_model.dart';
import '../models/tokyo_municipal_model.dart';
import '../models/tokyo_train_model.dart';
import 'parts/category_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.tokyoMunicipalList,
    required this.tokyoMunicipalMap,
    required this.tokyoTrainList,
    required this.tokyoStationMap,
    required this.templeList,
    required this.templeMap,
  });

  final List<TokyoMunicipalModel> tokyoMunicipalList;
  final Map<String, TokyoMunicipalModel> tokyoMunicipalMap;

  final List<TokyoTrainModel> tokyoTrainList;
  final Map<String, List<TokyoStationModel>> tokyoStationMap;

  final List<TempleModel> templeList;
  final Map<String, TempleModel> templeMap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen> {
  final MapController mapController = MapController();

  TokyoMunicipalModel? selectedTokyoMunicipal;

  List<TokyoMunicipalModel> sortedTokyoMunicipalList = <TokyoMunicipalModel>[];

  String _category = '区';

  LatLngBounds? tokyoAllBounds;

  ///
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appParamNotifier.setKeepTokyoMunicipalList(list: widget.tokyoMunicipalList);
      appParamNotifier.setKeepTokyoMunicipalMap(map: widget.tokyoMunicipalMap);

      appParamNotifier.setKeepTokyoTrainList(list: widget.tokyoTrainList);
      appParamNotifier.setKeepTokyoStationMap(map: widget.tokyoStationMap);

      appParamNotifier.setKeepTempleList(list: widget.templeList);
      appParamNotifier.setKeepTempleMap(map: widget.templeMap);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  CatButton(
                    label: '23区',
                    selected: _category == '区',
                    onTap: () {
                      mapController.rotate(0);

                      setState(() {
                        _category = '区';
                        selectedTokyoMunicipal = null;
                      });

                      if (tokyoAllBounds != null) {
                        mapController.fitCamera(
                          CameraFit.bounds(bounds: tokyoAllBounds!, padding: const EdgeInsets.all(24)),
                        );
                      }
                    },
                  ),

                  CatButton(
                    label: '26市',
                    selected: _category == '市',
                    onTap: () {
                      mapController.rotate(0);

                      setState(() {
                        _category = '市';
                        selectedTokyoMunicipal = null;
                      });

                      if (tokyoAllBounds != null) {
                        mapController.fitCamera(
                          CameraFit.bounds(bounds: tokyoAllBounds!, padding: const EdgeInsets.all(24)),
                        );
                      }
                    },
                  ),

                  CatButton(
                    label: '町村',
                    selected: _category == '町村',
                    onTap: () {
                      mapController.rotate(0);

                      setState(() {
                        _category = '町村';
                        selectedTokyoMunicipal = null;
                      });

                      if (tokyoAllBounds != null) {
                        mapController.fitCamera(
                          CameraFit.bounds(bounds: tokyoAllBounds!, padding: const EdgeInsets.all(24)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 100, child: displayTokyoMunicipalList()),

            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: const MapOptions(initialCenter: LatLng(35.718532, 139.586639), initialZoom: 10),

                children: <Widget>[
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.step3_bbox_preview',
                  ),

                  if (sortedTokyoMunicipalList.isNotEmpty) ...<Widget>[
                    // ignore: always_specify_types
                    PolygonLayer(
                      polygons: sortedTokyoMunicipalList
                          .expand(
                            (TokyoMunicipalModel r) =>
                                _toPolygonsWithColors(r, const Color(0x22000000), const Color(0x33000000)),
                          )
                          .toList(),
                    ),
                  ],

                  if (selectedTokyoMunicipal != null) ...<Widget>[
                    // ignore: always_specify_types
                    PolygonLayer(polygons: makeAreaPolygons(selectedTokyoMunicipal!)),
                  ],

                  if (selectedTokyoMunicipal != null) ...<Widget>[
                    MarkerLayer(
                      markers: _stationsIn(selectedTokyoMunicipal!).map((TokyoStationModel s) {
                        return Marker(
                          point: LatLng(s.lat, s.lng),

                          width: 168,
                          height: 52,

                          alignment: Alignment.center,

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black26),
                                ),
                                child: const DefaultTextStyle(
                                  style: TextStyle(fontSize: 11, color: Colors.black),
                                  child: Text('', maxLines: 1),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()..asMap().forEach((int i, Marker m) {}),
                    ),
                  ],

                  if (selectedTokyoMunicipal != null) ...<Widget>[
                    MarkerLayer(
                      markers: _stationsIn(selectedTokyoMunicipal!).map((TokyoStationModel s) {
                        return Marker(
                          point: LatLng(s.lat, s.lng),
                          width: 168,
                          height: 52,
                          alignment: Alignment.center,

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black26),
                                ),

                                child: Text(
                                  s.stationName,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  // ignore: always_specify_types
  List<Polygon> makeAreaPolygons(TokyoMunicipalModel tokyoMunicipalModel) {
    // ignore: always_specify_types
    final List<Polygon<Object>> polygonList = <Polygon>[];

    for (final List<List<List<double>>> rings in tokyoMunicipalModel.polygons) {
      if (rings.isEmpty) {
        continue;
      }

      final List<LatLng> outer = rings.first.map((List<double> p) => LatLng(p[1], p[0])).toList();

      final List<List<LatLng>> holes = <List<LatLng>>[];

      for (int i = 1; i < rings.length; i++) {
        holes.add(rings[i].map((List<double> p) => LatLng(p[1], p[0])).toList());
      }

      polygonList.add(
        // ignore: always_specify_types
        Polygon(
          points: outer,
          holePointsList: holes.isEmpty ? null : holes,
          isFilled: true,
          color: const Color(0x33FF0000),
          borderColor: const Color(0xFFFF0000),
          borderStrokeWidth: 1.5,
        ),
      );
    }

    return polygonList;
  }

  ///
  List<LatLng> makeAreaPolygon(TokyoMunicipalModel r) {
    return <LatLng>[
      LatLng(r.minLat, r.minLng),
      LatLng(r.minLat, r.maxLng),
      LatLng(r.maxLat, r.maxLng),
      LatLng(r.maxLat, r.minLng),
    ];
  }

  ///
  List<TokyoMunicipalModel> sortedByZOrder(List<TokyoMunicipalModel> list) {
    if (list.isEmpty) {
      return list;
    }

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final TokyoMunicipalModel m in list) {
      if (m.centroidLat < minLat) {
        minLat = m.centroidLat;
      }

      if (m.centroidLat > maxLat) {
        maxLat = m.centroidLat;
      }

      if (m.centroidLng < minLng) {
        minLng = m.centroidLng;
      }

      if (m.centroidLng > maxLng) {
        maxLng = m.centroidLng;
      }
    }

    int morton(double lat, double lng) {
      final double nx = _normalize(lng, minLng, maxLng);

      final double ny = _normalize(lat, minLat, maxLat);

      return _mortonKey16(nx, ny);
    }

    final List<TokyoMunicipalModel> out = List<TokyoMunicipalModel>.from(list);

    for (final TokyoMunicipalModel m in out) {
      m.zKey = morton(m.centroidLat, m.centroidLng);
    }

    out.sort((TokyoMunicipalModel a, TokyoMunicipalModel b) {
      final int ka = a.zKey ?? 0, kb = b.zKey ?? 0;

      if (ka != kb) {
        return ka.compareTo(kb);
      }

      return a.name.compareTo(b.name);
    });

    return out;
  }

  ///
  double _normalize(double v, double vmin, double vmax) {
    final double d = vmax - vmin;

    if (d == 0) {
      return 0.5;
    }

    return ((v - vmin) / d).clamp(0.0, 1.0);
  }

  ///
  int _mortonKey16(double normX, double normY) {
    final int x = (normX * 65535).round();

    final int y = (normY * 65535).round();

    return _interleave16(x) | (_interleave16(y) << 1);
  }

  ///
  int _interleave16(int n) {
    int x = n & 0xFFFF;

    x = (x | (x << 8)) & 0x00FF00FF;

    x = (x | (x << 4)) & 0x0F0F0F0F;

    x = (x | (x << 2)) & 0x33333333;

    x = (x | (x << 1)) & 0x55555555;

    return x;
  }

  ///
  bool _isMainland(TokyoMunicipalModel r) {
    if (r.centroidLat < 35.0) {
      return false;
    }
    if (r.centroidLng > 140.5) {
      return false;
    }
    return true;
  }

  ///
  Widget displayTokyoMunicipalList() {
    final List<Widget> list = <Widget>[];

    sortedTokyoMunicipalList = sortedByZOrder(appParamState.keepTokyoMunicipalList);

    sortedTokyoMunicipalList = sortedByCategory(sortedTokyoMunicipalList);

    final List<TokyoMunicipalModel> filtered = sortedTokyoMunicipalList.where((TokyoMunicipalModel r) {
      if (_category == '区') {
        return r.name.endsWith('区');
      }

      if (_category == '市') {
        return r.name.endsWith('市');
      }

      return !r.name.endsWith('区') && !r.name.endsWith('市');
    }).toList();

    final List<TokyoMunicipalModel> backgroundRows = sortedTokyoMunicipalList.where(_isMainland).toList();

    tokyoAllBounds = makeTokyoAllBounds(backgroundRows, fallback: sortedTokyoMunicipalList);

    for (final TokyoMunicipalModel element in filtered) {
      list.add(
        GestureDetector(
          onTap: () {
            mapController.rotate(0);

            setState(() {
              selectedTokyoMunicipal = element;

              final LatLngBounds bounds = LatLngBounds(
                LatLng(element.minLat, element.minLng),
                LatLng(element.maxLat, element.maxLng),
              );

              mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(24)));
            });
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(child: Text(element.name, style: const TextStyle(fontSize: 10))),
          ),
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: list),
      ),
    );
  }

  ///
  List<TokyoMunicipalModel> sortedByCategory(List<TokyoMunicipalModel> list) {
    int pri(String n) {
      if (n.endsWith('区')) {
        return 0;
      }

      if (n.endsWith('市')) {
        return 1;
      }

      return 2;
    }

    final List<TokyoMunicipalModel> out = List<TokyoMunicipalModel>.from(list);

    out.sort((TokyoMunicipalModel a, TokyoMunicipalModel b) {
      final int pa = pri(a.name), pb = pri(b.name);

      if (pa != pb) {
        return pa.compareTo(pb);
      }

      final int ka = a.zKey ?? 0, kb = b.zKey ?? 0;

      if (ka != kb) {
        return ka.compareTo(kb);
      }

      return a.name.compareTo(b.name);
    });

    return out;
  }

  ///
  // ignore: always_specify_types
  List<Polygon> _toPolygonsWithColors(TokyoMunicipalModel r, Color fill, Color stroke) {
    // ignore: always_specify_types
    final List<Polygon<Object>> ps = <Polygon>[];

    for (final List<List<List<double>>> rings in r.polygons) {
      if (rings.isEmpty) {
        continue;
      }

      final List<LatLng> outer = rings.first.map((List<double> p) => LatLng(p[1], p[0])).toList();

      final List<List<LatLng>> holes = <List<LatLng>>[];

      for (int i = 1; i < rings.length; i++) {
        holes.add(rings[i].map((List<double> p) => LatLng(p[1], p[0])).toList());
      }

      ps.add(
        // ignore: always_specify_types
        Polygon(
          points: outer,
          holePointsList: holes.isEmpty ? null : holes,
          isFilled: true,
          color: fill,
          borderColor: stroke,
          borderStrokeWidth: 1.0,
        ),
      );
    }

    return ps;
  }

  ///
  LatLngBounds makeTokyoAllBounds(List<TokyoMunicipalModel> list, {List<TokyoMunicipalModel>? fallback}) {
    final List<TokyoMunicipalModel> src = list.isNotEmpty ? list : (fallback ?? list);

    double? minLat, minLng, maxLat, maxLng;

    for (final TokyoMunicipalModel r in src) {
      minLat = (minLat == null) ? r.minLat : (r.minLat < minLat ? r.minLat : minLat);

      maxLat = (maxLat == null) ? r.maxLat : (r.maxLat > maxLat ? r.maxLat : maxLat);

      minLng = (minLng == null) ? r.minLng : (r.minLng < minLng ? r.minLng : minLng);

      maxLng = (maxLng == null) ? r.maxLng : (r.maxLng > maxLng ? r.maxLng : maxLng);
    }

    return LatLngBounds(LatLng(minLat ?? 0, minLng ?? 0), LatLng(maxLat ?? 0, maxLng ?? 0));
  }

  ///
  List<TokyoStationModel> _uniqueStations(List<TokyoStationModel> input) {
    final Map<String, List<TokyoStationModel>> map = <String, List<TokyoStationModel>>{};
    for (final TokyoStationModel s in input) {
      map.putIfAbsent(s.stationName, () => <TokyoStationModel>[]).add(s);
    }

    final List<TokyoStationModel> result = <TokyoStationModel>[];

    for (final MapEntry<String, List<TokyoStationModel>> entry in map.entries) {
      if (entry.value.length == 1) {
        result.add(entry.value.first);
      } else {
        final double avgLat =
            entry.value.map((TokyoStationModel e) => e.lat).reduce((double a, double b) => a + b) / entry.value.length;

        final double avgLng =
            entry.value.map((TokyoStationModel e) => e.lng).reduce((double a, double b) => a + b) / entry.value.length;

        result.add(TokyoStationModel(id: '', stationName: entry.key, address: '', lat: avgLat, lng: avgLng));
      }
    }
    return result;
  }

  ///
  List<TokyoStationModel> _stationsIn(TokyoMunicipalModel r) {
    final List<TokyoStationModel> list = <TokyoStationModel>[];

    appParamState.keepTokyoStationMap.forEach((String key, List<TokyoStationModel> value) {
      // ignore: prefer_foreach
      for (final TokyoStationModel element in value) {
        list.add(element);
      }
    });

    final List<TokyoStationModel> uniqueStations = _uniqueStations(list);

    return uniqueStations.where((TokyoStationModel s) => _pointInMunicipality(s.lat, s.lng, r)).toList();
  }

  ///
  bool _pointInMunicipality(double lat, double lng, TokyoMunicipalModel r) {
    for (final List<List<List<double>>> rings in r.polygons) {
      if (rings.isEmpty) {
        continue;
      }

      final List<List<double>> outer = rings.first;

      if (_pointInRing(lat, lng, outer)) {
        bool inHole = false;

        for (int i = 1; i < rings.length; i++) {
          if (_pointInRing(lat, lng, rings[i])) {
            inHole = true;
            break;
          }
        }

        if (!inHole) {
          return true;
        }
      }
    }

    return false;
  }

  ///
  bool _pointInRing(double lat, double lng, List<List<double>> ring) {
    bool inside = false;

    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final double xi = ring[i][1], yi = ring[i][0];

      final double xj = ring[j][1], yj = ring[j][0];

      final bool intersect =
          ((xi > lat) != (xj > lat)) && (lng < (yj - yi) * (lat - xi) / ((xj - xi) == 0 ? 1e-12 : (xj - xi)) + yi);

      if (intersect) {
        inside = !inside;
      }
    }

    return inside;
  }
}
