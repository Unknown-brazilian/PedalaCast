import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'PedalaCast'**
  String get appName;

  /// No description provided for @recordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Gravar'**
  String get recordTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutAuthor.
  ///
  /// In pt, this message translates to:
  /// **'Autor'**
  String get aboutAuthor;

  /// No description provided for @aboutSendFeedback.
  ///
  /// In pt, this message translates to:
  /// **'Enviar feedback'**
  String get aboutSendFeedback;

  /// No description provided for @aboutSupportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apoie o projeto'**
  String get aboutSupportTitle;

  /// No description provided for @aboutSupportText.
  ///
  /// In pt, this message translates to:
  /// **'O PedalaCast é gratuito. Se ele foi útil, você pode apoiar com Bitcoin pela rede Lightning.'**
  String get aboutSupportText;

  /// No description provided for @aboutLightningNote.
  ///
  /// In pt, this message translates to:
  /// **'Este é um endereço Lightning (formato parecido com e-mail), não um endereço on-chain. Enviar on-chain não funciona.'**
  String get aboutLightningNote;

  /// No description provided for @aboutDonationDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Doação voluntária. Não libera recursos nem dá vantagens.'**
  String get aboutDonationDisclaimer;

  /// No description provided for @aboutCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get aboutCopy;

  /// No description provided for @aboutCopied.
  ///
  /// In pt, this message translates to:
  /// **'Endereço copiado'**
  String get aboutCopied;

  /// No description provided for @aboutOpenWallet.
  ///
  /// In pt, this message translates to:
  /// **'Abrir na carteira'**
  String get aboutOpenWallet;

  /// No description provided for @aboutNoWallet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum aplicativo de carteira Lightning encontrado.'**
  String get aboutNoWallet;

  /// No description provided for @aboutLegal.
  ///
  /// In pt, this message translates to:
  /// **'Legal'**
  String get aboutLegal;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutLicenses.
  ///
  /// In pt, this message translates to:
  /// **'Licenças de código aberto'**
  String get aboutLicenses;

  /// No description provided for @aboutSafetyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aviso de segurança'**
  String get aboutSafetyTitle;

  /// No description provided for @aboutSafetyText.
  ///
  /// In pt, this message translates to:
  /// **'Não mexa no celular em movimento. Use um suporte firme e respeite o trânsito.'**
  String get aboutSafetyText;

  /// No description provided for @homeStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar passeio'**
  String get homeStart;

  /// No description provided for @homeLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Gravações'**
  String get homeLibrary;

  /// No description provided for @homeLayout.
  ///
  /// In pt, this message translates to:
  /// **'Layout do overlay'**
  String get homeLayout;

  /// No description provided for @homeSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get homeSettings;

  /// No description provided for @homeDebug.
  ///
  /// In pt, this message translates to:
  /// **'Debug do overlay'**
  String get homeDebug;

  /// No description provided for @homeAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get homeAbout;

  /// No description provided for @permTitle.
  ///
  /// In pt, this message translates to:
  /// **'Permissões necessárias'**
  String get permTitle;

  /// No description provided for @permIntro.
  ///
  /// In pt, this message translates to:
  /// **'Para gravar o passeio com o overlay, o PedalaCast precisa de:'**
  String get permIntro;

  /// No description provided for @permCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera: para filmar o passeio.'**
  String get permCamera;

  /// No description provided for @permMic.
  ///
  /// In pt, this message translates to:
  /// **'Microfone: para gravar o som do passeio.'**
  String get permMic;

  /// No description provided for @permLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização precisa: para velocidade, distância, trajeto e altitude.'**
  String get permLocation;

  /// No description provided for @permNotif.
  ///
  /// In pt, this message translates to:
  /// **'Notificações: para mostrar que a gravação está ativa.'**
  String get permNotif;

  /// No description provided for @permGrant.
  ///
  /// In pt, this message translates to:
  /// **'Conceder permissões'**
  String get permGrant;

  /// No description provided for @permDenied.
  ///
  /// In pt, this message translates to:
  /// **'Algumas permissões foram negadas. Abra os ajustes do sistema para concedê-las.'**
  String get permDenied;

  /// No description provided for @permOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir ajustes'**
  String get permOpenSettings;

  /// No description provided for @safetyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Antes de pedalar'**
  String get safetyTitle;

  /// No description provided for @safetyBody.
  ///
  /// In pt, this message translates to:
  /// **'Não mexa no celular em movimento. Use um suporte firme na bike e respeite o trânsito. Para parar a gravação, segure o botão.'**
  String get safetyBody;

  /// No description provided for @safetyAccept.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get safetyAccept;

  /// No description provided for @recGps.
  ///
  /// In pt, this message translates to:
  /// **'GPS'**
  String get recGps;

  /// No description provided for @recGpsNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem GPS'**
  String get recGpsNone;

  /// No description provided for @recFree.
  ///
  /// In pt, this message translates to:
  /// **'Livre {gb} GB'**
  String recFree(String gb);

  /// No description provided for @recTemp.
  ///
  /// In pt, this message translates to:
  /// **'{c} °C'**
  String recTemp(String c);

  /// No description provided for @recHoldToStop.
  ///
  /// In pt, this message translates to:
  /// **'Segure para parar'**
  String get recHoldToStop;

  /// No description provided for @recStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar'**
  String get recStart;

  /// No description provided for @recPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get recPause;

  /// No description provided for @recResume.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get recResume;

  /// No description provided for @recSaved.
  ///
  /// In pt, this message translates to:
  /// **'Gravação salva'**
  String get recSaved;

  /// No description provided for @recNoBaro.
  ///
  /// In pt, this message translates to:
  /// **'Sem barômetro: inclinação e D+ ficam menos confiáveis.'**
  String get recNoBaro;

  /// No description provided for @recHot.
  ///
  /// In pt, this message translates to:
  /// **'Celular quente. Considere reduzir a qualidade.'**
  String get recHot;

  /// No description provided for @recLowBattery.
  ///
  /// In pt, this message translates to:
  /// **'Bateria baixa.'**
  String get recLowBattery;

  /// No description provided for @recSimulation.
  ///
  /// In pt, this message translates to:
  /// **'Simulação'**
  String get recSimulation;

  /// No description provided for @recStarting.
  ///
  /// In pt, this message translates to:
  /// **'Iniciando câmera…'**
  String get recStarting;

  /// No description provided for @recError.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {msg}'**
  String recError(String msg);

  /// No description provided for @libEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma gravação ainda.'**
  String get libEmpty;

  /// No description provided for @libOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir'**
  String get libOpen;

  /// No description provided for @libShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get libShare;

  /// No description provided for @libDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get libDelete;

  /// No description provided for @libDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir esta gravação?'**
  String get libDeleteConfirm;

  /// No description provided for @libCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get libCancel;

  /// No description provided for @libDeleteDo.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get libDeleteDo;

  /// No description provided for @libNote.
  ///
  /// In pt, this message translates to:
  /// **'O vídeo fica em Movies/PedalaCast; o GPX e o JSON em Documents/PedalaCast.'**
  String get libNote;

  /// No description provided for @layoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Layout do overlay'**
  String get layoutTitle;

  /// No description provided for @layoutSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho'**
  String get layoutSize;

  /// No description provided for @layoutSmall.
  ///
  /// In pt, this message translates to:
  /// **'Pequeno'**
  String get layoutSmall;

  /// No description provided for @layoutMedium.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get layoutMedium;

  /// No description provided for @layoutLarge.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get layoutLarge;

  /// No description provided for @layoutBlocks.
  ///
  /// In pt, this message translates to:
  /// **'Blocos'**
  String get layoutBlocks;

  /// No description provided for @layoutPhone.
  ///
  /// In pt, this message translates to:
  /// **'Celular'**
  String get layoutPhone;

  /// No description provided for @layoutNoDevice.
  ///
  /// In pt, this message translates to:
  /// **'Sem dispositivo'**
  String get layoutNoDevice;

  /// No description provided for @layoutNoDeviceHint.
  ///
  /// In pt, this message translates to:
  /// **'Conecte um sensor Bluetooth para exibir este dado (disponível em breve).'**
  String get layoutNoDeviceHint;

  /// No description provided for @layoutFullTrack.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar trajeto completo no mini-mapa'**
  String get layoutFullTrack;

  /// No description provided for @blk_speed_gauge.
  ///
  /// In pt, this message translates to:
  /// **'Velocímetro'**
  String get blk_speed_gauge;

  /// No description provided for @blk_distance_climb.
  ///
  /// In pt, this message translates to:
  /// **'Distância e D+'**
  String get blk_distance_climb;

  /// No description provided for @blk_minimap.
  ///
  /// In pt, this message translates to:
  /// **'Mini-mapa'**
  String get blk_minimap;

  /// No description provided for @blk_elevation_profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de elevação'**
  String get blk_elevation_profile;

  /// No description provided for @blk_grade_badge.
  ///
  /// In pt, this message translates to:
  /// **'Selo de inclinação'**
  String get blk_grade_badge;

  /// No description provided for @blk_hr.
  ///
  /// In pt, this message translates to:
  /// **'Batimentos'**
  String get blk_hr;

  /// No description provided for @blk_cadence.
  ///
  /// In pt, this message translates to:
  /// **'Cadência'**
  String get blk_cadence;

  /// No description provided for @blk_power.
  ///
  /// In pt, this message translates to:
  /// **'Potência'**
  String get blk_power;

  /// No description provided for @blk_phone_status.
  ///
  /// In pt, this message translates to:
  /// **'Faixa de status do celular'**
  String get blk_phone_status;

  /// No description provided for @blk_live_badge.
  ///
  /// In pt, this message translates to:
  /// **'Selo REC / AO VIVO'**
  String get blk_live_badge;

  /// No description provided for @setTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get setTitle;

  /// No description provided for @setResolution.
  ///
  /// In pt, this message translates to:
  /// **'Resolução'**
  String get setResolution;

  /// No description provided for @set1080.
  ///
  /// In pt, this message translates to:
  /// **'1080p (30 fps)'**
  String get set1080;

  /// No description provided for @set720.
  ///
  /// In pt, this message translates to:
  /// **'720p (30 fps)'**
  String get set720;

  /// No description provided for @setKeepScreen.
  ///
  /// In pt, this message translates to:
  /// **'Manter a tela ligada'**
  String get setKeepScreen;

  /// No description provided for @setMic.
  ///
  /// In pt, this message translates to:
  /// **'Gravar microfone'**
  String get setMic;

  /// No description provided for @setAutoPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausa automática (parado)'**
  String get setAutoPause;

  /// No description provided for @setPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Zona de privacidade: {m} m'**
  String setPrivacy(int m);

  /// No description provided for @setPrivacyHint.
  ///
  /// In pt, this message translates to:
  /// **'O trajeto não aparece no mini-mapa dentro deste raio do ponto de partida.'**
  String get setPrivacyHint;

  /// No description provided for @setSimulation.
  ///
  /// In pt, this message translates to:
  /// **'Modo simulação'**
  String get setSimulation;

  /// No description provided for @setSimulationHint.
  ///
  /// In pt, this message translates to:
  /// **'Reproduz um percurso de exemplo como se fosse GPS ao vivo, para testar o overlay sem pedalar.'**
  String get setSimulationHint;

  /// No description provided for @dbgTitle.
  ///
  /// In pt, this message translates to:
  /// **'Debug do overlay'**
  String get dbgTitle;

  /// No description provided for @dbgBody.
  ///
  /// In pt, this message translates to:
  /// **'Renderiza o overlay sobre uma imagem estática com dados fixos e salva um PNG em Pictures/PedalaCast.'**
  String get dbgBody;

  /// No description provided for @dbgRender.
  ///
  /// In pt, this message translates to:
  /// **'Gerar PNG'**
  String get dbgRender;

  /// No description provided for @dbgSaved.
  ///
  /// In pt, this message translates to:
  /// **'PNG salvo: {uri}'**
  String dbgSaved(String uri);

  /// No description provided for @bgTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evitar que o sistema encerre a gravação'**
  String get bgTitle;

  /// No description provided for @bgBody.
  ///
  /// In pt, this message translates to:
  /// **'Em celulares como Xiaomi, Redmi e POCO (HyperOS/MIUI), o sistema pode fechar o app em segundo plano e perder o vídeo. Antes de pedalar: permita o início automático e deixe a bateria do PedalaCast como \"Sem restrições\".'**
  String get bgBody;

  /// No description provided for @bgAutostart.
  ///
  /// In pt, this message translates to:
  /// **'Início automático'**
  String get bgAutostart;

  /// No description provided for @bgBattery.
  ///
  /// In pt, this message translates to:
  /// **'Bateria'**
  String get bgBattery;

  /// No description provided for @setOrientation.
  ///
  /// In pt, this message translates to:
  /// **'Orientação do vídeo'**
  String get setOrientation;

  /// No description provided for @setLandscape.
  ///
  /// In pt, this message translates to:
  /// **'Horizontal'**
  String get setLandscape;

  /// No description provided for @setPortrait.
  ///
  /// In pt, this message translates to:
  /// **'Vertical'**
  String get setPortrait;

  /// No description provided for @recSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get recSettings;

  /// No description provided for @homeLive.
  ///
  /// In pt, this message translates to:
  /// **'Transmitir ao vivo (YouTube)'**
  String get homeLive;

  /// No description provided for @liveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Live no YouTube'**
  String get liveTitle;

  /// No description provided for @liveHelp.
  ///
  /// In pt, this message translates to:
  /// **'No YouTube Studio, crie uma transmissão ao vivo e copie a URL do servidor e a chave de transmissão. Cole abaixo.'**
  String get liveHelp;

  /// No description provided for @liveUrl.
  ///
  /// In pt, this message translates to:
  /// **'URL do servidor (RTMPS)'**
  String get liveUrl;

  /// No description provided for @liveKey.
  ///
  /// In pt, this message translates to:
  /// **'Chave de transmissão'**
  String get liveKey;

  /// No description provided for @liveKeyHint.
  ///
  /// In pt, this message translates to:
  /// **'A chave fica guardada criptografada neste aparelho e nunca é exibida nem registrada. Não a compartilhe.'**
  String get liveKeyHint;

  /// No description provided for @liveBadUrl.
  ///
  /// In pt, this message translates to:
  /// **'Use uma URL que comece com rtmps://'**
  String get liveBadUrl;

  /// No description provided for @liveNoKey.
  ///
  /// In pt, this message translates to:
  /// **'Cole a chave de transmissão do YouTube.'**
  String get liveNoKey;

  /// No description provided for @liveQuality.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade'**
  String get liveQuality;

  /// No description provided for @live720.
  ///
  /// In pt, this message translates to:
  /// **'720p (até 4 Mbps)'**
  String get live720;

  /// No description provided for @live1080.
  ///
  /// In pt, this message translates to:
  /// **'1080p (até 6 Mbps)'**
  String get live1080;

  /// No description provided for @liveRecordLocal.
  ///
  /// In pt, this message translates to:
  /// **'Gravar uma cópia no celular'**
  String get liveRecordLocal;

  /// No description provided for @liveRecordLocalHint.
  ///
  /// In pt, this message translates to:
  /// **'Usa o mesmo vídeo da transmissão (com overlay) e continua se a rede cair.'**
  String get liveRecordLocalHint;

  /// No description provided for @liveHideMap.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar mini-mapa'**
  String get liveHideMap;

  /// No description provided for @liveGo.
  ///
  /// In pt, this message translates to:
  /// **'Ir ao vivo'**
  String get liveGo;

  /// No description provided for @liveTip.
  ///
  /// In pt, this message translates to:
  /// **'Teste primeiro com a transmissão \"Não listada\" no YouTube Studio. O bitrate se ajusta sozinho à sua rede.'**
  String get liveTip;

  /// No description provided for @liveOnAir.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get liveOnAir;

  /// No description provided for @liveConnecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando…'**
  String get liveConnecting;

  /// No description provided for @liveReconnecting.
  ///
  /// In pt, this message translates to:
  /// **'Reconectando…'**
  String get liveReconnecting;

  /// No description provided for @liveBitrate.
  ///
  /// In pt, this message translates to:
  /// **'{mbps} Mbps'**
  String liveBitrate(String mbps);

  /// No description provided for @liveDropped.
  ///
  /// In pt, this message translates to:
  /// **'{n} quadros perdidos'**
  String liveDropped(int n);

  /// No description provided for @ovLiveLabel.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get ovLiveLabel;

  /// No description provided for @ovHrLabel.
  ///
  /// In pt, this message translates to:
  /// **'FC'**
  String get ovHrLabel;

  /// No description provided for @ovRecLabel.
  ///
  /// In pt, this message translates to:
  /// **'REC'**
  String get ovRecLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
