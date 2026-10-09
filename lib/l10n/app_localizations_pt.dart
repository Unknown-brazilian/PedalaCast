// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'PedalaCast';

  @override
  String get recordTitle => 'Gravar';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutAuthor => 'Autor';

  @override
  String get aboutSendFeedback => 'Enviar feedback';

  @override
  String get aboutSupportTitle => 'Apoie o projeto';

  @override
  String get aboutSupportText =>
      'O PedalaCast é gratuito. Se ele foi útil, você pode apoiar com Bitcoin pela rede Lightning.';

  @override
  String get aboutLightningNote =>
      'Este é um endereço Lightning (formato parecido com e-mail), não um endereço on-chain. Enviar on-chain não funciona.';

  @override
  String get aboutDonationDisclaimer =>
      'Doação voluntária. Não libera recursos nem dá vantagens.';

  @override
  String get aboutCopy => 'Copiar';

  @override
  String get aboutCopied => 'Endereço copiado';

  @override
  String get aboutOpenWallet => 'Abrir na carteira';

  @override
  String get aboutNoWallet =>
      'Nenhum aplicativo de carteira Lightning encontrado.';

  @override
  String get aboutLegal => 'Legal';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidade';

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String get aboutSafetyTitle => 'Aviso de segurança';

  @override
  String get aboutSafetyText =>
      'Não mexa no celular em movimento. Use um suporte firme e respeite o trânsito.';

  @override
  String get homeStart => 'Iniciar passeio';

  @override
  String get homeLibrary => 'Gravações';

  @override
  String get homeLayout => 'Layout do overlay';

  @override
  String get homeSettings => 'Ajustes';

  @override
  String get homeDebug => 'Debug do overlay';

  @override
  String get homeAbout => 'Sobre';

  @override
  String get permTitle => 'Permissões necessárias';

  @override
  String get permIntro =>
      'Para gravar o passeio com o overlay, o PedalaCast precisa de:';

  @override
  String get permCamera => 'Câmera: para filmar o passeio.';

  @override
  String get permMic => 'Microfone: para gravar o som do passeio.';

  @override
  String get permLocation =>
      'Localização precisa: para velocidade, distância, trajeto e altitude.';

  @override
  String get permNotif =>
      'Notificações: para mostrar que a gravação está ativa.';

  @override
  String get permGrant => 'Conceder permissões';

  @override
  String get permDenied =>
      'Algumas permissões foram negadas. Abra os ajustes do sistema para concedê-las.';

  @override
  String get permOpenSettings => 'Abrir ajustes';

  @override
  String get safetyTitle => 'Antes de pedalar';

  @override
  String get safetyBody =>
      'Não mexa no celular em movimento. Use um suporte firme na bike e respeite o trânsito. Para parar a gravação, segure o botão.';

  @override
  String get safetyAccept => 'Entendi';

  @override
  String get recGps => 'GPS';

  @override
  String get recGpsNone => 'Sem GPS';

  @override
  String recFree(String gb) {
    return 'Livre $gb GB';
  }

  @override
  String recTemp(String c) {
    return '$c °C';
  }

  @override
  String get recHoldToStop => 'Segure para parar';

  @override
  String get recStart => 'Iniciar';

  @override
  String get recPause => 'Pausar';

  @override
  String get recResume => 'Retomar';

  @override
  String get recSaved => 'Gravação salva';

  @override
  String get recNoBaro =>
      'Sem barômetro: inclinação e D+ ficam menos confiáveis.';

  @override
  String get recHot => 'Celular quente. Considere reduzir a qualidade.';

  @override
  String get recLowBattery => 'Bateria baixa.';

  @override
  String get recSimulation => 'Simulação';

  @override
  String get recStarting => 'Iniciando câmera…';

  @override
  String recError(String msg) {
    return 'Erro: $msg';
  }

  @override
  String get libEmpty => 'Nenhuma gravação ainda.';

  @override
  String get libOpen => 'Abrir';

  @override
  String get libShare => 'Compartilhar';

  @override
  String get libDelete => 'Excluir';

  @override
  String get libDeleteConfirm => 'Excluir esta gravação?';

  @override
  String get libCancel => 'Cancelar';

  @override
  String get libDeleteDo => 'Excluir';

  @override
  String get libNote =>
      'O vídeo fica em Movies/PedalaCast; o GPX e o JSON em Documents/PedalaCast.';

  @override
  String get layoutTitle => 'Layout do overlay';

  @override
  String get layoutSize => 'Tamanho';

  @override
  String get layoutSmall => 'Pequeno';

  @override
  String get layoutMedium => 'Médio';

  @override
  String get layoutLarge => 'Grande';

  @override
  String get layoutBlocks => 'Blocos';

  @override
  String get layoutPhone => 'Celular';

  @override
  String get layoutNoDevice => 'Sem dispositivo';

  @override
  String get layoutNoDeviceHint =>
      'Conecte um sensor Bluetooth para exibir este dado (disponível em breve).';

  @override
  String get layoutFullTrack => 'Mostrar trajeto completo no mini-mapa';

  @override
  String get blk_speed_gauge => 'Velocímetro';

  @override
  String get blk_distance_climb => 'Distância e D+';

  @override
  String get blk_minimap => 'Mini-mapa';

  @override
  String get blk_elevation_profile => 'Perfil de elevação';

  @override
  String get blk_grade_badge => 'Selo de inclinação';

  @override
  String get blk_hr => 'Batimentos';

  @override
  String get blk_cadence => 'Cadência';

  @override
  String get blk_power => 'Potência';

  @override
  String get blk_phone_status => 'Faixa de status do celular';

  @override
  String get blk_live_badge => 'Selo REC / AO VIVO';

  @override
  String get setTitle => 'Ajustes';

  @override
  String get setResolution => 'Resolução';

  @override
  String get set1080 => '1080p (30 fps)';

  @override
  String get set720 => '720p (30 fps)';

  @override
  String get setKeepScreen => 'Manter a tela ligada';

  @override
  String get setMic => 'Gravar microfone';

  @override
  String get setAutoPause => 'Pausa automática (parado)';

  @override
  String setPrivacy(int m) {
    return 'Zona de privacidade: $m m';
  }

  @override
  String get setPrivacyHint =>
      'O trajeto não aparece no mini-mapa dentro deste raio do ponto de partida.';

  @override
  String get setSimulation => 'Modo simulação';

  @override
  String get setSimulationHint =>
      'Reproduz um percurso de exemplo como se fosse GPS ao vivo, para testar o overlay sem pedalar.';

  @override
  String get dbgTitle => 'Debug do overlay';

  @override
  String get dbgBody =>
      'Renderiza o overlay sobre uma imagem estática com dados fixos e salva um PNG em Pictures/PedalaCast.';

  @override
  String get dbgRender => 'Gerar PNG';

  @override
  String dbgSaved(String uri) {
    return 'PNG salvo: $uri';
  }

  @override
  String get bgTitle => 'Evitar que o sistema encerre a gravação';

  @override
  String get bgBody =>
      'Em celulares como Xiaomi, Redmi e POCO (HyperOS/MIUI), o sistema pode fechar o app em segundo plano e perder o vídeo. Antes de pedalar: permita o início automático e deixe a bateria do PedalaCast como \"Sem restrições\".';

  @override
  String get bgAutostart => 'Início automático';

  @override
  String get bgBattery => 'Bateria';

  @override
  String get setOrientation => 'Orientação do vídeo';

  @override
  String get setLandscape => 'Horizontal';

  @override
  String get setPortrait => 'Vertical';

  @override
  String get recSettings => 'Ajustes';

  @override
  String get homeLive => 'Transmitir ao vivo (YouTube)';

  @override
  String get liveTitle => 'Live no YouTube';

  @override
  String get liveHelp =>
      'No YouTube Studio, crie uma transmissão ao vivo e copie a URL do servidor e a chave de transmissão. Cole abaixo.';

  @override
  String get liveUrl => 'URL do servidor (RTMPS)';

  @override
  String get liveKey => 'Chave de transmissão';

  @override
  String get liveKeyHint =>
      'A chave fica guardada criptografada neste aparelho e nunca é exibida nem registrada. Não a compartilhe.';

  @override
  String get liveBadUrl => 'Use uma URL que comece com rtmps://';

  @override
  String get liveNoKey => 'Cole a chave de transmissão do YouTube.';

  @override
  String get liveQuality => 'Qualidade';

  @override
  String get live720 => '720p (até 4 Mbps)';

  @override
  String get live1080 => '1080p (até 6 Mbps)';

  @override
  String get liveRecordLocal => 'Gravar uma cópia no celular';

  @override
  String get liveRecordLocalHint =>
      'Usa o mesmo vídeo da transmissão (com overlay) e continua se a rede cair.';

  @override
  String get liveHideMap => 'Ocultar mini-mapa';

  @override
  String get liveGo => 'Ir ao vivo';

  @override
  String get liveTip =>
      'Teste primeiro com a transmissão \"Não listada\" no YouTube Studio. O bitrate se ajusta sozinho à sua rede.';

  @override
  String get liveOnAir => 'AO VIVO';

  @override
  String get liveConnecting => 'Conectando…';

  @override
  String get liveReconnecting => 'Reconectando…';

  @override
  String liveBitrate(String mbps) {
    return '$mbps Mbps';
  }

  @override
  String liveDropped(int n) {
    return '$n quadros perdidos';
  }

  @override
  String get ovLiveLabel => 'AO VIVO';

  @override
  String get ovHrLabel => 'FC';

  @override
  String get ovRecLabel => 'REC';

  @override
  String get editOpen => 'Mover e redimensionar blocos';

  @override
  String get editTitle => 'Mover e redimensionar';

  @override
  String get editResetAll => 'Restaurar tudo';

  @override
  String get editResetBlock => 'Restaurar bloco';

  @override
  String editHelp(String orientation) {
    return 'Arraste os blocos para onde quiser. Toque em um bloco para mudar o tamanho. Posições salvas para a orientação $orientation.';
  }

  @override
  String editSize(int pct) {
    return '$pct%';
  }

  @override
  String get editTapHint =>
      'Toque em um bloco para escolher e ajustar o tamanho.';
}
