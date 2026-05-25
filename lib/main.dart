import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bandung Quest Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE31E24), // Telkom Red
          primary: const Color(0xFFE31E24),
        ),
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Coordinates
  static const LatLng _telkomUniv = LatLng(-6.9740, 107.6303);
  static const LatLng _gedungSate = LatLng(-6.9025, 107.6188);

  final MapController _mapController = MapController();
  bool _isAtTelkom = true;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _markers = [_buildMarker(_telkomUniv, "Telkom University", Colors.red)];
  }

  Marker _buildMarker(LatLng point, String label, Color color) {
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.location_on, color: color, size: 40),
        ],
      ),
    );
  }

  void _moveMap() {
    final LatLng destination = _isAtTelkom ? _gedungSate : _telkomUniv;
    final String label = _isAtTelkom ? "Gedung Sate" : "Telkom University";
    final Color color = _isAtTelkom ? Colors.blue : Colors.red;

    // Use a custom animation for smooth movement
    _animatedMapMove(destination, 15.0);

    setState(() {
      _markers = [_buildMarker(destination, label, color)];
      _isAtTelkom = !_isAtTelkom;
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween = Tween<double>(
        begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    final animation = CurvedAnimation(
        parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bandung Explorer",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _telkomUniv,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.maps_n_place',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isAtTelkom ? "Lokasi: Telkom University" : "Lokasi: Gedung Sate",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text("Sistem Informasi Geografis"),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moveMap,
        label: Text(_isAtTelkom ? "Pindah ke Wisata" : "Kembali ke Kampus"),
        icon: Icon(_isAtTelkom ? Icons.tour : Icons.school),
        backgroundColor: _isAtTelkom ? Colors.blue : Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}