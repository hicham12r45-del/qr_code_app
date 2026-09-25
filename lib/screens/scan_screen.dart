import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../models/qr_item.dart';
import '../theme/app_theme.dart';
import 'qr_result_screen.dart';

class ScanScreen extends StatefulWidget {
  final ValueChanged<QrItem> onScanned;
  const ScanScreen({super.key, required this.onScanned});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _torchOn = false;
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handled = true;

    final item = QrItem(
      id: const Uuid().v4(),
      type: _guessType(raw),
      title: _guessTitle(raw),
      data: raw,
      createdAt: DateTime.now(),
      isScanned: true,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QrResultScreen(
          item: item,
          isNew: true,
          onSaved: (saved) {
            widget.onScanned(saved);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  QrType _guessType(String raw) {
    if (raw.startsWith('WIFI:')) return QrType.wifi;
    if (raw.startsWith('BEGIN:VCARD')) return QrType.contact;
    if (raw.startsWith('mailto:')) return QrType.email;
    if (raw.startsWith('tel:')) return QrType.phone;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return QrType.website;
    }
    return QrType.text;
  }

  String _guessTitle(String raw) {
    final type = _guessType(raw);
    switch (type) {
      case QrType.website:
        return 'Website - ${raw.replaceFirst(RegExp(r'^https?://'), '')}';
      case QrType.wifi:
        final match = RegExp(r'S:([^;]*);').firstMatch(raw);
        return 'Wi-Fi - ${match?.group(1) ?? 'Network'}';
      case QrType.contact:
        final match = RegExp(r'FN:([^\n]*)').firstMatch(raw);
        return 'Contact - ${match?.group(1) ?? 'Unknown'}';
      case QrType.email:
        return 'Email - ${raw.replaceFirst('mailto:', '').split('?').first}';
      case QrType.phone:
        return 'Phone - ${raw.replaceFirst('tel:', '')}';
      case QrType.text:
        return 'Text - ${raw.length > 20 ? '${raw.substring(0, 20)}…' : raw}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          SafeArea(
            child: Column(
              children: [
                _topBar(context),
                const Spacer(),
                _scanFrame(),
                const SizedBox(height: 28),
                const Text(
                  'Align the QR code within the frame\nto scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: 14.5, height: 1.4),
                ),
                const Spacer(),
                _bottomControls(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          _circleIconButton(
            icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            onTap: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _scanFrame() {
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: _CornerFramePainter(),
      ),
    );
  }

  Widget _bottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _bottomAction(
          icon: Icons.image_rounded,
          label: 'Gallery',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Pick a QR image from your gallery')),
            );
          },
        ),
        _bottomAction(
          icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          label: 'Flash',
          onTap: () {
            _controller.toggleTorch();
            setState(() => _torchOn = !_torchOn);
          },
        ),
      ],
    );
  }

  Widget _bottomAction(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
        ..lineTo(size.width, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))
        ..lineTo(len, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - len)
        ..lineTo(size.width, size.height - r)
        ..arcToPoint(Offset(size.width - r, size.height),
            radius: const Radius.circular(r))
        ..lineTo(size.width - len, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
