import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:template_app/classes/map/road_graph_helper.dart';

class GraphAlgorithmResult {
  final double distanceKm;
  final List<int> nodePath;

  const GraphAlgorithmResult({
    required this.distanceKm,
    required this.nodePath,
  });
}

// Ren vægtet korteste vej uden heuristik
// Optimal så længe kanter ikke er negative
class GraphAlgorithmsHelper {
  static GraphAlgorithmResult runDijkstra(RoadGraph graph) {
    // Dijkstra kalder same base som A*
    // Forskellen er at heuristik sættes til 0 i dijkstra så det kun er g(n) der tæller og ikk h(n)
    return _runShortestPath(graph: graph, useAStar: false);
  }

  // Samme relaksation som Dijkstra
  // Kø prioritet får også et luftlinje estimat mod målet
  static GraphAlgorithmResult runAStar(RoadGraph graph) {
    return _runShortestPath(graph: graph, useAStar: true);
  }

  // Greedy Best First udvider den node som ser tættest på målet ud
  // Kan være hurtig men ignorerer kost indtil nu
  // Ikke garanteret optimal
  static GraphAlgorithmResult runGreedyBestFirst(RoadGraph graph) {
    final start = graph.startNodeId;
    final goal = graph.endNodeId;

    final frontier = PriorityQueue<_QueueItem>(
      (a, b) => a.priority.compareTo(b.priority),
    );
    // visited sikrer at vi kun afslutter en node én gang
    final visited = <int>{};
    // previous bruges senere til at bygge ruten tilbage
    final previous = <int, int?>{start: null};
    // distanceFromStart er den pris vi endte med i Greedy for hver node
    final distanceFromStart = <int, double>{start: 0};

    frontier.add(_QueueItem(nodeId: start, priority: 0));

    while (frontier.isNotEmpty) {
      // Tag node med laveste prioritet først
      final current = frontier.removeFirst();
      final currentNodeId = current.nodeId;

      if (!visited.add(currentNodeId)) {
        continue;
      }

      if (currentNodeId == goal) {
        break;
      }

      for (final edge
          in graph.adjacency[currentNodeId] ?? const <RoadGraphEdge>[]) {
        // Hvis nabo allerede er afsluttet springes den over
        if (visited.contains(edge.toNodeId)) {
          continue;
        }

        // I Greedy mode gemmer vi første forælder vi møder
        // Derefter går vi videre mod laveste heuristik
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

        // Prioritet er kun heuristik h(n)
        // Det er best first search og ikke A*
        frontier.add(_QueueItem(nodeId: edge.toNodeId, priority: heuristic));
      }
    }

    if (!previous.containsKey(goal)) {
      throw Exception('No valid road path found between selected addresses.');
    }

    // Gendan stien ved at følge forælder pegepinde fra mål til start
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
    // start er hvor vi begynder
    // goal er målnoden vi vil nå
    final start = graph.startNodeId;
    final goal = graph.endNodeId;

    // bestDistance[node] = bedste kendte pris fra start til node
    final bestDistance = <int, double>{};
    // previous[node] = hvilken node vi kom fra på bedste kendte rute
    final previous = <int, int?>{};

    // Standard setup for korteste vej
    // Alle noder starter på uendelig undtagen kilden
    for (final nodeId in graph.nodes.keys) {
      bestDistance[nodeId] = double.infinity;
      previous[nodeId] = null;
    }
    bestDistance[start] = 0;

    final queue = PriorityQueue<_QueueItem>(
      (a, b) => a.priority.compareTo(b.priority),
    );
    // Start i køen med pris 0
    queue.add(_QueueItem(nodeId: start, priority: 0));

    while (queue.isNotEmpty) {
      // Hent næste kandidat med laveste prioritet
      final current = queue.removeFirst();
      final currentNodeId = current.nodeId;

      // Når målet kommer ud af køen har vi bedste fundne pris til målet
      if (currentNodeId == goal) {
        break;
      }

      final currentDistance = bestDistance[currentNodeId] ?? double.infinity;
      // Hvis current ikke kan nås giver det ingen mening at udvide den
      if (currentDistance.isInfinite) {
        continue;
      }

      for (final edge
          in graph.adjacency[currentNodeId] ?? const <RoadGraphEdge>[]) {
        // Relaksation
        // Hvis ruten via current er billigere opdateres naboens bedste kendte afstand
        // g(n) er kendt pris fra start til en node
        final candidateDistance = currentDistance + edge.distanceKm;
        final knownDistance = bestDistance[edge.toNodeId] ?? double.infinity;

        // Ikke en forbedring så ignoreres den
        if (candidateDistance >= knownDistance) {
          continue;
        }

        // Bedre rute til naboen
        // Gem ny pris og forælder
        bestDistance[edge.toNodeId] = candidateDistance;
        previous[edge.toNodeId] = currentNodeId;

        // Heuristik h(n) er et kvalificeret gæt på afstand til målet
        // Her er heuristikken luftlinjeafstand fra nabo til mål via _haversineKm
        // Bruges kun i A* når useAStar er true
        // Dijkstra bruger 0.0 her
        final heuristic = useAStar
            ? _haversineKm(
                graph.nodes[edge.toNodeId]!.point.latitude,
                graph.nodes[edge.toNodeId]!.point.longitude,
                graph.nodes[goal]!.point.latitude,
                graph.nodes[goal]!.point.longitude,
              )
            : 0.0;

        // Prioritet i køen
        // Dijkstra f(n) = g(n)
        // A* f(n) = g(n) + h(n)
        queue.add(
          _QueueItem(
            nodeId: edge.toNodeId,
            priority: candidateDistance + heuristic,
          ),
        );
      }
    }

    // Hvis målet stadig er uendelig findes der ingen vej
    final totalDistance = bestDistance[goal] ?? double.infinity;
    if (totalDistance.isInfinite) {
      throw Exception('No valid road path found between selected addresses.');
    }

    // Forælder map giver et korteste vej træ med rod i start
    // Rul en gren ud for målet
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
    // Storcirkelafstand bruges som luftlinje heuristik i A*
    // Det er et estimate ikke den faktiske køreafstand på vejnettet
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

class _QueueItem {
  final int nodeId;
  final double priority;

  const _QueueItem({required this.nodeId, required this.priority});
}
