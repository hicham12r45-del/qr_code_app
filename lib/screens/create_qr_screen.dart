import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/qr_item.dart';
import '../theme/app_theme.dart';
import 'qr_result_screen.dart';

class CreateQrScreen extends StatefulWidget {
  final QrType? initialType;
  const CreateQrScreen({super.key, this.initialType});

  @override
  State<CreateQrScreen> createState() => _CreateQrScreenState();
}

class _CreateQrScreenState extends State<CreateQrScreen> {
  late QrType _selectedType;

  // Controllers per type
  final _websiteUrlCtrl = TextEditingController(text: 'https://');
  final _websiteTitleCtrl = TextEditingController();

  final _textCtrl = TextEditingController();
  final _textTitleCtrl = TextEditingController();

  final _wifiSsidCtrl = TextEditingController();
  final _wifiPassCtrl = TextEditingController();
  String _wifiSecurity = 'WPA';

  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();

  final _emailAddrCtrl = TextEditingController();
  final _emailSubjectCtrl = TextEditingController();
  final _emailBodyCtrl = TextEditingController();

  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? QrType.website;
  }

  @override
  void dispose() {
    _websiteUrlCtrl.dispose();
    _websiteTitleCtrl.dispose();
    _textCtrl.dispose();
    _textTitleCtrl.dispose();
    _wifiSsidCtrl.dispose();
    _wifiPassCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactEmailCtrl.dispose();
    _emailAddrCtrl.dispose();
    _emailSubjectCtrl.dispose();
    _emailBodyCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create QR Code'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeGrid(),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canGenerate() ? _generate : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Generate QR Code'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeGrid() {
    final types = [
      (QrType.website, Icons.public_rounded),
      (QrType.text, Icons.description_rounded),
      (QrType.wifi, Icons.wifi_rounded),
      (QrType.contact, Icons.person_rounded),
      (QrType.email, Icons.email_rounded),
      (QrType.phone, Icons.phone_rounded),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: types.map((t) {
        final selected = _selectedType == t.$1;
        return InkWell(
          onTap: () => setState(() => _selectedType = t.$1),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: selected ? null : Border.all(color: AppTheme.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(t.$2,
                    color: selected ? Colors.white : AppTheme.textPrimary,
                    size: 22),
                const SizedBox(height: 6),
                Text(
                  t.$1.label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForm() {
    switch (_selectedType) {
      case QrType.website:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Website URL'),
            _textField(_websiteUrlCtrl,
                hint: 'https://www.example.com',
                icon: Icons.link_rounded,
                keyboardType: TextInputType.url),
            const SizedBox(height: 18),
            _label('Title (optional)'),
            _textField(_websiteTitleCtrl,
                hint: 'My Website', icon: Icons.title_rounded),
          ],
        );
      case QrType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Title (optional)'),
            _textField(_textTitleCtrl,
                hint: 'Welcome!', icon: Icons.title_rounded),
            const SizedBox(height: 18),
            _label('Text'),
            _textField(_textCtrl,
                hint: 'Type your text here', maxLines: 5),
          ],
        );
      case QrType.wifi:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Network Name (SSID)'),
            _textField(_wifiSsidCtrl,
                hint: 'Home Network', icon: Icons.wifi_rounded),
            const SizedBox(height: 18),
            _label('Password'),
            _textField(_wifiPassCtrl,
                hint: 'Wi-Fi password', icon: Icons.lock_rounded),
            const SizedBox(height: 18),
            _label('Security'),
            Row(
              children: ['WPA', 'WEP', 'None'].map((s) {
                final selected = _wifiSecurity == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (_) => setState(() => _wifiSecurity = s),
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppTheme.surface,
                    side: BorderSide(
                        color: selected ? AppTheme.primary : AppTheme.divider),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case QrType.contact:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Full Name'),
            _textField(_contactNameCtrl,
                hint: 'John Doe', icon: Icons.person_rounded),
            const SizedBox(height: 18),
            _label('Phone'),
            _textField(_contactPhoneCtrl,
                hint: '+1 234 567 890',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 18),
            _label('Email (optional)'),
            _textField(_contactEmailCtrl,
                hint: 'john@example.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress),
          ],
        );
      case QrType.email:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Email Address'),
            _textField(_emailAddrCtrl,
                hint: 'hello@example.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 18),
            _label('Subject (optional)'),
            _textField(_emailSubjectCtrl,
                hint: 'Subject', icon: Icons.subject_rounded),
            const SizedBox(height: 18),
            _label('Message (optional)'),
            _textField(_emailBodyCtrl, hint: 'Message', maxLines: 4),
          ],
        );
      case QrType.phone:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Phone Number'),
            _textField(_phoneCtrl,
                hint: '+1 234 567 890',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone),
          ],
        );
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            color: AppTheme.textPrimary,
          ),
        ),
      );

  Widget _textField(
    TextEditingController controller, {
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: AppTheme.textSecondary, size: 20)
            : null,
      ),
    );
  }

  bool _canGenerate() {
    switch (_selectedType) {
      case QrType.website:
        return _websiteUrlCtrl.text.trim().length > 8;
      case QrType.text:
        return _textCtrl.text.trim().isNotEmpty;
      case QrType.wifi:
        return _wifiSsidCtrl.text.trim().isNotEmpty;
      case QrType.contact:
        return _contactNameCtrl.text.trim().isNotEmpty &&
            _contactPhoneCtrl.text.trim().isNotEmpty;
      case QrType.email:
        return _emailAddrCtrl.text.trim().contains('@');
      case QrType.phone:
        return _phoneCtrl.text.trim().isNotEmpty;
    }
  }

  void _generate() {
    final id = const Uuid().v4();
    final now = DateTime.now();
    String data;
    String title;

    switch (_selectedType) {
      case QrType.website:
        data = _websiteUrlCtrl.text.trim();
        title = _websiteTitleCtrl.text.trim().isNotEmpty
            ? _websiteTitleCtrl.text.trim()
            : 'Website - ${_shortUrl(data)}';
        break;
      case QrType.text:
        data = _textCtrl.text.trim();
        title = _textTitleCtrl.text.trim().isNotEmpty
            ? _textTitleCtrl.text.trim()
            : 'Text - ${data.length > 20 ? '${data.substring(0, 20)}…' : data}';
        break;
      case QrType.wifi:
        final ssid = _wifiSsidCtrl.text.trim();
        final pass = _wifiPassCtrl.text.trim();
        final sec = _wifiSecurity == 'None' ? 'nopass' : _wifiSecurity;
        data = 'WIFI:T:$sec;S:$ssid;P:$pass;;';
        title = 'Wi-Fi - $ssid';
        break;
      case QrType.contact:
        final name = _contactNameCtrl.text.trim();
        final phone = _contactPhoneCtrl.text.trim();
        final email = _contactEmailCtrl.text.trim();
        data = 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nTEL:$phone'
            '${email.isNotEmpty ? '\nEMAIL:$email' : ''}\nEND:VCARD';
        title = 'Contact - $name';
        break;
      case QrType.email:
        final addr = _emailAddrCtrl.text.trim();
        final subject = Uri.encodeComponent(_emailSubjectCtrl.text.trim());
        final body = Uri.encodeComponent(_emailBodyCtrl.text.trim());
        data = 'mailto:$addr?subject=$subject&body=$body';
        title = 'Email - $addr';
        break;
      case QrType.phone:
        final phone = _phoneCtrl.text.trim();
        data = 'tel:$phone';
        title = 'Phone - $phone';
        break;
    }

    final item = QrItem(
      id: id,
      type: _selectedType,
      title: title,
      data: data,
      createdAt: now,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrResultScreen(
          item: item,
          isNew: true,
          onSaved: (savedItem) {
            Navigator.of(context).pop(savedItem);
          },
        ),
      ),
    );
  }

  String _shortUrl(String url) {
    return url.replaceFirst(RegExp(r'^https?://'), '');
  }
}
