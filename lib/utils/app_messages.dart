/// ======================================================
/// AppMessages
///  Fichier centralisé pour tous les messages de l'application
/// ======================================================

class AppMessages {

  // --- Connexion / Réseau ---
  static const String noInternet =
      "Aucune connexion Internet. Veuillez vérifier votre réseau et réessayer.";
  static const String serverError =
      "La connexion au serveur a échoué. Vérifiez votre connexion Internet.";
  static const String networkError =
      "Erreur de réseau. Veuillez réessayer.";
  static const String loadError =
      "Impossible de charger les données. Réessayez plus tard.";


  // --- Authentification / Connexion ---
  static const String invalidCredentials =
      "Adresse e-mail ou mot de passe incorrect.";
  static const String userNotFound =
      "Ce compte n’existe pas. Veuillez vérifier vos informations.";
  static const String accountDisabled =
      "Ce compte est désactivé. Contactez l’administrateur.";
  static const String sessionExpired =
      "Votre session a expiré. Veuillez vous reconnecter.";
  static const String weakPassword =
      "Mot de passe trop court. Il doit contenir au moins 8 caractères.";
  static const String passwordMismatch =
      "Les mots de passe ne correspondent pas.";
  static const String invalidEmail =
      "L’adresse e-mail n’est pas valide.";


  // --- Fichiers / Documents ---
  static const String fileLoadError =
      "Impossible de charger le document.";
  static const String fileDownloadError =
      "Erreur lors du téléchargement du fichier.";
  static const String fileNotFound =
      "Fichier introuvable. Veuillez réessayer.";


  // --- Données / Base de données ---
  static const String noDataFound =
      "Aucun résultat trouvé.";
  static const String dataLoadError =
      "Erreur de chargement des données. Réessayez plus tard.";
  static const String saveError =
      "Impossible d’enregistrer les modifications.";
  static const String systemError =
      "Erreur interne du système.";


  // --- Succès ---
  static const String loginSuccess =
      "Connexion réussie ✅";
  static const String registerSuccess =
      "Enregistrement effectué avec succès";
  static const String passwordUpdateSuccess =
      "Mot de passe mis à jour avec succès 🔒";
  static const String profileUpdateSuccess =
      "Profil mis à jour avec succès ";
  static const String syncSuccess =
      "Données synchronisées avec succès ☁️";
  static const String pageMarked =
      "Page marquée comme dernière page lue ✅";
  static const String bookmarkRemoved =
      "Marque-page supprimé avec succès 🗑️";
  static const String downloadComplete =
      "Téléchargement terminé ✅";


  // --- Avertissements ---
  static const String deleteConfirmation =
      "Voulez-vous vraiment supprimer cet élément ?";
  static const String irreversibleAction =
      "Cette action est irréversible.";
  static const String missingInfo =
      "Certaines informations sont manquantes.";
  static const String fillAllFields =
      "Veuillez remplir tous les champs obligatoires.";
  static const String pleaseWait =
      "Veuillez patienter pendant le chargement...";
  static const String unsupportedFile =
      "Format de fichier non pris en charge.";


  // --- Informations ---
  static const String welcome =
      "Bienvenue dans l’application";
  static const String loading =
      "Chargement en cours...";
  static const String nothingToShow =
      "Aucun élément à afficher pour le moment.";
  static const String updateAvailable =
      "Nouvelle mise à jour disponible !";
  static const String offlineMode =
      "Mode hors ligne activé. Certaines fonctionnalités peuvent être limitées.";
  static const String progressSaved =
      "Votre progression a été sauvegardée.";
}
