import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:template_app/helpers/map/road_graph_helper.dart';

class GraphAlgorithmResult {
  final double distanceKm;
  final List<int> nodePath;

  const GraphAlgorithmResult({
    required this.distanceKm,
    required this.nodePath,
  });
}

// Works best without traffic - Based on distance, might be slower than Astar but guarantees optimality
class GraphAlgorithmsHelper {
  static GraphAlgorithmResult runDijkstra(RoadGraph graph) {
    return _runShortestPath(
      graph: graph,
      useAStar: false,
    );
  }

  // Works best without traffic - Based on distance + estimate, should be faster than Dijkstra and guarantees optimality
  static GraphAlgorithmResult runAStar(RoadGraph graph) {
    return _runShortestPath(
      graph: graph,
      useAStar: true,
    );
  }

  // Works best with trafic
  static GraphAlgorithmResult runGreedyBestFirst(RoadGraph graph) {
    final start = graph.startNodeId;
    final goal = graph.endNodeId;

    final frontier = PriorityQueue<_QueueItem>((a, b) => a.priority.compareTo(b.priority));
    final visited = <int>{};
    final previous = <int, int?>{start: null};
    final distanceFromStart = <int, double>{start: 0};

    frontier.add(_QueueItem(nodeId: start, priority: 0));

    while (frontier.isNotEmpty) {
      final current = frontier.removeFirst();
      final currentNodeId = current.nodeId;

      if (!visited.add(currentNodeId)) {
        continue;
      }

      if (currentNodeId == goal) {
        break;
      }

      for (final edge in graph.adjacency[currentNodeId] ?? const <RoadGraphEdge>[]) {
        if (visited.contains(edge.toNodeId)) {
          continue;
        }

        if (!previous.containsKey(edge.toNodeId)) {
          previous[edge.toNodeId] = currentNodeId;
          distanceFromStart[edge.toNodeId] =
              (distanceFromStart[currentNodeId] ?? 0) + edge.distanceKm;
        }

        final heuristic = _haversineKm(
          graph.nodes[edge.toNodeId]!.point.latitude,
          graph.nodes[edge.toNodeId]!.point.longitude,
          graph.nodes[goal]!.point.latitude,
          graph.nodes[goal]!.point.longitude,
        );

        frontier.add(_QueueItem(nodeId: edge.toNodeId, priority: heuristic));
      }
    }

    if (!previous.containsKey(goal)) {
      throw Exception('No valid road path found between selected addresses.');
    }

    final path = <int>[];
    int? cursor = goal;
    while (cursor != null) {
      path.add(cursor);
      cursor = previous[cursor];
    }
    final orderedPath = path.reversed.toList();

    final totalDistance = distanceFromStart[goal] ?? double.infinity;
    if (totalDistance.isInfinite) {
      throw Exception('No valid road path found between selected addresses.');
    }

    return GraphAlgorithmResult(
      distanceKm: totalDistance,
      nodePath: orderedPath,
    );
  }

  static GraphAlgorithmResult _runShortestPath({
    required RoadGraph graph,
    required bool useAStar,
  }) {
    final start = graph.startNodeId;
    final goal = graph.endNodeId;

    final bestDistance = <int, double>{};
    final previous = <int, int?>{};

    for (final nodeId in graph.nodes.keys) {
      bestDistance[nodeId] = double.infinity;
      previous[nodeId] = null;
    }
    bestDistance[start] = 0;

    final queue = PriorityQueue<_QueueItem>((a, b) => a.priority.compareTo(b.priority));
    queue.add(_QueueItem(nodeId: start, priority: 0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final currentNodeId = current.nodeId;

      if (currentNodeId == goal) {
        break;
      }

      final currentDistance = bestDistance[currentNodeId] ?? double.infinity;
      if (currentDistance.isInfinite) {
        continue;
      }

      for (final edge in graph.adjacency[currentNodeId] ?? const <RoadGraphEdge>[]) {
        final candidateDistance = currentDistance + edge.distanceKm;
        final knownDistance = bestDistance[edge.toNodeId] ?? double.infinity;

        if (candidateDistance >= knownDistance) {
          continue;
        }

        bestDistance[edge.toNodeId] = candidateDistance;
        previous[edge.toNodeId] = currentNodeId;

        final heuristic = useAStar
            ? _haversineKm(
                graph.nodes[edge.toNodeId]!.point.latitude,
                graph.nodes[edge.toNodeId]!.point.longitude,
                graph.nodes[goal]!.point.latitude,
                graph.nodes[goal]!.point.longitude,
              )
            : 0.0;

        queue.add(
          _QueueItem(
            nodeId: edge.toNodeId,
            priority: candidateDistance + heuristic,
          ),
        );
      }
    }

    final totalDistance = bestDistance[goal] ?? double.infinity;
    if (totalDistance.isInfinite) {
      throw Exception('No valid road path found between selected addresses.');
    }

    final path = <int>[];
    int? cursor = goal;
    while (cursor != null) {
      path.add(cursor);
      cursor = previous[cursor];
    }
    final orderedPath = path.reversed.toList();

    return GraphAlgorithmResult(
      distanceKm: totalDistance,
      nodePath: orderedPath,
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

class _QueueItem {
  final int nodeId;
  final double priority;

  const _QueueItem({required this.nodeId, required this.priority});
}
