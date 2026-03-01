import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:template_app/helpers/map/address_lookup_helper.dart';
import 'package:template_app/helpers/map/map_calculation_helper.dart';
import 'package:template_app/objects/address_suggestion.dart';
import 'package:template_app/helpers/auth_service.dart';
import 'package:template_app/helpers/general_util.dart';
import 'package:template_app/helpers/theme_manager.dart';
import 'package:template_app/objects/distance_result.dart';
import 'package:template_app/pages/login/login_page.dart';
import 'package:template_app/widgets/default_scaffold.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _fromAddressController = TextEditingController();
  final _toAddressController = TextEditingController();
  Timer? _fromDebounce;
  Timer? _toDebounce;

  List<AddressSuggestion> _fromSuggestions = const [];
  List<AddressSuggestion> _toSuggestions = const [];
  AddressSuggestion? _selectedFrom;
  AddressSuggestion? _selectedTo;

  DistanceResult? _result;
  String? _error;
  bool _isCalculating = false;

  @override
  void dispose() {
    _fromDebounce?.cancel();
    _toDebounce?.cancel();
    _fromAddressController.dispose();
    _toAddressController.dispose();
    super.dispose();
  }

  void _onFromChanged(String value) {
    _fromDebounce?.cancel();

    if (_selectedFrom != null && value.trim() != _selectedFrom!.displayName) {
      _selectedFrom = null;
      _result = null;
    }

    if (value.trim().length < 3) {
      setState(() => _fromSuggestions = const []);
      return;
    }

    _fromDebounce = Timer(const Duration(milliseconds: 350), () async {
      final suggestions = await AddressLookupHelper.searchSuggestions(value);
      if (!mounted) return;
      setState(() => _fromSuggestions = suggestions);
    });
  }

  void _onToChanged(String value) {
    _toDebounce?.cancel();

    if (_selectedTo != null && value.trim() != _selectedTo!.displayName) {
      _selectedTo = null;
      _result = null;
    }

    if (value.trim().length < 3) {
      setState(() => _toSuggestions = const []);
      return;
    }

    _toDebounce = Timer(const Duration(milliseconds: 350), () async {
      final suggestions = await AddressLookupHelper.searchSuggestions(value);
      if (!mounted) return;
      setState(() => _toSuggestions = suggestions);
    });
  }

  void _selectFrom(AddressSuggestion suggestion) {
    setState(() {
      _selectedFrom = suggestion;
      _fromAddressController.text = suggestion.displayName;
      _fromSuggestions = const [];
      _result = null;
      _error = null;
    });
  }

  void _selectTo(AddressSuggestion suggestion) {
    setState(() {
      _selectedTo = suggestion;
      _toAddressController.text = suggestion.displayName;
      _toSuggestions = const [];
      _result = null;
      _error = null;
    });
  }

  Future<void> _calculate() async {
    if (_selectedFrom == null || _selectedTo == null) {
      setState(() => _error = 'Select both addresses from autocomplete suggestions.');
      return;
    }

    setState(() {
      _isCalculating = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await MapCalculationHelper.calculateByRoadGraph(
        from: _selectedFrom!,
        to: _selectedTo!,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    await GeneralUtil.goToPage(context, const LoginPage(), goBack: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Drive Time',
      showTitle: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _addressField(
              controller: _fromAddressController,
              label: 'From address',
              suggestions: _fromSuggestions,
              onChanged: _onFromChanged,
              onSelected: _selectFrom,
            ),
            const SizedBox(height: 10),
            _addressField(
              controller: _toAddressController,
              label: 'To address',
              suggestions: _toSuggestions,
              onChanged: _onToChanged,
              onSelected: _selectTo,
            ),
            const SizedBox(height: 12),
            _mapPreview(),
            _routeLegend(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isCalculating ? null : _calculate,
              child: Text(_isCalculating ? 'Calculating...' : 'Calculate drive time'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _logout,
              child: const Text('Log out'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dark mode',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                themeSwitchWidget(),
              ],
            ),
            const SizedBox(height: 12),
            if ((_error ?? '').isNotEmpty)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_result != null) ...[
              const SizedBox(height: 8),
              _resultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _addressField({
    required TextEditingController controller,
    required String label,
    required List<AddressSuggestion> suggestions,
    required ValueChanged<String> onChanged,
    required ValueChanged<AddressSuggestion> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: const OutlineInputBorder(),
            labelText: label,
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    suggestion.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSelected(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _mapPreview() {
    final hasFrom = _selectedFrom != null;
    final hasTo = _selectedTo != null;

    final center = hasFrom
        ? LatLng(_selectedFrom!.latitude, _selectedFrom!.longitude)
        : const LatLng(55.6761, 12.5683);

    final dijkstraRoutePoints = (_result?.dijkstraRoutePoints ?? const <GeoPoint>[])
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();

    final aStarRoutePoints = (_result?.aStarRoutePoints ?? const <GeoPoint>[])
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    final greedyRoutePoints = (_result?.greedyRoutePoints ?? const <GeoPoint>[])
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();

    final fallbackLine = (hasFrom && hasTo)
        ? [
            LatLng(_selectedFrom!.latitude, _selectedFrom!.longitude),
            LatLng(_selectedTo!.latitude, _selectedTo!.longitude),
          ]
        : <LatLng>[];

    final showFallbackLine =
      dijkstraRoutePoints.isEmpty && aStarRoutePoints.isEmpty && greedyRoutePoints.isEmpty;

    final dijkstraColor = Theme.of(context).colorScheme.primary;
    final aStarColor = Theme.of(context).colorScheme.error;
    final greedyColor = Theme.of(context).colorScheme.secondary;

    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: hasFrom || hasTo ? 11 : 6,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'template_app',
            ),
            if (showFallbackLine && fallbackLine.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: fallbackLine,
                    strokeWidth: 4,
                    color: dijkstraColor,
                  ),
                ],
              ),
            if (dijkstraRoutePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: dijkstraRoutePoints,
                    strokeWidth: 5,
                    color: dijkstraColor,
                  ),
                ],
              ),
            if (aStarRoutePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: aStarRoutePoints,
                    strokeWidth: 3,
                    color: aStarColor,
                  ),
                ],
              ),
            if (greedyRoutePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: greedyRoutePoints,
                    strokeWidth: 2,
                    color: greedyColor,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (hasFrom)
                  Marker(
                    point: LatLng(_selectedFrom!.latitude, _selectedFrom!.longitude),
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.place,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                if (hasTo)
                  Marker(
                    point: LatLng(_selectedTo!.latitude, _selectedTo!.longitude),
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.place,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeLegend() {
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _legendItem(color: primary, label: 'Dijkstra'),
          const SizedBox(width: 12),
          _legendItem(color: error, label: 'A*'),
          const SizedBox(width: 12),
          _legendItem(color: secondary, label: 'Greedy Best-First'),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _resultCard(DistanceResult result) {
    String fmtKm(double value) => '${value.toStringAsFixed(3)} km';
    String fmtMinutes(double value) => '${value.toStringAsFixed(1)} min';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dijkstra km: ${fmtKm(result.dijkstraDistanceKm)}'),
            Text('Dijkstra time: ${fmtMinutes(result.dijkstraDriveTimeMinutes)}'),
            const SizedBox(height: 4),
            Text('A* km: ${fmtKm(result.aStarDistanceKm)}'),
            Text('A* time: ${fmtMinutes(result.aStarDriveTimeMinutes)}'),
            const SizedBox(height: 4),
            Text('Greedy Best-First km: ${fmtKm(result.greedyDistanceKm)}'),
            Text('Greedy Best-First time: ${fmtMinutes(result.greedyDriveTimeMinutes)}'),
          ],
        ),
      ),
    );
  }
}
