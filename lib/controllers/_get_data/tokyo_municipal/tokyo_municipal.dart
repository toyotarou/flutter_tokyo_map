import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/tokyo_municipal_model.dart';
import '../../../utility/utility.dart';

part 'tokyo_municipal.freezed.dart';

part 'tokyo_municipal.g.dart';

@freezed
class TokyoMunicipalState with _$TokyoMunicipalState {
  const factory TokyoMunicipalState({
    @Default(<TokyoMunicipalModel>[]) List<TokyoMunicipalModel> tokyoMunicipalList,
    @Default(<String, TokyoMunicipalModel>{}) Map<String, TokyoMunicipalModel> tokyoMunicipalMap,
  }) = _TokyoMunicipalState;
}

@riverpod
class TokyoMunicipal extends _$TokyoMunicipal {
  final Utility utility = Utility();

  ///
  @override
  TokyoMunicipalState build() => const TokyoMunicipalState();

  //============================================== api

  ///
  Future<TokyoMunicipalState> fetchAllTokyoMunicipalData() async {
    try {
      final List<TokyoMunicipalModel> list = <TokyoMunicipalModel>[];

      final Map<String, TokyoMunicipalModel> map = <String, TokyoMunicipalModel>{};

      //-----------------------------------------------------------------//
      const String kAssetPath = 'assets/json/tokyo_municipal.geojson';

      final String text = await rootBundle.loadString(kAssetPath);
      // ignore: always_specify_types
      final data = jsonDecode(text);

      // ignore: always_specify_types, strict_raw_type
      final List features;
      // ignore: avoid_dynamic_calls
      if (data['type'] == 'FeatureCollection') {
        // ignore: avoid_dynamic_calls, always_specify_types
        features = data['features'] as List;

        // ignore: avoid_dynamic_calls
      } else if (data['type'] == 'Feature') {
        features = <dynamic>[data];
      } else {
        // ignore: avoid_dynamic_calls
        throw Exception('Unsupported root type: ${data['type']}');
      }

      // ignore: always_specify_types
      for (final f in features) {
        // ignore: avoid_dynamic_calls
        final Map<String, dynamic> props = Map<String, dynamic>.from(f['properties'] as Map<String, dynamic>);

        // ignore: avoid_dynamic_calls
        final Map<String, dynamic> geom = Map<String, dynamic>.from(f['geometry'] as Map<String, dynamic>);

        if (geom.isEmpty) {
          continue;
        }

        /////////////////// name
        final String name = (props['N03_004'] ?? props['name'] ?? '') as String;

        if (name.isEmpty) {
          continue;
        }
        /////////////////// name

        /////////////////// count
        final String? type = geom['type'] as String?;
        // ignore: always_specify_types
        final coords = geom['coordinates'];

        int count = 0;
        if (type == 'Polygon') {
          // [rings][points][lng/lat]
          // ignore: always_specify_types
          for (final ring in (coords as List)) {
            // ignore: always_specify_types
            count += (ring as List).length;
          }
        } else if (type == 'MultiPolygon') {
          // [polygons][rings][points][lng/lat]
          // ignore: always_specify_types
          for (final poly in (coords as List)) {
            // ignore: always_specify_types
            for (final ring in (poly as List)) {
              // ignore: always_specify_types
              count += (ring as List).length;
            }
          }
        } else {
          // Point / MultiLineString などは今回は対象外
          continue;
        }
        /////////////////// count

        list.add(TokyoMunicipalModel(name, count));

        map[name] = TokyoMunicipalModel(name, count);
      }

      return state.copyWith(tokyoMunicipalList: list, tokyoMunicipalMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllTokyoMunicipalData() async {
    try {
      final TokyoMunicipalState newState = await fetchAllTokyoMunicipalData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
