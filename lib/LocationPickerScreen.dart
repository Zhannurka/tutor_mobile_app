import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _selectedPos = const LatLng(43.2389, 76.8897); // Бастапқы нүкте (Алматы)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Орынды таңдаңыз"), backgroundColor: Colors.green),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selectedPos, zoom: 14),
            onTap: (pos) => setState(() => _selectedPos = pos),
            markers: {
              Marker(markerId: const MarkerId("selected"), position: _selectedPos),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15), backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context, _selectedPos),
              child: const Text("Осы орынды таңдау", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}