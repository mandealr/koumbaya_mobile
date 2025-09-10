import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
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
              'Koumbaya ("nous", "notre" ou "nos") exploite l\'application mobile Koumbaya (ci-après dénommée "Service"). '
              'Cette page vous informe de nos politiques concernant la collecte, l\'utilisation et la divulgation de données personnelles '
              'lorsque vous utilisez notre Service et des choix que vous avez associés à ces données. '
              'Nous utilisons vos données pour fournir et améliorer le Service. En utilisant le Service, vous acceptez '
              'la collecte et l\'utilisation d\'informations conformément à cette politique.',
            ),
            _buildSection(
              '1. Collecte et utilisation des informations',
              'Nous collectons plusieurs types d\'informations à différentes fins pour vous fournir et améliorer notre Service.',
            ),
            _buildSubSection(
              '1.1 Types de données collectées',
              '',
            ),
            _buildSubSection(
              'Données personnelles',
              'Lors de l\'utilisation de notre Service, nous pouvons vous demander de nous fournir certaines informations personnellement identifiables qui peuvent être utilisées pour vous contacter ou vous identifier. Les informations personnellement identifiables peuvent inclure, mais sans s\'y limiter :\n\n'
              '• Adresse e-mail\n'
              '• Prénom et nom\n'
              '• Numéro de téléphone\n'
              '• Adresse postale\n'
              '• Informations de paiement (traitées de manière sécurisée)\n'
              '• Photo de profil (optionnelle)\n'
              '• Cookies et données d\'utilisation',
            ),
            _buildSubSection(
              'Données d\'utilisation',
              'Nous pouvons également collecter des informations sur la manière dont le Service est accédé et utilisé ("Données d\'utilisation"). '
              'Ces données d\'utilisation peuvent inclure des informations telles que l\'adresse IP de votre appareil, le type de navigateur, '
              'la version du navigateur, les pages de notre Service que vous visitez, l\'heure et la date de votre visite, '
              'le temps passé sur ces pages, les identifiants uniques de l\'appareil et d\'autres données de diagnostic.',
            ),
            _buildSubSection(
              'Données de localisation',
              'Nous pouvons utiliser et stocker des informations sur votre localisation si vous nous en donnez la permission ("Données de localisation"). '
              'Nous utilisons ces données pour fournir les fonctionnalités de notre Service, pour améliorer et personnaliser notre Service. '
              'Vous pouvez activer ou désactiver les services de localisation lorsque vous utilisez notre Service à tout moment '
              'via les paramètres de votre appareil.',
            ),
            _buildSection(
              '2. Utilisation des données',
              'Koumbaya utilise les données collectées à diverses fins :\n\n'
              '• Pour fournir et maintenir notre Service\n'
              '• Pour vous informer des changements apportés à notre Service\n'
              '• Pour vous permettre de participer aux fonctionnalités interactives de notre Service\n'
              '• Pour fournir un support client\n'
              '• Pour recueillir des analyses ou des informations précieuses afin d\'améliorer notre Service\n'
              '• Pour surveiller l\'utilisation de notre Service\n'
              '• Pour détecter, prévenir et résoudre les problèmes techniques\n'
              '• Pour traiter les transactions et gérer vos commandes\n'
              '• Pour vous envoyer des notifications concernant votre compte et vos activités\n'
              '• Pour personnaliser votre expérience utilisateur',
            ),
            _buildSection(
              '3. Conservation des données',
              'Koumbaya conservera vos données personnelles uniquement aussi longtemps que nécessaire aux fins énoncées dans cette politique de confidentialité. '
              'Nous conserverons et utiliserons vos données personnelles dans la mesure nécessaire pour nous conformer à nos obligations légales '
              '(par exemple, si nous sommes tenus de conserver vos données pour nous conformer aux lois applicables), '
              'résoudre les litiges et faire respecter nos accords et politiques juridiques.',
            ),
            _buildSection(
              '4. Transfert de données',
              'Vos informations, y compris les données personnelles, peuvent être transférées et conservées sur des ordinateurs '
              'situés en dehors de votre état, province, pays ou autre juridiction gouvernementale où les lois sur la protection '
              'des données peuvent différer de celles de votre juridiction. Si vous êtes situé en dehors du Cameroun et que vous '
              'choisissez de nous fournir des informations, veuillez noter que nous transférons les données, y compris les données '
              'personnelles, au Cameroun et les traitons là-bas. Votre consentement à cette politique de confidentialité suivi de '
              'votre soumission de ces informations représente votre accord à ce transfert.',
            ),
            _buildSection(
              '5. Divulgation des données',
              '',
            ),
            _buildSubSection(
              'Exigences légales',
              'Koumbaya peut divulguer vos données personnelles en toute bonne foi si une telle action est nécessaire pour :\n\n'
              '• Se conformer à une obligation légale\n'
              '• Protéger et défendre les droits ou la propriété de Koumbaya\n'
              '• Prévenir ou enquêter sur d\'éventuels actes répréhensibles en lien avec le Service\n'
              '• Protéger la sécurité personnelle des utilisateurs du Service ou du public\n'
              '• Se protéger contre la responsabilité légale',
            ),
            _buildSection(
              '6. Sécurité des données',
              'La sécurité de vos données est importante pour nous, mais n\'oubliez pas qu\'aucune méthode de transmission sur Internet '
              'ou méthode de stockage électronique n\'est sécurisée à 100%. Bien que nous nous efforcions d\'utiliser des moyens commercialement '
              'acceptables pour protéger vos données personnelles, nous ne pouvons garantir leur sécurité absolue. Nous utilisons :\n\n'
              '• Le cryptage SSL/TLS pour toutes les transmissions de données\n'
              '• Le stockage sécurisé des mots de passe avec hachage\n'
              '• L\'accès restreint aux données personnelles\n'
              '• Des audits de sécurité réguliers\n'
              '• La conformité aux normes de sécurité PCI DSS pour les paiements',
            ),
            _buildSection(
              '7. Droits de protection des données',
              'Vous avez certains droits concernant vos données personnelles :\n\n'
              '• Droit d\'accès : Vous avez le droit de demander l\'accès à vos données personnelles\n'
              '• Droit de rectification : Vous avez le droit de demander la correction de données inexactes\n'
              '• Droit à l\'effacement : Vous avez le droit de demander la suppression de vos données\n'
              '• Droit de limitation : Vous avez le droit de demander la limitation du traitement\n'
              '• Droit d\'opposition : Vous avez le droit de vous opposer au traitement de vos données\n'
              '• Droit à la portabilité : Vous avez le droit de recevoir vos données dans un format structuré\n\n'
              'Pour exercer ces droits, veuillez nous contacter à l\'adresse privacy@koumbaya.com',
            ),
            _buildSection(
              '8. Enfants',
              'Notre Service ne s\'adresse pas aux personnes de moins de 13 ans ("Enfants"). '
              'Nous ne collectons pas sciemment d\'informations personnellement identifiables auprès de personnes de moins de 13 ans. '
              'Si vous êtes un parent ou un tuteur et que vous savez que votre enfant nous a fourni des données personnelles, '
              'veuillez nous contacter. Si nous découvrons que nous avons collecté des données personnelles d\'enfants sans vérification '
              'du consentement parental, nous prenons des mesures pour supprimer ces informations de nos serveurs.',
            ),
            _buildSection(
              '9. Services tiers',
              'Notre Service peut contenir des liens vers des sites ou services tiers qui ne sont pas exploités par nous. '
              'Si vous cliquez sur un lien tiers, vous serez dirigé vers le site de ce tiers. Nous vous conseillons vivement '
              'de consulter la politique de confidentialité de chaque site que vous visitez.\n\n'
              'Nous utilisons les services tiers suivants :\n'
              '• Google Analytics pour l\'analyse\n'
              '• Firebase pour les notifications push et l\'analyse\n'
              '• Stripe/PayPal pour le traitement des paiements\n'
              '• Amazon S3 pour le stockage des images',
            ),
            _buildSection(
              '10. Modifications de cette politique de confidentialité',
              'Nous pouvons mettre à jour notre politique de confidentialité de temps à autre. Nous vous informerons de tout changement '
              'en publiant la nouvelle politique de confidentialité sur cette page. Nous vous informerons par e-mail et/ou par un avis '
              'bien visible sur notre Service, avant que le changement ne devienne effectif et mettrons à jour la date de "Dernière mise à jour" '
              'en haut de cette politique de confidentialité. Nous vous conseillons de consulter régulièrement cette politique de '
              'confidentialité pour tout changement. Les modifications apportées à cette politique de confidentialité sont effectives '
              'lorsqu\'elles sont publiées sur cette page.',
            ),
            _buildSection(
              '11. Nous contacter',
              'Si vous avez des questions concernant cette politique de confidentialité, veuillez nous contacter :\n\n'
              '• Par e-mail : privacy@koumbaya.com\n'
              '• Par téléphone : +237 XXX XXX XXX\n'
              '• Par courrier : Koumbaya, [Adresse complète], Cameroun\n'
              '• Via le formulaire de contact dans l\'application',
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