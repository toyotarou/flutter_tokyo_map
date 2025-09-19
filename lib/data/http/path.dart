enum APIPath { getTokyoTrainStation, getTempleLatLng, getTempleDatePhoto, getAllTemple }

extension APIPathExtension on APIPath {
  String? get value {
    switch (this) {
      case APIPath.getTokyoTrainStation:
        return 'getTokyoTrainStation';
      case APIPath.getTempleLatLng:
        return 'getTempleLatLng';
      case APIPath.getTempleDatePhoto:
        return 'getTempleDatePhoto';
      case APIPath.getAllTemple:
        return 'getAllTemple';
    }
  }
}
