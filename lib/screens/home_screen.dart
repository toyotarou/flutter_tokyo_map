import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/tokyo_municipal_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.tokyoMunicipalList, required this.tokyoMunicipalMap});

  final List<TokyoMunicipalModel> tokyoMunicipalList;
  final Map<String, TokyoMunicipalModel> tokyoMunicipalMap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen> {
  final MapController mapController = MapController();

  TokyoMunicipalModel? selectedTokyoMunicipal;

  ///
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appParamNotifier.setKeepTokyoMunicipalList(list: widget.tokyoMunicipalList);
      appParamNotifier.setKeepTokyoMunicipalMap(map: widget.tokyoMunicipalMap);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text('tokyo municipal list'), SizedBox.shrink()],
            ),

            Divider(color: Colors.white.withOpacity(0.4), thickness: 5),

            Expanded(child: displayTokyoMunicipalList()),

            SizedBox(
              height: context.screenSize.height * 0.6,

              child: FlutterMap(
                mapController: mapController,
                options: const MapOptions(initialCenter: LatLng(35.718532, 139.586639), initialZoom: 10),

                children: <Widget>[
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.step3_bbox_preview',
                  ),

                  if (selectedTokyoMunicipal != null) ...<Widget>[
                    // ignore: always_specify_types
                    PolygonLayer(polygons: makeAreaPolygons(selectedTokyoMunicipal!)),
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
  Widget displayTokyoMunicipalList() {
    final List<Widget> list = <Widget>[];

    for (final TokyoMunicipalModel element in appParamState.keepTokyoMunicipalList) {
      list.add(
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
          ),
          padding: const EdgeInsets.all(5),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedTokyoMunicipal = element;

                    final LatLngBounds bounds = LatLngBounds(
                      LatLng(element.minLat, element.minLng),
                      LatLng(element.maxLat, element.maxLng),
                    );

                    mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(24)));
                  });
                },
                icon: const Icon(Icons.ac_unit),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text(element.name), Text(element.vertexCount.toString())],
              ),

              Text(element.maxLat.toStringAsFixed(5)),
              Text(element.minLng.toStringAsFixed(5)),

              Text(element.maxLat.toStringAsFixed(5)),
              Text(element.maxLng.toStringAsFixed(5)),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => list[index],
            childCount: list.length,
          ),
        ),
      ],
    );
  }
}
