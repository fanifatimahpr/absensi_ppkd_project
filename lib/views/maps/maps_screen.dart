import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? currentPosition;

  String? currentAddress = "Mendeteksi lokasi...";

  LatLng kantorLocation = const LatLng(-6.175392, 106.827153);

  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;
  String? checkInLocation;
  String? checkOutLocation;

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _initLocation();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animController);

    _animController.forward();
  }

  // ===========================================================
  // GET CURRENT LOCATION + ADDRESS
  // ===========================================================
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    // Gerakkan kamera ke lokasi user
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition!, 16),
      );
    }

    // Get Address
    final place = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    setState(() {
      currentAddress =
          "${place.first.street}, ${place.first.subLocality}, ${place.first.locality}";
    });
  }

  String formatTime(DateTime date) =>
      DateFormat('HH:mm:ss', 'id_ID').format(date);

  // ABSEN MASUK
  void handleCheckIn() {
    if (currentPosition == null) return;

    setState(() {
      isCheckedIn = true;
      checkInTime = formatTime(DateTime.now());
      checkInLocation = currentAddress;
    });
  }

  // ABSEN KELUAR
  void handleCheckOut() {
    if (currentPosition == null) return;

    setState(() {
      isCheckedIn = false;
      checkOutTime = formatTime(DateTime.now());
      checkOutLocation = currentAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D1F42),
        title:
            const Text("Absensi Lokasi", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              Expanded(child: _buildMap()),
              _buildCurrentAddressBox(),
              _buildActionCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // GOOGLE MAPS
  // ===========================================================
  Widget _buildMap() {
    if (currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6D1F42)),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: currentPosition!,
        zoom: 16,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        controller.animateCamera(
            CameraUpdate.newLatLngZoom(currentPosition!, 16));
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: {
        Marker(
          markerId: const MarkerId("myLocation"),
          position: currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: const InfoWindow(title: "Lokasi Anda"),
        ),
        Marker(
          markerId: const MarkerId("kantor"),
          position: kantorLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "Lokasi Kantor"),
        ),
      },
    );
  }

  // ===========================================================
  // ADDRESS BOX TEMA ELEGAN
  // ===========================================================
  Widget _buildCurrentAddressBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF6D1F42),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              currentAddress ?? "Mendeteksi lokasi...",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // BOTTOM CARD BUTTON MASUK / KELUAR
  // ===========================================================
  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Riwayat Hari Ini",
            style: TextStyle(
              color: Color(0xFF6D1F42),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _historyItem(
            title: "Waktu Masuk",
            time: checkInTime ?? "--:--",
            location: checkInLocation ?? "-",
            dotColor: const Color(0xFF6D1F42),
          ),
          _historyItem(
            title: "Waktu Keluar",
            time: checkOutTime ?? "--:--",
            location: checkOutLocation ?? "-",
            dotColor: const Color(0xFF275185),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isCheckedIn ? null : handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor:
                        isCheckedIn ? Colors.grey : const Color(0xFF6D1F42),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Masuk",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: !isCheckedIn ? null : handleCheckOut,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor:
                        !isCheckedIn ? Colors.grey : const Color(0xFF275185),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Keluar",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // ITEM RIWAYAT
  // ===========================================================
  Widget _historyItem({
    required String title,
    required String time,
    required String location,
    required Color dotColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dotColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text("Jam: $time",
              style: const TextStyle(fontSize: 13, color: Color(0xFF6D1F42))),
          Text("Lokasi: $location",
              style: const TextStyle(fontSize: 13, color: Color(0xFF6D1F42))),
        ],
      ),
    );
  }
}
 