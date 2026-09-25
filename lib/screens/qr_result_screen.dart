import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/qr_item.dart';
import '../theme/app_theme.dart';

class QrResultScreen extends StatefulWidget {
  final QrItem item;
  final bool isNew;
  final ValueChanged<QrItem> onSaved;

  const QrResultScreen({
    super.key,
    required this.item,
    required this.isNew,
    required this.onSaved,
  });

  @override
  State<QrResultScreen> createState() => _QrResultScreenState();
}

class _QrResultScreenState extends State<QrResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late QrItem _item;
  bool _savedFlag = false;
  bool _showSavedBanner = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _savedFlag = !widget.isNew;
  }

  IconData get _typeIcon {
    switch (_item.type) {
      case QrType.website:
        return Icons.public_rounded;
      case QrType.text:
        return Icons.description_rounded;
      case QrType.wifi:
        return Icons.wifi_rounded;
      case QrType.contact:
        return Icons.person_rounded;
      case QrType.email:
        return Icons.email_rounded;
      case QrType.phone:
        return Icons.phone_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            _saveIfNeeded();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('QR Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCard(),
              const SizedBox(height: 20),
              _qrPreview(),
              const SizedBox(height: 24),
              _colorPicker(),
              const SizedBox(height: 20),
              _stylePicker(),
              const SizedBox(height: 20),
              _logoToggle(),
              const SizedBox(height: 24),
              _actionRow(),
              if (_showSavedBanner) ...[
                const SizedBox(height: 16),
                _savedBanner(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(_item.colorValue),
              shape: BoxShape.circle,
            ),
            child: Icon(_typeIcon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_item.type.label} QR Code',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _item.data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Created ${DateFormat('MMM d, h:mm a').format(_item.createdAt)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrPreview() {
    return Center(
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: _item.data.isEmpty ? ' ' : _item.data,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: QrEyeStyle(
                  eyeShape: _item.styleIndex == 3
                      ? QrEyeShape.circle
                      : QrEyeShape.square,
                  color: Color(_item.colorValue),
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: _item.styleIndex == 2
                      ? QrDataModuleShape.circle
                      : QrDataModuleShape.square,
                  color: const Color(0xFF1B2B4B),
                ),
              ),
              if (_item.logoEnabled)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(_item.colorValue),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(_typeIcon, color: Colors.white, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorPicker() {
    return Row(
      children: [
        const SizedBox(
          width: 70,
          child: Text('Color',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppTheme.textPrimary)),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: AppTheme.qrColorOptions.map((c) {
              final selected = c.value == _item.colorValue;
              return GestureDetector(
                onTap: () => setState(
                    () => _item = _item.copyWith(colorValue: c.value)),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: AppTheme.textPrimary, width: 2.4)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _stylePicker() {
    final styleIcons = [
      Icons.crop_free_rounded,
      Icons.filter_center_focus_rounded,
      Icons.blur_on_rounded,
      Icons.radio_button_unchecked_rounded,
    ];
    return Row(
      children: [
        const SizedBox(
          width: 70,
          child: Text('Style',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppTheme.textPrimary)),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              final selected = _item.styleIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _item = _item.copyWith(styleIndex: i)),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.divider,
                        width: selected ? 1.6 : 1),
                  ),
                  child: Icon(styleIcons[i],
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      size: 20),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _logoToggle() {
    return Row(
      children: [
        const Expanded(
          child: Text('Logo',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppTheme.textPrimary)),
        ),
        Switch(
          value: _item.logoEnabled,
          activeColor: AppTheme.primary,
          onChanged: (v) => setState(() => _item = _item.copyWith(logoEnabled: v)),
        ),
      ],
    );
  }

  Widget _actionRow() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
              icon: Icons.bookmark_border_rounded,
              label: 'Save',
              onTap: () {
                _saveIfNeeded(showBanner: true);
              }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
              icon: Icons.share_rounded, label: 'Share', onTap: _share),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
              icon: Icons.download_rounded,
              label: 'Download',
              onTap: _download),
        ),
      ],
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget _savedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.wifiBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.wifiFg, size: 18),
          const SizedBox(width: 8),
          Text('Saved to History',
              style: TextStyle(
                  color: AppTheme.wifiFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5)),
        ],
      ),
    );
  }

  void _saveIfNeeded({bool showBanner = false}) {
    widget.onSaved(_item);
    setState(() {
      _savedFlag = true;
      if (showBanner) _showSavedBanner = true;
    });
  }

  Future<String?> _renderToFile() async {
    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3);
      if (bytes == null) return null;
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/qr_${_item.id}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _share() async {
    final path = await _renderToFile();
    if (path != null) {
      await Share.shareXFiles([XFile(path)], text: _item.title);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not share QR code')));
    }
  }

  Future<void> _download() async {
    final path = await _renderToFile();
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved image to $path')),
      );
      _saveIfNeeded();
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not save QR code')));
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppTheme.primary),
              title: const Text('Copy data'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFE84366)),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
