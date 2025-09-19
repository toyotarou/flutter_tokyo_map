import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/temple_model.dart';
import '../../models/tokyo_municipal_model.dart';

import '../../models/tokyo_train_model.dart';
import '../../utility/utility.dart';

part 'app_param.freezed.dart';

part 'app_param.g.dart';

@freezed
class AppParamState with _$AppParamState {
  const factory AppParamState({
    @Default(<TokyoMunicipalModel>[]) List<TokyoMunicipalModel> keepTokyoMunicipalList,
    @Default(<String, TokyoMunicipalModel>{}) Map<String, TokyoMunicipalModel> keepTokyoMunicipalMap,

    @Default(<TokyoTrainModel>[]) List<TokyoTrainModel> keepTokyoTrainList,
    @Default(<String, List<TokyoStationModel>>{}) Map<String, List<TokyoStationModel>> keepTokyoStationMap,

    @Default(<TempleModel>[]) List<TempleModel> keepTempleList,
    @Default(<String, TempleModel>{}) Map<String, TempleModel> keepTempleMap,

    ///////////////////////////////////////
    @Default('') String selectedMunicipal,

    @Default('station') String selectedMarkerDisplayKind,
  }) = _AppParamState;
}

@riverpod
class AppParam extends _$AppParam {
  final Utility utility = Utility();

  ///
  @override
  AppParamState build() => const AppParamState();

  ///
  void setKeepTokyoMunicipalList({required List<TokyoMunicipalModel> list}) =>
      state = state.copyWith(keepTokyoMunicipalList: list);

  ///
  void setKeepTokyoMunicipalMap({required Map<String, TokyoMunicipalModel> map}) =>
      state = state.copyWith(keepTokyoMunicipalMap: map);

  ///
  void setKeepTokyoTrainList({required List<TokyoTrainModel> list}) => state = state.copyWith(keepTokyoTrainList: list);

  ///
  void setKeepTokyoStationMap({required Map<String, List<TokyoStationModel>> map}) =>
      state = state.copyWith(keepTokyoStationMap: map);

  ///
  void setKeepTempleList({required List<TempleModel> list}) => state = state.copyWith(keepTempleList: list);

  ///
  void setKeepTempleMap({required Map<String, TempleModel> map}) => state = state.copyWith(keepTempleMap: map);

  ///////////////////////////////////////

  ///
  void setSelectedMunicipal({required String municipal}) => state = state.copyWith(selectedMunicipal: municipal);

  ///
  void setSelectedMarkerDisplayKind({required String kind}) => state = state.copyWith(selectedMarkerDisplayKind: kind);
}
