class TokyoMunicipalModel {
  const TokyoMunicipalModel(
    this.name,
    this.vertexCount, {
    this.minLat = 0,
    this.minLng = 0,
    this.maxLat = 0,
    this.maxLng = 0,
    this.centroidLat = 0,
    this.centroidLng = 0,
  });

  final String name;

  final double minLat;
  final double minLng;

  final double maxLat;
  final double maxLng;

  final double centroidLat;
  final double centroidLng;

  final int vertexCount;
}
