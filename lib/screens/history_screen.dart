import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/qr_item.dart';
import '../theme/app_theme.dart';
import 'qr_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  final List<QrItem> history;
  final ValueChanged<QrItem> onItemUpdated;
  final ValueChanged<String> onItemDeleted;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onItemUpdated,
    required this.onItemDeleted,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  QrType? _filterType;

  List<QrItem> get _filtered {
    var items = widget.history;
    if (_filterType != null) {
      items = items.where((e) => e.type == _filterType).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      items = items
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.data.toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 18),
            _searchBar(),
            const SizedBox(height: 14),
            _filterChips(),
            const SizedBox(height: 14),
            Expanded(
              child: items.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _HistoryTile(
                          item: item,
                          onOpen: () => _open(item),
                          onShare: () => _share(item),
                          onDelete: () => _delete(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.websiteBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_2_rounded,
              color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('History',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text('Your saved QR codes',
                  style:
                      TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
              color: AppTheme.surface, shape: BoxShape.circle),
          child: const Icon(Icons.settings_rounded,
              color: AppTheme.textPrimary, size: 20),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      style: const TextStyle(fontSize: 14.5),
      decoration: const InputDecoration(
        hintText: 'Search QR codes...',
        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _filterChips() {
    final options = <(String, QrType?)>[
      ('All', null),
      ('Website', QrType.website),
      ('Text', QrType.text),
      ('Wi-Fi', QrType.wifi),
      ('Contact', QrType.contact),
      ('Email', QrType.email),
      ('Phone', QrType.phone),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, type) = options[i];
          final selected = _filterType == type;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _filterType = type),
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            side: BorderSide(
                color: selected ? AppTheme.primary : AppTheme.divider),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.websiteBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.inbox_rounded,
                  color: AppTheme.primary, size: 30),
            ),
            const SizedBox(height: 14),
            const Text('No history yet',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              'Your scanned and created QR codes\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  void _open(QrItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrResultScreen(
          item: item,
          isNew: false,
          onSaved: widget.onItemUpdated,
        ),
      ),
    );
  }

  Future<void> _share(QrItem item) async {
    await Share.share(item.data, subject: item.title);
  }

  void _delete(QrItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete QR Code'),
        content: Text('Delete "${item.title}" from history?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onItemDeleted(item.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFE84366))),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final QrItem item;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.item,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  (Color, Color) get _colors {
    switch (item.type) {
      case QrType.website:
        return (AppTheme.websiteBg, AppTheme.websiteFg);
      case QrType.text:
        return (AppTheme.textBg, AppTheme.textFg);
      case QrType.wifi:
        return (AppTheme.wifiBg, AppTheme.wifiFg);
      case QrType.contact:
        return (AppTheme.contactBg, AppTheme.contactFg);
      case QrType.email:
        return (AppTheme.emailBg, AppTheme.emailFg);
      case QrType.phone:
        return (AppTheme.phoneBg, AppTheme.phoneFg);
    }
  }

  IconData get _icon {
    switch (item.type) {
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
    final colors = _colors;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
                color: colors.$1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: colors.$2, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.$1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.type.label,
                            style: TextStyle(
                                color: colors.$2,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy, h:mm a')
                            .format(item.createdAt),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.textSecondary, size: 20),
              onSelected: (value) {
                if (value == 'open') onOpen();
                if (value == 'share') onShare();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'open',
                    child: Row(children: [
                      Icon(Icons.open_in_new_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Open'),
                    ])),
                const PopupMenuItem(
                    value: 'share',
                    child: Row(children: [
                      Icon(Icons.share_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Share'),
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Color(0xFFE84366)),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Color(0xFFE84366))),
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
