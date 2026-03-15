class DistanceResult {
  final double dijkstraDistanceKm;
  final double dijkstraDriveTimeMinutes;
  final double aStarDistanceKm;
  final double aStarDriveTimeMinutes;
  final double greedyDistanceKm;
  final double greedyDriveTimeMinutes;
  final double? haversineDistanceKm;
  final List<GeoPoint> dijkstraRoutePoints;
  final List<GeoPoint> aStarRoutePoints;
  final List<GeoPoint> greedyRoutePoints;
  final String? note;

  const DistanceResult({
    required this.dijkstraDistanceKm,
    required this.dijkstraDriveTimeMinutes,
    required this.aStarDistanceKm,
    required this.aStarDriveTimeMinutes,
    required this.greedyDistanceKm,
    required this.greedyDriveTimeMinutes,
    required this.haversineDistanceKm,
    required this.dijkstraRoutePoints,
    required this.aStarRoutePoints,
    required this.greedyRoutePoints,
    required this.note,
  });
}

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});
}
