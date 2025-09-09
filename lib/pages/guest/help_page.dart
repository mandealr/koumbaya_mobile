import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Centre d\'aide',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/guest'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 32),
            _buildQuickHelp(),
            const SizedBox(height: 32),
            _buildFAQSection(),
            const SizedBox(height: 32),
            _buildGuideSection(),
            const SizedBox(height: 32),
            _buildSupportSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_center,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Comment pouvons-nous vous aider ?',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Trouvez rapidement des réponses à vos questions ou contactez notre équipe support.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aide rapide',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickHelpCard(
                'Comment participer',
                'Guide d\'inscription et d\'achat de tickets',
                Icons.how_to_reg,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickHelpCard(
                'Paiements',
                'Méthodes de paiement acceptées',
                Icons.payment,
                AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickHelpCard(
                'Mes gains',
                'Comment récupérer vos prix',
                Icons.card_giftcard,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickHelpCard(
                'Sécurité',
                'Protection de vos données',
                Icons.security,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickHelpCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.h6.copyWith(
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions fréquentes',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'Comment créer un compte ?',
          'Cliquez sur "S\'inscrire", remplissez le formulaire avec vos informations personnelles et validez votre email.',
        ),
        _buildFAQItem(
          'Quelles sont les méthodes de paiement acceptées ?',
          'Nous acceptons Airtel Money et Moov Money pour tous vos achats de tickets de tirage spécial.',
        ),
        _buildFAQItem(
          'Comment savoir si j\'ai gagné ?',
          'Vous recevrez une notification push et un email. Vous pouvez aussi vérifier dans la section "Mes tickets".',
        ),
        _buildFAQItem(
          'Combien de temps pour recevoir mon prix ?',
          'Les prix sont livrés sous 3-7 jours ouvrables après confirmation du gain.',
        ),
        _buildFAQItem(
          'Puis-je annuler un achat de ticket ?',
          'Les achats de tickets ne peuvent pas être annulés une fois confirmés. Assurez-vous avant de valider.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guides détaillés',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildGuideCard(
          'Guide du débutant',
          'Tout ce qu\'il faut savoir pour commencer',
          Icons.school,
          AppColors.primary,
          [
            '1. Créez votre compte',
            '2. Explorez les articles disponibles',
            '3. Achetez vos premiers tickets',
            '4. Suivez les tirages en direct',
            '5. Récupérez vos gains',
          ],
        ),
        const SizedBox(height: 16),
        _buildGuideCard(
          'Sécurité et protection',
          'Comment protéger votre compte',
          Icons.shield,
          AppConstants.primaryColor,
          [
            '• Utilisez un mot de passe fort',
            '• Ne partagez jamais vos identifiants',
            '• Vérifiez toujours les URLs',
            '• Contactez le support en cas de doute',
          ],
        ),
        const SizedBox(height: 16),
        _buildGuideCard(
          'Conseils de participation',
          'Maximisez vos chances',
          Icons.tips_and_updates,
          Colors.orange,
          [
            '• Participez régulièrement',
            '• Diversifiez vos achats',
            '• Suivez les statistiques',
            '• Respectez votre budget',
          ],
        ),
      ],
    );
  }

  Widget _buildGuideCard(String title, String subtitle, IconData icon, Color color, List<String> points) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.h6.copyWith(
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        point,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Besoin d\'aide personnalisée ?',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Notre équipe support est disponible pour vous aider avec toutes vos questions.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/guest/contact'),
                  icon: const Icon(Icons.contact_support),
                  label: const Text('Nous contacter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/register'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('S\'inscrire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}