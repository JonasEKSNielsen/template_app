import 'dart:math' as math;

import 'package:template_app/helpers/map/graph_algorithms_helper.dart';
import 'package:template_app/helpers/map/road_graph_helper.dart';
import 'package:template_app/objects/address_suggestion.dart';
import 'package:template_app/objects/distance_result.dart';

class MapCalculationHelper {
  static Future<DistanceResult> calculateByRoadGraph({
    required AddressSuggestion from,
    required AddressSuggestion to,
  }) async {
    final graph = await RoadGraphHelper.buildRoadGraph(from: from, to: to);

    final dijkstra = GraphAlgorithmsHelper.runDijkstra(graph);
    final aStar = GraphAlgorithmsHelper.runAStar(graph);
    final greedy = GraphAlgorithmsHelper.runGreedyBestFirst(graph);

    const assumedAverageSpeedKmh = 50.0;

    final dijkstraMinutes = (dijkstra.distanceKm / assumedAverageSpeedKmh) * 60;
    final aStarMinutes = (aStar.distanceKm / assumedAverageSpeedKmh) * 60;
    final greedyMinutes = (greedy.distanceKm / assumedAverageSpeedKmh) * 60;

    final haversineKm = _haversineKm(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );

    final dijkstraPath = dijkstra.nodePath
        .map((nodeId) => graph.nodes[nodeId]!.point)
        .toList();

    final aStarPath = aStar.nodePath
      .map((nodeId) => graph.nodes[nodeId]!.point)
      .toList();

    final greedyPath = greedy.nodePath
      .map((nodeId) => graph.nodes[nodeId]!.point)
      .toList();

    final greedyVsDijkstraKm = greedy.distanceKm - dijkstra.distanceKm;
    final greedyVsDijkstraPercent = dijkstra.distanceKm == 0
        ? 0.0
        : (greedyVsDijkstraKm / dijkstra.distanceKm) * 100;

    return DistanceResult(
      dijkstraDistanceKm: dijkstra.distanceKm,
      dijkstraDriveTimeMinutes: dijkstraMinutes,
      aStarDistanceKm: aStar.distanceKm,
      aStarDriveTimeMinutes: aStarMinutes,
      greedyDistanceKm: greedy.distanceKm,
      greedyDriveTimeMinutes: greedyMinutes,
      haversineDistanceKm: haversineKm,
      dijkstraRoutePoints: dijkstraPath,
      aStarRoutePoints: aStarPath,
      greedyRoutePoints: greedyPath,
      note: 'Greedy Best-First uses only straight-line heuristic and may be suboptimal. '
          'Difference vs Dijkstra: ${greedyVsDijkstraKm.toStringAsFixed(3)} km '
          '(${greedyVsDijkstraPercent.toStringAsFixed(2)}%).',
    );
  }

  static double _haversineKm(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadiusKm = 6371.0;
    double toRadians(double value) => value * math.pi / 180.0;

    final deltaLat = toRadians(latitude2 - latitude1);
    final deltaLon = toRadians(longitude2 - longitude1);
    final lat1Rad = toRadians(latitude1);
    final lat2Rad = toRadians(latitude2);

    final a =
        math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(deltaLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
