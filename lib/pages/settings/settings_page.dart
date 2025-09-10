import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../models/language.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notifications
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _pushNotifications = true;
  
  // Theme is managed by ThemeProvider
  
  // Language
  Language? _selectedLanguage;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      setState(() {
        _emailNotifications = user.emailNotifications ?? true;
        _smsNotifications = user.smsNotifications ?? true;
        _pushNotifications = user.pushNotifications ?? true;
        _selectedLanguage = user.language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/profile');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Notifications par email',
                subtitle: 'Recevoir les mises à jour par email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                  _updateNotificationSettings();
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.sms,
                title: 'Notifications par SMS',
                subtitle: 'Recevoir les alertes importantes par SMS',
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() => _smsNotifications = value);
                  _updateNotificationSettings();
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications push',
                subtitle: 'Recevoir les notifications sur l\'appareil',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                  _updateNotificationSettings();
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Appearance Section
            _buildSectionHeader('Apparence'),
            _buildSettingsCard([
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSwitchTile(
                    icon: Icons.dark_mode,
                    title: 'Mode sombre',
                    subtitle: 'Activer le thème sombre',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.language,
                title: 'Langue',
                subtitle: _selectedLanguage?.name ?? 'Français',
                onTap: _showLanguageDialog,
              ),
            ]),

            const SizedBox(height: 16),

            // Account Section
            _buildSectionHeader('Compte'),
            _buildSettingsCard([
              _buildListTile(
                icon: Icons.security,
                title: 'Authentification à deux facteurs',
                subtitle: 'Gérer la sécurité du compte',
                onTap: () {
                  _showComingSoonMessage('La 2FA sera bientôt disponible');
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Confidentialité',
                subtitle: 'Gérer vos données personnelles',
                onTap: () {
                  _showComingSoonMessage('Les paramètres de confidentialité arrivent bientôt');
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Supprimer le compte',
                subtitle: 'Supprimer définitivement votre compte',
                textColor: Colors.red,
                onTap: _showDeleteAccountDialog,
              ),
            ]),

            const SizedBox(height: 16),

            // About Section
            _buildSectionHeader('À propos'),
            _buildSettingsCard([
              _buildListTile(
                icon: Icons.info,
                title: 'Version de l\'application',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.description,
                title: 'Conditions d\'utilisation',
                subtitle: 'Lire les conditions',
                onTap: () {
                  context.push('/terms-of-service');
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.lock,
                title: 'Politique de confidentialité',
                subtitle: 'Lire la politique',
                onTap: () {
                  context.push('/privacy-policy');
                },
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppConstants.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppConstants.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppConstants.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  void _updateNotificationSettings() async {
    final authProvider = context.read<AuthProvider>();
    
    final updateData = {
      'email_notifications': _emailNotifications,
      'sms_notifications': _smsNotifications,
      'push_notifications': _pushNotifications,
    };

    final success = await authProvider.updateProfile(updateData);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres de notification mis à jour'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    }
  }

  void _showLanguageDialog() {
    final appProvider = context.read<AppProvider>();
    final languages = appProvider.languages;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir la langue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.map((language) {
                return RadioListTile<Language>(
                  title: Text(language.name),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (Language? value) {
                    Navigator.of(context).pop();
                    if (value != null) {
                      setState(() => _selectedLanguage = value);
                      _updateLanguage(value);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _updateLanguage(Language language) async {
    final authProvider = context.read<AuthProvider>();
    
    final updateData = {
      'language_id': language.id,
    };

    final success = await authProvider.updateProfile(updateData);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Langue changée en ${language.name}'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Supprimer le compte',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoonMessage('La suppression de compte sera bientôt disponible');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}