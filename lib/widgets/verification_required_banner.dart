import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';

class VerificationRequiredBanner extends StatelessWidget {
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Function(String email, String maskedEmail)? onVerificationRequested;

  const VerificationRequiredBanner({
    super.key,
    this.actionText,
    this.onActionPressed,
    this.onVerificationRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // N'afficher que si l'utilisateur est connecté mais non vérifié
        if (!authProvider.isAuthenticated || authProvider.isVerified) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade100, Colors.orange.shade50],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.shade300,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compte non vérifié',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vous devez vérifier votre compte pour acheter des articles et participer aux tirages spéciaux.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (onActionPressed != null) {
                        onActionPressed!();
                      } else if (onVerificationRequested != null) {
                        // Utiliser le callback pour laisser la page parent gérer la navigation
                        _goToVerificationWithCallback(context, authProvider);
                      } else {
                        _goToVerification(context, authProvider);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      actionText ?? 'Vérifier maintenant',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToVerificationWithCallback(BuildContext context, AuthProvider authProvider) async {
    print('🔍 _goToVerificationWithCallback called');
    
    if (authProvider.user?.email != null) {
      final email = authProvider.user!.email;
      final maskedEmail = _maskEmail(email);
      
      print('📧 Sending OTP for email: $email');
      
      // Envoyer un nouveau code OTP avant de rediriger
      final success = await authProvider.sendVerificationOtp();
      
      print('📤 OTP send result: $success');
      
      if (success && onVerificationRequested != null) {
        print('🔄 Calling parent callback for navigation');
        onVerificationRequested!(email, maskedEmail);
      } else if (!success) {
        print('❌ OTP send failed: ${authProvider.errorMessage}');
        
        // Afficher un message d'erreur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Impossible d\'envoyer le code de vérification.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('❌ No email found for user');
    }
  }

  void _goToVerification(BuildContext context, AuthProvider authProvider) async {
    print('🔍 _goToVerification called');
    
    if (authProvider.user?.email != null) {
      final email = authProvider.user!.email;
      final maskedEmail = _maskEmail(email);
      
      print('📧 Sending OTP for email: $email');
      
      // Envoyer un nouveau code OTP avant de rediriger
      final success = await authProvider.sendVerificationOtp();
      
      print('📤 OTP send result: $success');
      
      if (success) {
        // Rediriger vers la page de vérification
        if (context.mounted) {
          final url = '/verify-otp?email=${Uri.encodeComponent(email)}&masked_email=${Uri.encodeComponent(maskedEmail)}';
          print('🔄 Redirecting to: $url');
          
          // Utiliser un délai très court et GoRouter directement
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              print('🔄 Actually redirecting now with addPostFrameCallback...');
              try {
                // Utiliser GoRouter directement
                GoRouter.of(context).go(url);
                print('✅ GoRouter.of(context).go executed successfully');
              } catch (e) {
                print('❌ Error with GoRouter.of(context).go: $e');
                // Dernière tentative avec Navigator
                try {
                  Navigator.of(context).pushReplacementNamed('/verify-otp');
                  print('✅ Navigator.pushReplacementNamed executed successfully');
                } catch (e2) {
                  print('❌ Error with Navigator: $e2');
                }
              }
            } else {
              print('❌ Context not mounted after addPostFrameCallback');
            }
          });
        } else {
          print('❌ Context not mounted, cannot redirect');
        }
      } else {
        print('❌ OTP send failed: ${authProvider.errorMessage}');
        
        // Afficher un message d'erreur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Impossible d\'envoyer le code de vérification.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('❌ No email found for user');
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final localPart = parts[0];
    final domain = parts[1];
    
    if (localPart.length <= 2) {
      return '${'*' * localPart.length}@$domain';
    }
    
    final maskedLocal = localPart.substring(0, 2) + '*' * (localPart.length - 2);
    return '$maskedLocal@$domain';
  }
}