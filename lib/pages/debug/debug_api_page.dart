import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DebugApiPage extends StatefulWidget {
  const DebugApiPage({super.key});

  @override
  State<DebugApiPage> createState() => _DebugApiPageState();
}

class _DebugApiPageState extends State<DebugApiPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _result = 'Veuillez remplir l\'email et le mot de passe';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Test en cours...';
    });

    try {
      final apiService = ApiService();
      final response = await apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _result = '''
✅ SUCCÈS:
Token: ${response.token?.substring(0, 20)}...
User: ${response.user?.firstName} ${response.user?.lastName}
Email: ${response.user?.email}
Success: ${response.success}
Message: ${response.message}
''';
      });
    } catch (e) {
      setState(() {
        _result = '''
❌ ERREUR:
Type: ${e.runtimeType}
Message: $e
''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testProvider() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _result = 'Veuillez remplir l\'email et le mot de passe';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Test AuthProvider en cours...';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _result = '''
🔒 AUTHPROVIDER:
Succès: $success
Authentifié: ${authProvider.isAuthenticated}
Utilisateur: ${authProvider.user?.firstName} ${authProvider.user?.lastName}
Erreur: ${authProvider.errorMessage ?? 'Aucune'}
''';
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Debug API',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test de connexion API',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                '✅ Authentification fonctionnelle avec génération de token temporaire.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Boutons de test
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Test API Direct'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testProvider,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Test Provider'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Résultats
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          _result.isEmpty ? 'Résultats du test s\'afficheront ici...' : _result,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}