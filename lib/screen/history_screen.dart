import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_record.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryScreen> {
  final _storage = StorageService();
  final _fmt = DateFormat('dd MMM yyyy • HH:mm');

  List<AttendanceRecord> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.getRecords();
    setState(() => _items = list);
  }

  // --- Confirmation Dialog ---
  Future<void> _showClearConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat absensi? Aksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: kErrorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearRecords();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _items.isEmpty
                ? null
                : _showClearConfirmation, // <-- Gunakan dialog
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Bersihkan Riwayat',
          ),
        ],
      ),
      body: _items.isEmpty
          // --- Better empty state ---
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  kGap,
                  const Text(
                    'Belum ada riwayat absensi',
                    style: TextStyle(fontSize: 18, color: kMutedColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(kDefaultPadding / 2),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final it = _items[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: kDefaultPadding / 2,
                    horizontal: kDefaultPadding / 2,
                  ),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: kBorderRadius,
                          child: Image.file(
                            File(it.imagePath),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: kDefaultPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fmt.format(it.timestamp),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              kGapTiny,
                              Text(
                                it.address ??
                                    '${it.latitude.toStringAsFixed(6)}, ${it.longitude.toStringAsFixed(6)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kMutedColor,
                                  fontSize: 12,
                                ),
                              ),
                              kGapSmall,
                              // --- Status Chip ---
                              Chip(
                                label: Text(
                                  it.withinRadius ? 'Valid' : 'Invalid',
                                ),
                                labelStyle: TextStyle(
                                  color: it.withinRadius
                                      ? kSuccessColor
                                      : kErrorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: it.withinRadius
                                    ? kSuccessColor.withOpacity(0.1)
                                    : kErrorColor.withOpacity(0.1),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
