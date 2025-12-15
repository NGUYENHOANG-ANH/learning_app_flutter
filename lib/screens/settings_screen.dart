import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _ttsEnabled = true;
  double _ttsSpeed = 1.0;
  String _selectedLanguage = 'vi'; // vi or en

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Cài Đặt'),
        backgroundColor: AppColors.accentColor,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Audio Settings Section
            _buildSection(
              title: '🔊 Âm Thanh',
              children: [
                _buildToggleSetting(
                  title: 'Âm Hiệu Ứng',
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() => _soundEnabled = val);
                  },
                ),
                _buildToggleSetting(
                  title: 'Nhạc Nền',
                  value: _musicEnabled,
                  onChanged: (val) {
                    setState(() => _musicEnabled = val);
                  },
                ),
                _buildToggleSetting(
                  title: 'Phát Âm TTS',
                  value: _ttsEnabled,
                  onChanged: (val) {
                    setState(() => _ttsEnabled = val);
                  },
                ),
                _buildSliderSetting(
                  title: 'Tốc Độ Phát Âm',
                  value: _ttsSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (val) {
                    setState(() => _ttsSpeed = val);
                  },
                  label: '${_ttsSpeed.toStringAsFixed(1)}x',
                ),
              ],
            ),

            // Language Settings Section
            _buildSection(
              title: '🌐 Ngôn Ngữ',
              children: [
                _buildRadioSetting(
                  title: 'Tiếng Việt',
                  value: 'vi',
                  groupValue: _selectedLanguage,
                  onChanged: (val) {
                    setState(() => _selectedLanguage = val!);
                  },
                ),
                _buildRadioSetting(
                  title: 'English',
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: (val) {
                    setState(() => _selectedLanguage = val!);
                  },
                ),
              ],
            ),

            // Data Settings Section
            _buildSection(
              title: '📱 Dữ Liệu',
              children: [
                _buildButtonSetting(
                  title: 'Xóa Tiến Độ',
                  subtitle: 'Xóa tất cả dữ liệu học',
                  buttonLabel: 'Xóa',
                  buttonColor: Colors.red,
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                ),
                _buildButtonSetting(
                  title: 'Xuất Dữ Liệu',
                  subtitle: 'Sao lưu tiến độ của bạn',
                  buttonLabel: 'Xuất',
                  buttonColor: Colors.blue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang phát triển.. .')),
                    );
                  },
                ),
              ],
            ),

            // About Section
            _buildSection(
              title: 'ℹ️ Về Ứng Dụng',
              children: [
                _buildInfoSetting(
                  title: 'Phiên Bản',
                  value: '1.0.0',
                ),
                _buildInfoSetting(
                  title: 'Nhà Phát Triển',
                  value: 'Language Learning App',
                ),
                _buildButtonSetting(
                  title: 'Điều Khoản & Điều Kiện',
                  subtitle: 'Đọc các điều khoản sử dụng',
                  buttonLabel: 'Đọc',
                  buttonColor: Colors.grey,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang phát triển...')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: children
                  .map((child) => [
                        child,
                        if (children.indexOf(child) < children.length - 1)
                          Divider(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                      ])
                  .expand((e) => e)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          Switch(
            value: value,
            activeThumbColor: AppColors.accentColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.accentColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioSetting({
    required String title,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          Radio<String>(
            value: value,
            groupValue: groupValue,
            activeColor: AppColors.accentColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSetting({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSetting({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác Nhận'),
        content: const Text('Bạn có chắc muốn xóa tất cả tiến độ học?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tiến độ đã được xóa')),
              );
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
