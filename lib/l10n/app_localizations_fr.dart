// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'PedalaCast';

  @override
  String get recordTitle => 'Enregistrer';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutAuthor => 'Auteur';

  @override
  String get aboutSendFeedback => 'Envoyer un retour';

  @override
  String get aboutSupportTitle => 'Soutenir le projet';

  @override
  String get aboutSupportText =>
      'PedalaCast est gratuit. S\'il vous a été utile, vous pouvez le soutenir avec du Bitcoin via le réseau Lightning.';

  @override
  String get aboutLightningNote =>
      'Il s\'agit d\'une adresse Lightning (format proche d\'un e-mail), pas d\'une adresse on-chain. Un envoi on-chain ne fonctionne pas.';

  @override
  String get aboutDonationDisclaimer =>
      'Don volontaire. Il ne débloque aucune fonction et n\'apporte aucun avantage.';

  @override
  String get aboutCopy => 'Copier';

  @override
  String get aboutCopied => 'Adresse copiée';

  @override
  String get aboutOpenWallet => 'Ouvrir dans le portefeuille';

  @override
  String get aboutNoWallet =>
      'Aucune application de portefeuille Lightning trouvée.';

  @override
  String get aboutLegal => 'Mentions légales';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutSafetyTitle => 'Avertissement de sécurité';

  @override
  String get aboutSafetyText =>
      'Ne manipulez pas votre téléphone en roulant. Utilisez un support solide et respectez la circulation.';

  @override
  String get homeStart => 'Démarrer la sortie';

  @override
  String get homeLibrary => 'Enregistrements';

  @override
  String get homeLayout => 'Disposition de l\'overlay';

  @override
  String get homeSettings => 'Réglages';

  @override
  String get homeDebug => 'Débogage de l\'overlay';

  @override
  String get homeAbout => 'À propos';

  @override
  String get permTitle => 'Autorisations nécessaires';

  @override
  String get permIntro =>
      'Pour enregistrer votre sortie avec l\'overlay, PedalaCast a besoin de :';

  @override
  String get permCamera => 'Caméra : pour filmer la sortie.';

  @override
  String get permMic => 'Microphone : pour enregistrer le son.';

  @override
  String get permLocation =>
      'Position précise : pour la vitesse, la distance, le tracé et l\'altitude.';

  @override
  String get permNotif =>
      'Notifications : pour indiquer que l\'enregistrement est actif.';

  @override
  String get permGrant => 'Accorder les autorisations';

  @override
  String get permDenied =>
      'Certaines autorisations ont été refusées. Ouvrez les réglages du système pour les accorder.';

  @override
  String get permOpenSettings => 'Ouvrir les réglages';

  @override
  String get safetyTitle => 'Avant de rouler';

  @override
  String get safetyBody =>
      'Ne manipulez pas votre téléphone en roulant. Utilisez un support solide sur le vélo et respectez la circulation. Pour arrêter l\'enregistrement, maintenez le bouton.';

  @override
  String get safetyAccept => 'Compris';

  @override
  String get recGps => 'GPS';

  @override
  String get recGpsNone => 'Pas de GPS';

  @override
  String recFree(String gb) {
    return '$gb Go libres';
  }

  @override
  String recTemp(String c) {
    return '$c °C';
  }

  @override
  String get recHoldToStop => 'Maintenir pour arrêter';

  @override
  String get recStart => 'Démarrer';

  @override
  String get recPause => 'Pause';

  @override
  String get recResume => 'Reprendre';

  @override
  String get recSaved => 'Enregistrement sauvegardé';

  @override
  String get recNoBaro =>
      'Pas de baromètre : la pente et le dénivelé sont moins fiables.';

  @override
  String get recHot => 'Le téléphone chauffe. Pensez à réduire la qualité.';

  @override
  String get recLowBattery => 'Batterie faible.';

  @override
  String get recSimulation => 'Simulation';

  @override
  String get recStarting => 'Démarrage de la caméra…';

  @override
  String recError(String msg) {
    return 'Erreur : $msg';
  }

  @override
  String get libEmpty => 'Aucun enregistrement pour l\'instant.';

  @override
  String get libOpen => 'Ouvrir';

  @override
  String get libShare => 'Partager';

  @override
  String get libDelete => 'Supprimer';

  @override
  String get libDeleteConfirm => 'Supprimer cet enregistrement ?';

  @override
  String get libCancel => 'Annuler';

  @override
  String get libDeleteDo => 'Supprimer';

  @override
  String get libNote =>
      'Les vidéos sont dans Movies/PedalaCast ; les fichiers GPX et JSON dans Documents/PedalaCast.';

  @override
  String get layoutTitle => 'Disposition de l\'overlay';

  @override
  String get layoutSize => 'Taille';

  @override
  String get layoutSmall => 'Petit';

  @override
  String get layoutMedium => 'Moyen';

  @override
  String get layoutLarge => 'Grand';

  @override
  String get layoutBlocks => 'Blocs';

  @override
  String get layoutPhone => 'Téléphone';

  @override
  String get layoutNoDevice => 'Aucun appareil';

  @override
  String get layoutNoDeviceHint =>
      'Connectez un capteur Bluetooth pour afficher cette donnée (bientôt disponible).';

  @override
  String get layoutFullTrack => 'Afficher le tracé complet sur la mini-carte';

  @override
  String get blk_speed_gauge => 'Compteur de vitesse';

  @override
  String get blk_distance_climb => 'Distance et dénivelé';

  @override
  String get blk_minimap => 'Mini-carte';

  @override
  String get blk_elevation_profile => 'Profil d\'altitude';

  @override
  String get blk_grade_badge => 'Pastille de pente';

  @override
  String get blk_hr => 'Fréquence cardiaque';

  @override
  String get blk_cadence => 'Cadence';

  @override
  String get blk_power => 'Puissance';

  @override
  String get blk_phone_status => 'Barre d\'état du téléphone';

  @override
  String get blk_live_badge => 'Pastille REC / EN DIRECT';

  @override
  String get setTitle => 'Réglages';

  @override
  String get setResolution => 'Résolution';

  @override
  String get set1080 => '1080p (30 i/s)';

  @override
  String get set720 => '720p (30 i/s)';

  @override
  String get setKeepScreen => 'Garder l\'écran allumé';

  @override
  String get setMic => 'Enregistrer le microphone';

  @override
  String get setAutoPause => 'Pause automatique (à l\'arrêt)';

  @override
  String setPrivacy(int m) {
    return 'Zone de confidentialité : $m m';
  }

  @override
  String get setPrivacyHint =>
      'Le tracé n\'apparaît pas sur la mini-carte dans ce rayon autour du point de départ.';

  @override
  String get setSimulation => 'Mode simulation';

  @override
  String get setSimulationHint =>
      'Rejoue un parcours d\'exemple comme un GPS en direct, pour tester l\'overlay sans rouler.';

  @override
  String get dbgTitle => 'Débogage de l\'overlay';

  @override
  String get dbgBody =>
      'Dessine l\'overlay sur une image statique avec des données fixes et enregistre un PNG dans Pictures/PedalaCast.';

  @override
  String get dbgRender => 'Générer un PNG';

  @override
  String dbgSaved(String uri) {
    return 'PNG enregistré : $uri';
  }

  @override
  String get bgTitle => 'Empêcher le système d\'arrêter l\'enregistrement';

  @override
  String get bgBody =>
      'Sur les téléphones comme Xiaomi, Redmi et POCO (HyperOS/MIUI), le système peut fermer l\'application en arrière-plan et perdre la vidéo. Avant de rouler : autorisez le démarrage automatique et réglez la batterie de PedalaCast sur « Sans restriction ».';

  @override
  String get bgAutostart => 'Démarrage automatique';

  @override
  String get bgBattery => 'Batterie';

  @override
  String get setOrientation => 'Orientation de la vidéo';

  @override
  String get setLandscape => 'Paysage';

  @override
  String get setPortrait => 'Portrait';

  @override
  String get recSettings => 'Réglages';

  @override
  String get homeLive => 'Diffuser en direct (YouTube)';

  @override
  String get liveTitle => 'Direct YouTube';

  @override
  String get liveHelp =>
      'Dans YouTube Studio, créez une diffusion en direct et copiez l\'URL du serveur et la clé de diffusion. Collez-les ci-dessous.';

  @override
  String get liveUrl => 'URL du serveur (RTMPS)';

  @override
  String get liveKey => 'Clé de diffusion';

  @override
  String get liveKeyHint =>
      'La clé est stockée chiffrée sur cet appareil et n\'est jamais affichée ni journalisée. Ne la partagez pas.';

  @override
  String get liveBadUrl => 'Utilisez une URL commençant par rtmps://';

  @override
  String get liveNoKey => 'Collez la clé de diffusion YouTube.';

  @override
  String get liveQuality => 'Qualité';

  @override
  String get live720 => '720p (jusqu\'à 4 Mbit/s)';

  @override
  String get live1080 => '1080p (jusqu\'à 6 Mbit/s)';

  @override
  String get liveRecordLocal => 'Enregistrer une copie sur le téléphone';

  @override
  String get liveRecordLocalHint =>
      'Utilise la même vidéo que la diffusion (avec overlay) et continue si le réseau coupe.';

  @override
  String get liveHideMap => 'Masquer la mini-carte';

  @override
  String get liveGo => 'Passer en direct';

  @override
  String get liveTip =>
      'Testez d\'abord avec une diffusion « Non répertoriée » dans YouTube Studio. Le débit s\'adapte seul à votre réseau.';

  @override
  String get liveOnAir => 'EN DIRECT';

  @override
  String get liveConnecting => 'Connexion…';

  @override
  String get liveReconnecting => 'Reconnexion…';

  @override
  String liveBitrate(String mbps) {
    return '$mbps Mbit/s';
  }

  @override
  String liveDropped(int n) {
    return '$n images perdues';
  }

  @override
  String get ovLiveLabel => 'EN DIRECT';

  @override
  String get ovHrLabel => 'FC';

  @override
  String get ovRecLabel => 'REC';

  @override
  String get editOpen => 'Déplacer et redimensionner les blocs';

  @override
  String get editTitle => 'Déplacer et redimensionner';

  @override
  String get editResetAll => 'Tout réinitialiser';

  @override
  String get editResetBlock => 'Réinitialiser le bloc';

  @override
  String editHelp(String orientation) {
    return 'Faites glisser les blocs où vous voulez. Touchez un bloc pour changer sa taille. Positions enregistrées pour l\'orientation $orientation.';
  }

  @override
  String editSize(int pct) {
    return '$pct%';
  }

  @override
  String get editTapHint =>
      'Touchez un bloc pour le sélectionner et ajuster sa taille.';

  @override
  String get camSwitch => 'Changer de caméra';

  @override
  String get camPickTitle => 'Quelle caméra utiliser ?';

  @override
  String get camPickHint =>
      'Choisissez la caméra pour enregistrer. Vous pourrez la changer avec le bouton caméra de l\'écran d\'enregistrement.';

  @override
  String get camAuto => 'Automatique (arrière principale)';

  @override
  String get camFront => 'Frontale';

  @override
  String get camRearMain => 'Arrière principale';

  @override
  String get camRearUltra => 'Arrière ultra grand-angle';

  @override
  String get camRearTele => 'Arrière téléobjectif';

  @override
  String camMp(int mp) {
    return '$mp Mpx';
  }
}
