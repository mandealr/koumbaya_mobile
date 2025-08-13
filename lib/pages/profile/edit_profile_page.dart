import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/country.dart';
import '../../models/language.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChangingPassword = false;
  
  List<Country> _countries = [];
  List<Language> _languages = [];
  Country? _selectedCountry;
  Language? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _selectedCountry = user.country;
      _selectedLanguage = user.language;
    }
    
    await _loadCountriesAndLanguages();
  }

  Future<void> _loadCountriesAndLanguages() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final countriesFuture = apiService.getCountries();
      final languagesFuture = apiService.getLanguages();
      
      final results = await Future.wait([countriesFuture, languagesFuture]);
      
      setState(() {
        _countries = results[0] as List<Country>;
        _languages = results[1] as List<Language>;
      });
    } catch (e) {
      _showErrorMessage('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Modifier le profil',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text(
              'Sauvegarder',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileImageSection(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildSecuritySection(),
                    const SizedBox(height: 24),
                    _buildPasswordSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    final user = context.watch<AuthProvider>().user;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: user != null
                      ? Text(
                          '${user.firstName[0]}${user.lastName[0]}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.person, size: 50),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _changeProfileImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
              style: const TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'Informations personnelles',
      [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration('Prénom', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration('Nom', Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: _inputDecoration('Email', Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'email est requis';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format d\'email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: _inputDecoration('Téléphone', Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                return 'Format de téléphone invalide';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      'Localisation et préférences',
      [
        DropdownButtonFormField<Country>(
          value: _selectedCountry,
          decoration: _inputDecoration('Pays', Icons.flag),
          items: _countries.map((country) {
            return DropdownMenuItem<Country>(
              value: country,
              child: Row(
                children: [
                  if (country.flag != null) ...[
                    Image.network(
                      country.flag!,
                      width: 24,
                      height: 18,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.flag, size: 18),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: Text(country.name)),
                ],
              ),
            );
          }).toList(),
          onChanged: (country) {
            setState(() => _selectedCountry = country);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Language>(
          value: _selectedLanguage,
          decoration: _inputDecoration('Langue', Icons.language),
          items: _languages.map((language) {
            return DropdownMenuItem<Language>(
              value: language,
              child: Text(language.name),
            );
          }).toList(),
          onChanged: (language) {
            setState(() => _selectedLanguage = language);
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    final user = context.watch<AuthProvider>().user;
    
    return _buildSection(
      'Sécurité',
      [
        _buildSecurityItem(
          'Email vérifié',
          user?.verifiedAt != null ? 'Vérifié' : 'Non vérifié',
          user?.verifiedAt != null ? Icons.verified : Icons.warning,
          user?.verifiedAt != null ? AppConstants.primaryColor : Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildSecurityItem(
          'Authentification à 2 facteurs',
          user?.mfaIsActive == true ? 'Activée' : 'Désactivée',
          user?.mfaIsActive == true ? Icons.security : Icons.security_outlined,
          user?.mfaIsActive == true ? AppConstants.primaryColor : Colors.grey,
          onTap: _toggle2FA,
        ),
        const SizedBox(height: 12),
        _buildSecurityItem(
          'Dernière connexion',
          user?.lastLoginDate != null 
              ? _formatDate(user!.lastLoginDate!)
              : 'Jamais',
          Icons.access_time,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildSecurityItem(
    String title,
    String value,
    IconData icon,
    Color color,
    {VoidCallback? onTap}
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return _buildSection(
      'Changer le mot de passe',
      [
        SwitchListTile(
          title: const Text(
            'Modifier le mot de passe',
            style: TextStyle(fontFamily: 'AmazonEmberDisplay'),
          ),
          value: _isChangingPassword,
          onChanged: (value) {
            setState(() {
              _isChangingPassword = value;
              if (!value) {
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              }
            });
          },
          activeColor: AppColors.primary,
        ),
        if (_isChangingPassword) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentPasswordController,
            decoration: _inputDecoration(
              'Mot de passe actuel',
              Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: _isChangingPassword
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe actuel est requis';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            decoration: _inputDecoration(
              'Nouveau mot de passe',
              Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(_isNewPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
              ),
            ),
            obscureText: !_isNewPasswordVisible,
            validator: _isChangingPassword
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nouveau mot de passe est requis';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: _inputDecoration(
              'Confirmer le nouveau mot de passe',
              Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
            obscureText: !_isConfirmPasswordVisible,
            validator: _isChangingPassword
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'La confirmation est requise';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Sauvegarder les modifications',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      labelStyle: const TextStyle(fontFamily: 'AmazonEmberDisplay'),
    );
  }

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera capture
                _showInfoMessage('Fonctionnalité à venir !');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery selection
                _showInfoMessage('Fonctionnalité à venir !');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Supprimer la photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement photo removal
                _showInfoMessage('Fonctionnalité à venir !');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggle2FA() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentification à 2 facteurs'),
        content: const Text(
          'Cette fonctionnalité sera bientôt disponible pour renforcer la sécurité de votre compte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare update data
      final updateData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'country_id': _selectedCountry?.id,
        'language_id': _selectedLanguage?.id,
      };

      // Add password data if changing password
      if (_isChangingPassword) {
        updateData.addAll({
          'current_password': _currentPasswordController.text,
          'password': _newPasswordController.text,
          'password_confirmation': _confirmPasswordController.text,
        });
      }

      // Update profile via AuthProvider
      await context.read<AuthProvider>().updateProfile(updateData);

      if (mounted) {
        _showSuccessMessage('Profil mis à jour avec succès !');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de la mise à jour: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} à ${date.hour.toString().padLeft(2, '0')}h'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}