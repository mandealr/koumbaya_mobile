import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_widget.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Changer le mot de passe',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/profile');
          },
        ),
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
                    _buildSecurityInfo(),
                    const SizedBox(height: 24),
                    _buildPasswordForm(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSecurityInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.security,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sécurité de votre compte',
              style: const TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Changez votre mot de passe pour protéger votre compte. Utilisez un mot de passe fort avec au moins 8 caractères.',
              textAlign: TextAlign.center,
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

  Widget _buildPasswordForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modification du mot de passe',
              style: const TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Current Password
            TextFormField(
              controller: _currentPasswordController,
              decoration: _inputDecoration(
                'Mot de passe actuel',
                Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(_isCurrentPasswordVisible 
                      ? Icons.visibility_off 
                      : Icons.visibility),
                  onPressed: () => setState(() => 
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                ),
              ),
              obscureText: !_isCurrentPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe actuel est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // New Password
            TextFormField(
              controller: _newPasswordController,
              decoration: _inputDecoration(
                'Nouveau mot de passe',
                Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(_isNewPasswordVisible 
                      ? Icons.visibility_off 
                      : Icons.visibility),
                  onPressed: () => setState(() => 
                      _isNewPasswordVisible = !_isNewPasswordVisible),
                ),
              ),
              obscureText: !_isNewPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nouveau mot de passe est requis';
                }
                if (value.length < 8) {
                  return 'Le mot de passe doit contenir au moins 8 caractères';
                }
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                  return 'Le mot de passe doit contenir au moins une minuscule, une majuscule et un chiffre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              decoration: _inputDecoration(
                'Confirmer le nouveau mot de passe',
                Icons.lock_person,
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible 
                      ? Icons.visibility_off 
                      : Icons.visibility),
                  onPressed: () => setState(() => 
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La confirmation du mot de passe est requise';
                }
                if (value != _newPasswordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            _buildPasswordStrengthIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    String password = _newPasswordController.text;
    int strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Force du mot de passe',
          style: TextStyle(
            fontFamily: 'AmazonEmberDisplay',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            strength <= 1 ? Colors.red :
            strength <= 2 ? Colors.orange :
            strength <= 3 ? Colors.yellow :
            Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getPasswordStrengthText(strength),
          style: TextStyle(
            fontFamily: 'AmazonEmberDisplay',
            fontSize: 12,
            color: strength <= 1 ? Colors.red :
                   strength <= 2 ? Colors.orange :
                   strength <= 3 ? Colors.yellow :
                   Colors.green,
          ),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Très faible';
      case 2:
        return 'Faible';
      case 3:
        return 'Moyen';
      case 4:
        return 'Fort';
      case 5:
        return 'Très fort';
      default:
        return 'Très faible';
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
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
                    'Changer le mot de passe',
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
            onPressed: _isLoading ? null : () {
              context.go('/profile');
            },
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
      labelStyle: const TextStyle(
        fontFamily: 'AmazonEmberDisplay',
        color: Color(0xFF5f5f5f),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare password change data
      final passwordData = {
        'current_password': _currentPasswordController.text,
        'password': _newPasswordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      // Change password via AuthProvider
      await context.read<AuthProvider>().changePassword(passwordData);

      if (mounted) {
        _showSuccessMessage('Mot de passe modifié avec succès !');
        // Clear form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        // Go back to profile
        context.go('/profile');
      }
    } catch (e) {
      _showErrorMessage('Erreur lors du changement de mot de passe: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}