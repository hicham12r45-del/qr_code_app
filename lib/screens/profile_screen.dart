import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final int totalCodes;
  final VoidCallback onClearHistory;

  const ProfileScreen({
    super.key,
    required this.totalCodes,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppTheme.websiteBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        color: AppTheme.primary, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text('QR Vault',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text('$totalCodes QR codes saved',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _sectionCard([
              _tile(Icons.color_lens_outlined, 'App Theme', 'Light'),
              _tile(Icons.notifications_none_rounded, 'Notifications', 'On'),
              _tile(Icons.language_rounded, 'Language', 'English'),
            ]),
            const SizedBox(height: 16),
            _sectionCard([
              _tile(Icons.privacy_tip_outlined, 'Privacy Policy', ''),
              _tile(Icons.description_outlined, 'Terms of Service', ''),
              _tile(Icons.info_outline_rounded, 'About', 'v1.0.0'),
            ]),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _confirmClear(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFE84366), size: 20),
                    SizedBox(width: 12),
                    Text('Clear All History',
                        style: TextStyle(
                            color: Color(0xFFE84366),
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: List.generate(tiles.length, (i) {
          return Column(
            children: [
              tiles[i],
              if (i != tiles.length - 1)
                const Divider(height: 1, indent: 52),
            ],
          );
        }),
      ),
    );
  }

  Widget _tile(IconData icon, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: AppTheme.textPrimary)),
          ),
          if (trailing.isNotEmpty)
            Text(trailing,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textSecondary, size: 18),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
            'This will permanently delete all saved QR codes. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClearHistory();
            },
            child:
                const Text('Clear', style: TextStyle(color: Color(0xFFE84366))),
          ),
        ],
      ),
    );
  }
}
