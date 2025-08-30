import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/attendance_record.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendanceScreen> {
  final LocationService _locationService = LocationService();
  final StorageService _storage = StorageService();
  final DateFormat _dt = DateFormat('EEE, dd MMM yyyy • HH:mm:ss');

  String? _userName;
  Position? _position;
  String? _address;
  double? _distance;
  bool _within = false;
  File? _selfie;
  bool _loadingLoc = false;
  Timer? _clock;
  DateTime _now = DateTime.now();
  bool _hasCheckedInToday = false;

  @override
  void initState() {
    super.initState();
    _init();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final name = await _storage.getUserName();
    if (name == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    final checked = await _storage.hasCheckedInToday();

    setState(() {
      _userName = name;
      _hasCheckedInToday = checked;
    });

    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _loadingLoc = true);
    final ok = await _locationService.ensurePermission();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi ditolak / layanan nonaktif')),
      );
      setState(() => _loadingLoc = false);
      return;
    }
    final pos = await _locationService.getCurrentPosition();
    final dist = _locationService.distanceFromOffice(
      pos.latitude,
      pos.longitude,
    );
    final addr = await _locationService.reverseGeocode(
      pos.latitude,
      pos.longitude,
    );
    setState(() {
      _position = pos;
      _distance = dist;
      _within = dist <= LocationService.validRadiusMeters;
      _address = addr;
      _loadingLoc = false;
    });
  }

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70,
    );
    if (xfile == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    final savedFile = await File(xfile.path).copy(savedPath);
    setState(() => _selfie = savedFile);
  }

  Future<void> _submit() async {
    if (_hasCheckedInToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu sudah absen hari ini ✅')),
      );
      return;
    }

    if (_position == null || _selfie == null) return;

    final rec = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      withinRadius: _within,
      imagePath: _selfie!.path,
      address: _address,
    );
    await _storage.addRecord(rec);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Absensi tersimpan!')));

    setState(() {
      _selfie = null;
      _hasCheckedInToday = true; // update status
    });
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = _distance == null
        ? '-'
        : '${_distance!.toStringAsFixed(1)} m';
    final coordsText = _position == null
        ? '-'
        : '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}';
    final canSubmit = _within && _selfie != null && !_hasCheckedInToday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kehadiran'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 1.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).pushNamed('/history'),
            tooltip: 'Riwayat Absensi',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _storage.signOut();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
            },
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLocation,
        color: kPrimaryColor,
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            // --- Header Section ---
            Container(
              padding: const EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: kBorderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${_userName ?? '-'} 👋',
                    style: kTitleStyle.copyWith(color: kPrimaryColor),
                  ),
                  kGapTiny,
                  Text(_dt.format(_now)),
                  kGapSmall,
                  // --- Status Chip ---
                  Chip(
                    avatar: Icon(
                      _hasCheckedInToday ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                    ),
                    label: Text(
                      _hasCheckedInToday
                          ? "Sudah Absen Hari Ini"
                          : "Belum Absen",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _hasCheckedInToday
                        ? kSuccessColor
                        : kErrorColor,
                  ),
                ],
              ),
            ),
            kGap,

            // --- Lokasi Card (Refined) ---
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lokasi Saat Ini', style: kHeadingStyle),
                    const Divider(),
                    // --- Info items with icons ---
                    _buildLocationInfo(Icons.pin_drop, 'Koordinat', coordsText),
                    _buildLocationInfo(
                      Icons.location_on,
                      'Alamat',
                      _address ?? '-',
                    ),
                    _buildLocationInfo(
                      Icons.radar,
                      'Jarak dari Kantor',
                      distanceText,
                    ),
                    kGapSmall,
                    // --- Status dalam/luar radius ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _within
                            ? kSuccessColor.withOpacity(0.1)
                            : kErrorColor.withOpacity(0.1),
                        borderRadius: kBorderRadius,
                        border: Border.all(
                          color: _within ? kSuccessColor : kErrorColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _within ? Icons.verified : Icons.error_outline,
                            color: _within ? kSuccessColor : kErrorColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _within
                                  ? 'Anda berada dalam radius kantor'
                                  : 'Anda di luar radius kantor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _within ? kSuccessColor : kErrorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    kGap,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loadingLoc ? null : _fetchLocation,
                        icon: _loadingLoc
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: const Text('Refresh Lokasi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            kGap,

            // --- Selfie Card (Refined) ---
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selfie Kehadiran', style: kHeadingStyle),
                    const Divider(),
                    kGapSmall,
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: kBorderRadius,
                          color: Colors.grey.shade50,
                        ),
                        child: _selfie == null
                            // --- Better placeholder ---
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                      color: kMutedColor,
                                    ),
                                    kGapTiny,
                                    Text(
                                      'Ambil selfie untuk absen',
                                      style: TextStyle(color: kMutedColor),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: kBorderRadius,
                                child: Image.file(_selfie!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    kGap,
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _pickSelfie,
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Ambil Foto'),
                          ),
                        ),
                        if (_selfie != null) const SizedBox(width: 12),
                        if (_selfie != null)
                          IconButton(
                            onPressed: () => setState(() => _selfie = null),
                            icon: const Icon(Icons.delete_outline),
                            style: IconButton.styleFrom(
                              foregroundColor: kErrorColor,
                              side: const BorderSide(color: kErrorColor),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            kGap,

            // --- Submit Button (Refined) ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSuccessColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
              ),
              onPressed: canSubmit ? _submit : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'ABSEN SEKARANG',
                style: TextStyle(fontSize: 16),
              ),
            ),
            kGap,
            const Text(
              'Tombol "Absen Sekarang" akan aktif jika lokasi valid, selfie sudah diambil, dan Anda belum absen hari ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMutedColor),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper widget untuk menampilkan info lokasi ---
  Widget _buildLocationInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: kMutedColor)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
