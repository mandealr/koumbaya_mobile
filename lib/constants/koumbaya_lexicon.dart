/// Glossaire Koumbaya
/// Ce lexique rassemble l'ensemble des termes propres à l'écosystème de la plateforme
/// Koumbaya, afin d'harmoniser la compréhension et l'utilisation par ses utilisateurs.

class KoumbayaLexicon {
  // ============================================================================
  // TERMES PRINCIPAUX
  // ============================================================================

  /// Plateforme réunissant les koumbistes et les koumbuyers dans un marché en ligne
  static const String platformName = 'Koumbaya';

  /// Désigne les clients et acheteurs qui utilisent la plateforme
  /// (prononcée : koum-bailleur – buyer : acheteur en anglais)
  static const String buyer = 'Koumbuyer';
  static const String buyers = 'Koumbuyers';

  /// Désigne les vendeurs et commerçants qui mettent en ligne leurs articles
  static const String seller = 'Koumbiste';
  static const String sellers = 'Koumbistes';

  /// Les revenus/fonds cumulés par un koumbiste grâce à la mise en vente
  static const String earnings = 'Koumbich';

  // ============================================================================
  // MODES DE TRANSACTION
  // ============================================================================

  /// Mode classique de transaction avec prix fixe
  static const String directPurchase = 'Achat Direct';
  static const String directPurchaseShort = 'Direct';

  /// Mode alternatif de transaction par tirage
  static const String specialDraw = 'Tirage Spécial';
  static const String specialDrawShort = 'Tirage';

  /// Unité de participation aux tirages spéciaux
  static const String ticket = 'Ticket';
  static const String tickets = 'Tickets';

  /// Les biens ou services mis en ligne sur la plateforme
  static const String article = 'Article';
  static const String articles = 'Articles';

  // ============================================================================
  // DESCRIPTIONS
  // ============================================================================

  /// Description complète d'un koumbuyer
  static const String buyerDescription =
      'Client qui utilise la plateforme pour acquérir des articles via achat direct ou tirages spéciaux';

  /// Description complète d'un koumbiste
  static const String sellerDescription =
      'Vendeur qui met en ligne ses articles pour générer des ventes et des revenus';

  /// Description d'un achat direct
  static const String directPurchaseDescription =
      'L\'article est listé avec un prix fixe affiché, et vous pouvez l\'acquérir immédiatement';

  /// Description d'un tirage spécial
  static const String specialDrawDescription =
      'Achetez un ou plusieurs tickets pour tenter de remporter l\'article au seul coût du ticket';

  /// Description d'un ticket
  static const String ticketDescription =
      'Chaque ticket donne droit à une chance unique de remporter l\'article mis en jeu';

  /// Description du Koumbich
  static const String earningsDescription =
      'Vos revenus cumulés grâce à vos ventes sur Koumbaya';

  // ============================================================================
  // MESSAGES & LABELS UI
  // ============================================================================

  // Navigation
  static const String navHome = 'Accueil';
  static const String navArticles = articles;
  static const String navDraws = 'Tirages';
  static const String navMyTickets = 'Mes Tickets';
  static const String navProfile = 'Profil';

  // Authentification
  static const String welcomeToKoumbaya = 'Bienvenue sur $platformName';
  static const String becomeKoumbuyer = 'Devenir $buyer';
  static const String becomeKoumbiste = 'Devenir $seller';
  static const String koumbuyerAccount = 'Compte $buyer';
  static const String koumbisteAccount = 'Compte $seller';

  // Profil
  static const String myKoumbich = 'Mon $earnings';
  static const String totalKoumbich = '$earnings Total';
  static const String availableKoumbich = '$earnings Disponible';

  // Articles
  static const String allArticles = 'Tous les $articles';
  static const String featuredArticles = '$articles à la Une';
  static const String latestArticles = 'Derniers $articles';
  static const String popularArticles = '$articles Populaires';
  static const String noArticlesFound = 'Aucun $article trouvé';
  static const String articleDetails = 'Détails de l\'$article';
  static const String searchArticles = 'Rechercher des $articles';

  // Achats
  static const String buyDirect = directPurchase;
  static const String buyDirectly = 'Acheter Directement';
  static const String directPrice = 'Prix $directPurchaseShort';

  // Tirages
  static const String participateInDraw = 'Participer au $specialDrawShort';
  static const String buyTickets = 'Acheter des $tickets';
  static const String myTickets = 'Mes $tickets';
  static const String ticketsRemaining = '$tickets Restants';
  static const String ticketPrice = 'Prix du $ticket';
  static const String numberOfTickets = 'Nombre de $tickets';
  static const String activeDraws = '$specialDrawShort en Cours';
  static const String pastDraws = '$specialDrawShort Terminés';

  // Vendeurs
  static const String soldBy = 'Vendu par';
  static const String koumbisteProfile = 'Profil du $seller';
  static const String becomeSeller = 'Devenir $seller';
  static const String becomeSellerTitle = 'Devenez $seller sur $platformName';
  static const String becomeSellerDescription =
      'Rejoignez notre communauté de $sellers et commencez à vendre vos $articles';

  // Transactions
  static const String purchaseHistory = 'Historique d\'Achats';
  static const String salesHistory = 'Historique de Ventes';
  static const String transactionType = 'Type de Transaction';

  // Messages de confirmation
  static const String purchaseSuccess = 'Achat réussi !';
  static const String ticketsPurchased = '$tickets achetés avec succès';
  static const String drawWon = 'Félicitations ! Vous avez remporté le $specialDrawShort';
  static const String drawLost = 'Dommage, vous n\'avez pas gagné cette fois';

  // Filtres
  static const String filterByType = 'Filtrer par Type';
  static const String showDirectOnly = '$directPurchase uniquement';
  static const String showDrawsOnly = '$specialDrawShort uniquement';
  static const String bothTypes = 'Les deux types';

  // Statistiques
  static const String totalBuyers = 'Total $buyers';
  static const String totalSellers = 'Total $sellers';
  static const String totalArticles = 'Total $articles';
  static const String activeDrawsCount = '$specialDrawShort Actifs';

  // Aide & Info
  static const String whatIsKoumbaya = 'Qu\'est-ce que $platformName ?';
  static const String whatIsKoumbuyer = 'Qu\'est-ce qu\'un $buyer ?';
  static const String whatIsKoumbiste = 'Qu\'est-ce qu\'un $seller ?';
  static const String whatIsKoumbich = 'Qu\'est-ce que le $earnings ?';
  static const String whatIsDirectPurchase = 'Qu\'est-ce qu\'un $directPurchase ?';
  static const String whatIsSpecialDraw = 'Qu\'est-ce qu\'un $specialDraw ?';
  static const String whatIsTicket = 'Qu\'est-ce qu\'un $ticket ?';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Retourne le terme approprié selon le type d'utilisateur
  static String getUserTypeLabel(bool isSeller) {
    return isSeller ? seller : buyer;
  }

  /// Retourne le terme de transaction selon le type
  static String getTransactionTypeLabel(bool isDraw) {
    return isDraw ? specialDraw : directPurchase;
  }

  /// Compte de tickets avec pluriel
  static String ticketCount(int count) {
    return count <= 1 ? '$count $ticket' : '$count $tickets';
  }

  /// Compte d'articles avec pluriel
  static String articleCount(int count) {
    return count <= 1 ? '$count $article' : '$count $articles';
  }
}
