class GraphNode {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const GraphNode({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
