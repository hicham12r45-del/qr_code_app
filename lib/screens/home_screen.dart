import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/qr_item.dart';
import '../theme/app_theme.dart';
import 'create_qr_screen.dart';
import 'qr_result_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<QrItem> history;
  final VoidCallback onOpenSettings;
  final ValueChanged<QrItem> onItemCreated;
  final VoidCallback onGoToHistory;
  final VoidCallback onGoToScan;

  const HomeScreen({
    super.key,
    required this.history,
    required this.onOpenSettings,
    required this.onItemCreated,
    required this.onGoToHistory,
    required this.onGoToScan,
  });

  @override
  Widget build(BuildContext context) {
    final recent = history.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildHero(context),
            const SizedBox(height: 20),
            _buildPrimaryButton(
              context,
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan QR Code',
              filled: true,
              onTap: onGoToScan,
            ),
            const SizedBox(height: 12),
            _buildPrimaryButton(
              context,
              icon: Icons.add_circle_rounded,
              label: 'Create QR Code',
              filled: false,
              onTap: () => _openCreate(context),
            ),
            const SizedBox(height: 28),
            _sectionHeader(context, 'Quick Create', 'See All', () {
              _openCreate(context);
            }),
            const SizedBox(height: 14),
            _buildQuickGrid(context),
            const SizedBox(height: 28),
            _sectionHeader(context, 'Recent Activity', 'View All', onGoToHistory),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              _emptyRecent(context)
            else
              ...recent.map((item) => _RecentTile(
                    item: item,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QrResultScreen(
                          item: item,
                          onSaved: (_) {},
                          isNew: false,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              color: AppTheme.primary, size: 26),
        ),
        const SizedBox(width: 12),
        const Text(
          'QR Code',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onOpenSettings,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_rounded,
                color: AppTheme.textPrimary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hello!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Scan, create and manage\nyour QR codes easily.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppTheme.websiteBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.qr_code_rounded,
              color: AppTheme.primary, size: 42),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: AppTheme.divider),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: filled ? Colors.white : AppTheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: filled ? Colors.white : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
      BuildContext context, String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickGrid(BuildContext context) {
    final tiles = [
      _QuickTile(
        icon: Icons.public_rounded,
        label: 'Website',
        bg: AppTheme.websiteBg,
        fg: AppTheme.websiteFg,
        type: QrType.website,
      ),
      _QuickTile(
        icon: Icons.description_rounded,
        label: 'Text',
        bg: AppTheme.textBg,
        fg: AppTheme.textFg,
        type: QrType.text,
      ),
      _QuickTile(
        icon: Icons.wifi_rounded,
        label: 'Wi-Fi',
        bg: AppTheme.wifiBg,
        fg: AppTheme.wifiFg,
        type: QrType.wifi,
      ),
      _QuickTile(
        icon: Icons.person_rounded,
        label: 'Contact',
        bg: AppTheme.contactBg,
        fg: AppTheme.contactFg,
        type: QrType.contact,
      ),
      _QuickTile(
        icon: Icons.email_rounded,
        label: 'Email',
        bg: AppTheme.emailBg,
        fg: AppTheme.emailFg,
        type: QrType.email,
      ),
      _QuickTile(
        icon: Icons.phone_rounded,
        label: 'Phone',
        bg: AppTheme.phoneBg,
        fg: AppTheme.phoneFg,
        type: QrType.phone,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: tiles
          .map((t) => _QuickCreateCard(
                tile: t,
                onTap: () => _openCreate(context, initialType: t.type),
              ))
          .toList(),
    );
  }

  Widget _emptyRecent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Text(
        'No QR codes yet.\nCreate or scan one to get started.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
      ),
    );
  }

  void _openCreate(BuildContext context, {QrType? initialType}) async {
    final result = await Navigator.of(context).push<QrItem>(
      MaterialPageRoute(
        builder: (_) => CreateQrScreen(initialType: initialType),
      ),
    );
    if (result != null) {
      onItemCreated(result);
    }
  }
}

class _QuickTile {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final QrType type;

  _QuickTile({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.type,
  });
}

class _QuickCreateCard extends StatelessWidget {
  final _QuickTile tile;
  final VoidCallback onTap;

  const _QuickCreateCard({required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: tile.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tile.icon, color: tile.fg, size: 26),
            const SizedBox(height: 8),
            Text(
              tile.label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final QrItem item;
  final VoidCallback onTap;

  const _RecentTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _typeColors(item.type);
    return InkWell(
      onTap: onTap,
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
              child: Icon(Icons.qr_code_rounded, color: colors.$2, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
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
                        child: Text(
                          item.type.label,
                          style: TextStyle(
                            color: colors.$2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, h:mm a').format(item.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

(Color, Color) _typeColors(QrType type) {
  switch (type) {
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
