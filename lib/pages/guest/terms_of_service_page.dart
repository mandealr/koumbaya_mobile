import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 20),
            _buildSection(
              'Introduction',
              'Bienvenue sur Koumbaya ! Ces conditions d\'utilisation ("Conditions") régissent votre utilisation de l\'application '
              'mobile Koumbaya et des services associés (collectivement, le "Service") exploités par Koumbaya ("nous", "notre" ou "nos"). '
              'En accédant ou en utilisant notre Service, vous acceptez d\'être lié par ces Conditions. Si vous n\'acceptez pas '
              'ces Conditions, vous ne devez pas utiliser notre Service.',
            ),
            _buildSection(
              '1. Acceptation des conditions',
              'En créant un compte et en utilisant notre Service, vous confirmez que :\n\n'
              '• Vous avez au moins 13 ans\n'
              '• Vous avez la capacité juridique de conclure ces Conditions\n'
              '• Vous n\'êtes pas une personne interdite de recevoir des services en vertu des lois du Gabon ou d\'autres juridictions applicables\n'
              '• Vous fournirez des informations véridiques et exactes lors de l\'inscription\n'
              '• Vous maintiendrez la sécurité de votre compte et mot de passe',
            ),
            _buildSection(
              '2. Description du service',
              'Koumbaya est une plateforme de commerce électronique et de loterie qui permet aux utilisateurs de :\n\n'
              '• Acheter et vendre des produits\n'
              '• Participer à des tirages de loterie\n'
              '• Gérer des transactions financières\n'
              '• Interagir avec d\'autres utilisateurs\n'
              '• Accéder à divers services liés au commerce électronique',
            ),
            _buildSection(
              '3. Comptes utilisateurs',
              '',
            ),
            _buildSubSection(
              '3.1 Création de compte',
              'Pour utiliser certaines fonctionnalités du Service, vous devez créer un compte. Vous êtes responsable de :\n\n'
              '• Fournir des informations exactes et complètes\n'
              '• Maintenir la confidentialité de votre mot de passe\n'
              '• Toutes les activités qui se produisent sous votre compte\n'
              '• Notifier immédiatement toute utilisation non autorisée',
            ),
            _buildSubSection(
              '3.2 Types de comptes',
              'Nous proposons différents types de comptes :\n\n'
              '• Compte Acheteur : Pour acheter des produits et participer aux loteries\n'
              '• Compte Vendeur : Pour vendre des produits sur la plateforme\n'
              '• Compte Entreprise : Pour les entités commerciales',
            ),
            _buildSection(
              '4. Utilisation acceptable',
              'Vous acceptez de ne pas :\n\n'
              '• Violer les lois ou règlements applicables\n'
              '• Publier du contenu faux, trompeur ou diffamatoire\n'
              '• Usurper l\'identité d\'une autre personne ou entité\n'
              '• Transmettre des virus ou du code malveillant\n'
              '• Collecter les informations d\'autres utilisateurs sans consentement\n'
              '• Utiliser le Service à des fins illégales ou non autorisées\n'
              '• Interférer avec le bon fonctionnement du Service\n'
              '• Contourner les mesures de sécurité\n'
              '• Vendre des produits contrefaits ou interdits',
            ),
            _buildSection(
              '5. Contenu utilisateur',
              '',
            ),
            _buildSubSection(
              '5.1 Propriété',
              'Vous conservez tous les droits sur le contenu que vous publiez sur le Service. En publiant du contenu, '
              'vous nous accordez une licence mondiale, non exclusive, transférable, sous-licenciable, libre de redevances '
              'pour utiliser, copier, modifier, créer des œuvres dérivées, distribuer et afficher ce contenu.',
            ),
            _buildSubSection(
              '5.2 Responsabilité',
              'Vous êtes seul responsable du contenu que vous publiez. Nous ne cautionnons pas et n\'assumons aucune responsabilité '
              'pour le contenu publié par les utilisateurs.',
            ),
            _buildSection(
              '6. Transactions et paiements',
              '',
            ),
            _buildSubSection(
              '6.1 Transactions',
              'Toutes les transactions sont conclues directement entre acheteurs et vendeurs. Koumbaya facilite ces transactions '
              'mais n\'est pas partie au contrat de vente.',
            ),
            _buildSubSection(
              '6.2 Paiements',
              'Les paiements sont traités via des processeurs de paiement tiers sécurisés. Vous acceptez de :\n\n'
              '• Fournir des informations de paiement valides\n'
              '• Payer tous les frais applicables\n'
              '• Respecter les politiques de remboursement',
            ),
            _buildSubSection(
              '6.3 Frais',
              'Koumbaya peut facturer des frais pour certains services, notamment :\n\n'
              '• Commissions sur les ventes\n'
              '• Frais de listing premium\n'
              '• Frais de transaction\n'
              '• Frais de participation aux loteries',
            ),
            _buildSection(
              '7. Loteries',
              '',
            ),
            _buildSubSection(
              '7.1 Participation',
              'La participation aux loteries est soumise à des règles spécifiques :\n\n'
              '• Vous devez avoir l\'âge légal requis\n'
              '• Les achats de billets sont définitifs et non remboursables\n'
              '• Les gains sont soumis aux lois fiscales applicables\n'
              '• La fraude entraînera la disqualification',
            ),
            _buildSubSection(
              '7.2 Tirages',
              'Les tirages sont effectués de manière aléatoire et transparente. Les résultats sont définitifs et ne peuvent être contestés.',
            ),
            _buildSection(
              '8. Propriété intellectuelle',
              'Le Service et son contenu original, les fonctionnalités et la fonctionnalité sont et resteront la propriété exclusive '
              'de Koumbaya et de ses concédants de licence. Le Service est protégé par le droit d\'auteur, les marques déposées et '
              'd\'autres lois. Nos marques ne peuvent pas être utilisées sans notre consentement écrit préalable.',
            ),
            _buildSection(
              '9. Limitation de responsabilité',
              'Dans toute la mesure permise par la loi applicable, en aucun cas Koumbaya, ses dirigeants, directeurs, employés ou '
              'agents ne seront responsables de dommages indirects, accessoires, spéciaux, consécutifs ou punitifs, y compris, sans '
              'limitation, la perte de profits, de données, d\'utilisation, de bonne volonté ou d\'autres pertes intangibles.',
            ),
            _buildSection(
              '10. Indemnisation',
              'Vous acceptez de défendre, d\'indemniser et de dégager de toute responsabilité Koumbaya et ses concédants de licence '
              'et concédants, et leurs employés, contractants, agents, dirigeants et directeurs, de et contre toutes réclamations, '
              'dommages, obligations, pertes, responsabilités, coûts ou dettes, et dépenses (y compris mais sans s\'y limiter les '
              'frais d\'avocat).',
            ),
            _buildSection(
              '11. Résiliation',
              'Nous pouvons résilier ou suspendre votre compte et interdire l\'accès au Service immédiatement, sans préavis ni '
              'responsabilité, sous notre seule discrétion, pour quelque raison que ce soit et sans limitation, y compris mais '
              'sans s\'y limiter en cas de violation des Conditions. Vous pouvez également supprimer votre compte à tout moment.',
            ),
            _buildSection(
              '12. Modifications des conditions',
              'Nous nous réservons le droit de modifier ces Conditions à tout moment. Si nous apportons des modifications importantes, '
              'nous vous en informerons par e-mail ou par un avis bien visible sur notre Service. Votre utilisation continue du '
              'Service après de telles modifications constitue votre acceptation des nouvelles Conditions.',
            ),
            _buildSection(
              '13. Droit applicable',
              'Ces Conditions sont régies et interprétées conformément aux lois du Gabon, sans égard à ses dispositions relatives '
              'aux conflits de lois. Notre défaut d\'appliquer un droit ou une disposition de ces Conditions ne sera pas considéré '
              'comme une renonciation à ces droits.',
            ),
            _buildSection(
              '14. Divisibilité',
              'Si une disposition de ces Conditions est jugée inapplicable ou invalide, cette disposition sera limitée ou éliminée '
              'dans la mesure minimale nécessaire afin que ces Conditions restent par ailleurs pleinement en vigueur et applicables.',
            ),
            _buildSection(
              '15. Contact',
              'Pour toute question concernant ces Conditions, veuillez nous contacter :\n\n'
              '• Par e-mail : legal@koumbaya.com\n'
              '• Par téléphone : +241 XXX XXX XXX\n'
              '• Par courrier : Koumbaya, [Adresse complète], Gabon',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Dernière mise à jour : 10 septembre 2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (content.isNotEmpty)
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (content.isNotEmpty)
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}