import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants/app_constants.dart';
import '../../constants/koumbaya_lexicon.dart';

class BecomeSellerPage extends StatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  State<BecomeSellerPage> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<BecomeSellerPage> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _becomeSeller() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.becomeSeller('individual');

      if (response['success'] == true) {
        // Refresh user data
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Vous êtes maintenant un vendeur !'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigate back to profile
          context.pop();
        }
      } else {
        // Refresh user data même en cas d'erreur (peut-être déjà vendeur)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUser();

        if (mounted) {
          // Vérifier si l'utilisateur est déjà vendeur
          final isAlreadySeller = response['message']?.toString().toLowerCase().contains('déjà') ?? false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Une erreur est survenue'),
              backgroundColor: isAlreadySeller ? Colors.orange : Colors.red,
              duration: Duration(seconds: isAlreadySeller ? 3 : 4),
            ),
          );

          // Si déjà vendeur, retourner au profil
          if (isAlreadySeller) {
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Devenir ${KoumbayaLexicon.seller}'),
          content: Text(
            'Êtes-vous sûr de vouloir devenir un ${KoumbayaLexicon.seller} ? '
            'Vous pourrez créer des ${KoumbayaLexicon.specialDrawShort.toLowerCase()} avec 500 ${KoumbayaLexicon.tickets.toLowerCase()} fixes.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _becomeSeller();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(KoumbayaLexicon.becomeSeller),
        backgroundColor: AppConstants.primaryColor,
        elevation: 1,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.storefront,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Devenez ${KoumbayaLexicon.seller}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vendez vos ${KoumbayaLexicon.articles.toLowerCase()} et créez des ${KoumbayaLexicon.specialDrawShort.toLowerCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Avantages du vendeur individuel
            Text(
              'Avantages du ${KoumbayaLexicon.seller}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildAdvantageCard(
              icon: Icons.confirmation_number,
              title: '500 ${KoumbayaLexicon.tickets} par ${KoumbayaLexicon.specialDrawShort}',
              description: 'Nombre de ${KoumbayaLexicon.tickets.toLowerCase()} optimisé pour maximiser vos ventes',
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _buildAdvantageCard(
              icon: Icons.monetization_on,
              title: 'Prix minimum: 200 FCFA',
              description: 'Vendez vos ${KoumbayaLexicon.articles.toLowerCase()} à partir de 200 FCFA par ${KoumbayaLexicon.ticket.toLowerCase()}',
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _buildAdvantageCard(
              icon: Icons.speed,
              title: 'Configuration simplifiée',
              description: 'Création d\'${KoumbayaLexicon.articles.toLowerCase()} et ${KoumbayaLexicon.specialDrawShort.toLowerCase()} en quelques clics',
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            _buildAdvantageCard(
              icon: Icons.people,
              title: 'Accès aux clients',
              description: 'Rejoignez la communauté des ${KoumbayaLexicon.sellers.toLowerCase()} ${KoumbayaLexicon.platformName}',
              color: Colors.purple,
            ),

            const SizedBox(height: 32),

            // Processus
            const Text(
              'Comment ça marche ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildProcessStep(
              step: '1',
              title: 'Devenez ${KoumbayaLexicon.seller}',
              description: 'Cliquez sur le bouton ci-dessous pour activer votre statut',
            ),

            const SizedBox(height: 12),

            _buildProcessStep(
              step: '2',
              title: 'Créez vos ${KoumbayaLexicon.articles}',
              description: 'Ajoutez vos ${KoumbayaLexicon.articles.toLowerCase()} avec photos et descriptions',
            ),

            const SizedBox(height: 12),

            _buildProcessStep(
              step: '3',
              title: 'Lancez des ${KoumbayaLexicon.specialDrawShort}',
              description: 'Créez des ${KoumbayaLexicon.specialDrawShort.toLowerCase()} avec 500 ${KoumbayaLexicon.tickets.toLowerCase()} automatiquement',
            ),

            const SizedBox(height: 12),

            _buildProcessStep(
              step: '4',
              title: 'Recevez vos gains',
              description: 'Les paiements sont traités automatiquement',
            ),

            const SizedBox(height: 40),

            // Button to become seller
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'En cours...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Devenir ${KoumbayaLexicon.seller}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),
            
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'En devenant ${KoumbayaLexicon.seller}, vous acceptez les conditions générales de vente et vous engagez à respecter la politique de qualité de ${KoumbayaLexicon.platformName}.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantageCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required String step,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}