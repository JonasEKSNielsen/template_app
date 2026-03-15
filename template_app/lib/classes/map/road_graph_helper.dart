import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:template_app/classes/objects/address_suggestion.dart';
import 'package:template_app/classes/objects/distance_result.dart';

class RoadGraphNode {
  final int id;
  final GeoPoint point;

  const RoadGraphNode({required this.id, required this.point});
}

class RoadGraphEdge {
  final int fromNodeId;
  final int toNodeId;
  final double distanceKm;

  const RoadGraphEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.distanceKm,
  });
}

class RoadGraph {
  final Map<int, RoadGraphNode> nodes;
  final Map<int, List<RoadGraphEdge>> adjacency;
  final int startNodeId;
  final int endNodeId;

  const RoadGraph({
    required this.nodes,
    required this.adjacency,
    required this.startNodeId,
    required this.endNodeId,
  });
}

class RoadGraphHelper {
  static Future<RoadGraph> buildRoadGraph({
    required AddressSuggestion from,
    required AddressSuggestion to,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?alternatives=true&overview=full&geometries=geojson',
    );

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'template_app/1.0 (road-graph-builder)',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not fetch road network for route.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = payload['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No drivable route found between selected addresses.');
    }

    final nodesById = <int, RoadGraphNode>{};
    final adjacency = <int, List<RoadGraphEdge>>{};
    final nodeByKey = <String, int>{};
    var nextNodeId = 0;

    int getOrCreateNodeId(double latitude, double longitude) {
      final key =
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
      final existing = nodeByKey[key];
      if (existing != null) {
        return existing;
      }

      final id = nextNodeId++;
      nodeByKey[key] = id;
      nodesById[id] = RoadGraphNode(
        id: id,
        point: GeoPoint(latitude: latitude, longitude: longitude),
      );
      adjacency[id] = <RoadGraphEdge>[];
      return id;
    }

    int? startNodeId;
    int? endNodeId;

    for (var routeIndex = 0; routeIndex < routes.length; routeIndex++) {
      final route = routes[routeIndex] as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>?;
      if (coordinates == null || coordinates.length < 2) {
        continue;
      }

      final ids = <int>[];
      for (final item in coordinates) {
        final coord = item as List<dynamic>;
        if (coord.length < 2) {
          continue;
        }
        final longitude = (coord[0] as num).toDouble();
        final latitude = (coord[1] as num).toDouble();
        ids.add(getOrCreateNodeId(latitude, longitude));
      }

      if (ids.length < 2) {
        continue;
      }

      if (routeIndex == 0) {
        startNodeId = ids.first;
        endNodeId = ids.last;
      }

      for (var i = 0; i < ids.length - 1; i++) {
        final fromId = ids[i];
        final toId = ids[i + 1];

        final fromPoint = nodesById[fromId]!.point;
        final toPoint = nodesById[toId]!.point;
        final distanceKm = _haversineKm(
          fromPoint.latitude,
          fromPoint.longitude,
          toPoint.latitude,
          toPoint.longitude,
        );

        adjacency[fromId]!.add(
          RoadGraphEdge(
            fromNodeId: fromId,
            toNodeId: toId,
            distanceKm: distanceKm,
          ),
        );
        adjacency[toId]!.add(
          RoadGraphEdge(
            fromNodeId: toId,
            toNodeId: fromId,
            distanceKm: distanceKm,
          ),
        );
      }
    }

    if (nodesById.isEmpty || startNodeId == null || endNodeId == null) {
      throw Exception('Could not construct road graph for route.');
    }

    return RoadGraph(
      nodes: nodesById,
      adjacency: adjacency,
      startNodeId: startNodeId,
      endNodeId: endNodeId,
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
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.pow(math.sin(deltaLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
