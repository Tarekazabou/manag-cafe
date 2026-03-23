// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Gestionnaire de café';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signIn => 'Se connecter';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get shopCode => 'Code de la boutique';

  @override
  String get shopCodeHelper =>
      'Entrez le code de la boutique pour rejoindre une boutique';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ? Inscrivez-vous';

  @override
  String get joinShop => 'Rejoindre la boutique';

  @override
  String get shopNotFound =>
      'Boutique non trouvée. Veuillez vous déconnecter et réessayer.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String signInError(Object error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String signUpError(Object error) {
    return 'Échec de l\'inscription : $error';
  }

  @override
  String joinShopError(Object error) {
    return 'Échec de l\'adhésion à la boutique : $error';
  }

  @override
  String get requestSentSuccess => 'Demande envoyée avec succès';

  @override
  String get signOutSuccess => 'Déconnexion réussie';

  @override
  String signOutError(Object error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get itemsScreenTitle => 'Articles d\'inventaire';

  @override
  String get editItem => 'Modifier l\'article';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get inventoryTitle => 'Enregistrer les quantités';

  @override
  String get lowStockAlert => 'Alertes de stock faible';

  @override
  String get searchItems => 'Rechercher des articles';

  @override
  String get sortByName => 'Trier par nom';

  @override
  String get sortByQuantity => 'Trier par quantité';

  @override
  String get sortByThreshold => 'Trier par seuil';

  @override
  String get noItems => 'Aucun article dans l\'inventaire.';

  @override
  String get saveConfirmationMessage =>
      'Voulez-vous enregistrer les quantités et mettre à jour les ventes ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get positiveQuantityError => 'Les quantités doivent être positives';

  @override
  String get noValidQuantitiesError => 'Aucune quantité valide à enregistrer';

  @override
  String get saveSuccessMessage =>
      'Quantités enregistrées et ventes mises à jour';

  @override
  String get undo => 'Annuler';

  @override
  String get undoSuccessMessage => 'Opération d\'enregistrement annulée';

  @override
  String get saveError => 'Erreur lors de l\'enregistrement';

  @override
  String get clearQuantitiesSuccess => 'Quantités sélectionnées effacées';

  @override
  String get prefillQuantitiesSuccess => 'Quantités pré-remplies';

  @override
  String get clearSelectedQuantitiesTooltip =>
      'Effacer les quantités sélectionnées';

  @override
  String get prefillQuantitiesTooltip => 'Pré-remplir les quantités';

  @override
  String get prefillQuantitiesTitle => 'Pré-remplir les quantités';

  @override
  String get quantity => 'Quantité';

  @override
  String get buyPrice => 'Prix d\'achat';

  @override
  String get sellPrice => 'Prix de vente';

  @override
  String get lowStockThreshold => 'Seuil de stock faible';

  @override
  String get isSellable => 'Est vendable';

  @override
  String get confirm => 'Confirmer';

  @override
  String get sortOrderTooltip => 'Changer l\'ordre de tri';

  @override
  String get date => 'Date';

  @override
  String get session => 'Session';

  @override
  String get weather => 'Météo';

  @override
  String get item => 'Article';

  @override
  String get quantityHint => 'Qté';

  @override
  String get invalidInput => 'Invalide';

  @override
  String get negativeQuantityError => 'Doit être >= 0';

  @override
  String get salesTitle => 'Ventes';

  @override
  String get adminTitle => 'Admin';

  @override
  String get deliveriesTitle => 'Livraisons';

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get dashboardTooltip => 'Voir le tableau de bord';

  @override
  String get inventoryTooltip => 'Gérer l\'inventaire';

  @override
  String get salesTooltip => 'Voir les ventes';

  @override
  String get adminTooltip => 'Accéder aux paramètres administrateur';

  @override
  String get deliveriesTooltip => 'Gérer les livraisons';

  @override
  String get statisticsTooltip => 'Voir les statistiques';

  @override
  String get errorLoadingRequests => 'Erreur lors du chargement des demandes';

  @override
  String get noRequestsFound => 'Aucune demande trouvée';

  @override
  String get requestDenied => 'Demande refusée';

  @override
  String get requestSentWaitingApproval =>
      'Demande envoyée, en attente de l\'approbation du propriétaire';

  @override
  String get unknownUser => 'Utilisateur inconnu';
}
