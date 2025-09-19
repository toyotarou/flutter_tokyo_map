import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/controllers_mixin.dart';
import '../models/tokyo_municipal_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.tokyoMunicipalList, required this.tokyoMunicipalMap});

  final List<TokyoMunicipalModel> tokyoMunicipalList;
  final Map<String, TokyoMunicipalModel> tokyoMunicipalMap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen> {
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
          ],
        ),
      ),
    );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text(element.name), Text(element.vertexCount.toString())],
              ),

              Text(element.maxLat.toStringAsFixed(5)),
              Text(element.minLng.toStringAsFixed(5)),

              Text(element.maxLat.toStringAsFixed(5)),
              Text(element.maxLng.toStringAsFixed(5)),

              Text(element.centroidLat.toStringAsFixed(5)),
              Text(element.centroidLng.toStringAsFixed(5)),
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
