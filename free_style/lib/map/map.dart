import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? controller;

  onMapCreated(GoogleMapController value) async {
    controller = value;
  }

  currentLocation() async {
    Position current = await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
            target: LatLng(10.744949, 106.697521),
            zoom: 17.0,
            tilt: 0,
            bearing: 0),
        onMapCreated: onMapCreated,
        mapType: MapType.normal,
      ),
    );
  }
}
