import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  /// Lokasi default (contoh: Jakarta)
  final LatLng defaultLocation = const LatLng(-6.200000, 106.816666);

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    /// Tambah marker
    _markers.add(
      Marker(
        markerId: const MarkerId("myLoc"),
        position: defaultLocation,
        infoWindow: const InfoWindow(
          title: "Lokasi Saya",
          snippet: "Anda berada di sekitar sini",
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D1F42),
        centerTitle: true,
        title: const Text(
          "Peta Fasilitas Kesehatan",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          /// ===================== PETA =====================
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: defaultLocation,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),
          ),

          /// ===================== KETERANGAN LOKASI =====================
          Container(
            padding: const EdgeInsets.all(22),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD3B6D3),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ----- Judul -----
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D1F42).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Lokasi Anda",
                    style: TextStyle(
                      color: Color(0xFF6D1F42),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ----- Nama Lokasi -----
                const Text(
                  "Dekat Anda — Jakarta Pusat",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6D1F42),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: const [
                    Icon(Icons.place, size: 18, color: Color(0xFF6D1F42)),
                    SizedBox(width: 6),
                    Text(
                      "Estimasi lokasi berdasarkan GPS",
                      style: TextStyle(fontSize: 14, color: Color(0xFF6D1F42)),
                    ),
                  ],
                ),

                const Divider(height: 30, thickness: 1, color: Colors.white),

                /// ----- Info Tambahan -----
                Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF6D1F42),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Gunakan peta untuk mencari fasilitas kesehatan terdekat.",
                        style: TextStyle(
                          color: Color(0xFF6D1F42),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
