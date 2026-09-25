import 'package:flutter/material.dart';
import 'models/qr_item.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_nav.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_qr_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QrVaultApp());
}

class QrVaultApp extends StatelessWidget {
  const QrVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final StorageService _storage = StorageService();
  int _tabIndex = 0;
  List<QrItem> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await _storage.loadHistory();
    if (!mounted) return;
    setState(() {
      _history = items;
      _loading = false;
    });
  }

  Future<void> _handleUpsertItem(QrItem item) async {
    final exists = _history.any((e) => e.id == item.id);
    final updated = exists
        ? await _storage.updateItem(item)
        : await _storage.addItem(item);
    if (!mounted) return;
    setState(() => _history = updated);
  }

  Future<void> _handleDeleteItem(String id) async {
    final updated = await _storage.deleteItem(id);
    if (!mounted) return;
    setState(() => _history = updated);
  }

  Future<void> _handleClearHistory() async {
    await _storage.clearAll();
    if (!mounted) return;
    setState(() => _history = []);
  }

  void _goToTab(int index) => setState(() => _tabIndex = index);

  Future<void> _openScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanScreen(onScanned: _handleUpsertItem),
      ),
    );
  }

  Future<void> _openCreate() async {
    final result = await Navigator.of(context).push<QrItem>(
      MaterialPageRoute(builder: (_) => const CreateQrScreen()),
    );
    if (result != null) {
      await _handleUpsertItem(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body:
            Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _bodyForIndex(_tabIndex),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tabIndex,
        onTap: (index) {
          if (index == 3) {
            _openScan();
          } else {
            _goToTab(index);
          }
        },
        onCreateTap: _openCreate,
      ),
    );
  }

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 1:
        return HistoryScreen(
          history: _history,
          onItemUpdated: _handleUpsertItem,
          onItemDeleted: _handleDeleteItem,
        );
      case 4:
        return ProfileScreen(
          totalCodes: _history.length,
          onClearHistory: _handleClearHistory,
        );
      case 0:
      default:
        return HomeScreen(
          history: _history,
          onOpenSettings: () => _goToTab(4),
          onItemCreated: _handleUpsertItem,
          onGoToHistory: () => _goToTab(1),
          onGoToScan: _openScan,
        );
    }
  }
}