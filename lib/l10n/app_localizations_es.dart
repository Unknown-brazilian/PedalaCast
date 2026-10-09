// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'PedalaCast';

  @override
  String get recordTitle => 'Grabar';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutAuthor => 'Autor';

  @override
  String get aboutSendFeedback => 'Enviar comentarios';

  @override
  String get aboutSupportTitle => 'Apoya el proyecto';

  @override
  String get aboutSupportText =>
      'PedalaCast es gratuito. Si te resultó útil, puedes apoyarlo con Bitcoin a través de la red Lightning.';

  @override
  String get aboutLightningNote =>
      'Esta es una dirección Lightning (formato similar a un correo), no una dirección on-chain. Enviar on-chain no funciona.';

  @override
  String get aboutDonationDisclaimer =>
      'Donación voluntaria. No desbloquea funciones ni da ventajas.';

  @override
  String get aboutCopy => 'Copiar';

  @override
  String get aboutCopied => 'Dirección copiada';

  @override
  String get aboutOpenWallet => 'Abrir en la billetera';

  @override
  String get aboutNoWallet => 'No se encontró ninguna billetera Lightning.';

  @override
  String get aboutLegal => 'Legal';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get aboutSafetyTitle => 'Aviso de seguridad';

  @override
  String get aboutSafetyText =>
      'No uses el teléfono en movimiento. Usa un soporte firme y respeta el tráfico.';

  @override
  String get homeStart => 'Iniciar paseo';

  @override
  String get homeLibrary => 'Grabaciones';

  @override
  String get homeLayout => 'Diseño del overlay';

  @override
  String get homeSettings => 'Ajustes';

  @override
  String get homeDebug => 'Depuración del overlay';

  @override
  String get homeAbout => 'Acerca de';

  @override
  String get permTitle => 'Permisos necesarios';

  @override
  String get permIntro =>
      'Para grabar tu paseo con el overlay, PedalaCast necesita:';

  @override
  String get permCamera => 'Cámara: para filmar el paseo.';

  @override
  String get permMic => 'Micrófono: para grabar el sonido del paseo.';

  @override
  String get permLocation =>
      'Ubicación precisa: para velocidad, distancia, recorrido y altitud.';

  @override
  String get permNotif =>
      'Notificaciones: para mostrar que la grabación está activa.';

  @override
  String get permGrant => 'Conceder permisos';

  @override
  String get permDenied =>
      'Se denegaron algunos permisos. Abre los ajustes del sistema para concederlos.';

  @override
  String get permOpenSettings => 'Abrir ajustes';

  @override
  String get safetyTitle => 'Antes de pedalear';

  @override
  String get safetyBody =>
      'No uses el teléfono en movimiento. Usa un soporte firme en la bici y respeta el tráfico. Para detener la grabación, mantén pulsado el botón.';

  @override
  String get safetyAccept => 'Entendido';

  @override
  String get recGps => 'GPS';

  @override
  String get recGpsNone => 'Sin GPS';

  @override
  String recFree(String gb) {
    return '$gb GB libres';
  }

  @override
  String recTemp(String c) {
    return '$c °C';
  }

  @override
  String get recHoldToStop => 'Mantén para detener';

  @override
  String get recStart => 'Iniciar';

  @override
  String get recPause => 'Pausar';

  @override
  String get recResume => 'Reanudar';

  @override
  String get recSaved => 'Grabación guardada';

  @override
  String get recNoBaro =>
      'Sin barómetro: la pendiente y el desnivel son menos fiables.';

  @override
  String get recHot =>
      'El teléfono está caliente. Considera reducir la calidad.';

  @override
  String get recLowBattery => 'Batería baja.';

  @override
  String get recSimulation => 'Simulación';

  @override
  String get recStarting => 'Iniciando cámara…';

  @override
  String recError(String msg) {
    return 'Error: $msg';
  }

  @override
  String get libEmpty => 'Aún no hay grabaciones.';

  @override
  String get libOpen => 'Abrir';

  @override
  String get libShare => 'Compartir';

  @override
  String get libDelete => 'Eliminar';

  @override
  String get libDeleteConfirm => '¿Eliminar esta grabación?';

  @override
  String get libCancel => 'Cancelar';

  @override
  String get libDeleteDo => 'Eliminar';

  @override
  String get libNote =>
      'Los vídeos están en Movies/PedalaCast; los archivos GPX y JSON en Documents/PedalaCast.';

  @override
  String get layoutTitle => 'Diseño del overlay';

  @override
  String get layoutSize => 'Tamaño';

  @override
  String get layoutSmall => 'Pequeño';

  @override
  String get layoutMedium => 'Mediano';

  @override
  String get layoutLarge => 'Grande';

  @override
  String get layoutBlocks => 'Bloques';

  @override
  String get layoutPhone => 'Teléfono';

  @override
  String get layoutNoDevice => 'Sin dispositivo';

  @override
  String get layoutNoDeviceHint =>
      'Conecta un sensor Bluetooth para mostrar este dato (próximamente).';

  @override
  String get layoutFullTrack => 'Mostrar el recorrido completo en el minimapa';

  @override
  String get blk_speed_gauge => 'Velocímetro';

  @override
  String get blk_distance_climb => 'Distancia y desnivel';

  @override
  String get blk_minimap => 'Minimapa';

  @override
  String get blk_elevation_profile => 'Perfil de elevación';

  @override
  String get blk_grade_badge => 'Indicador de pendiente';

  @override
  String get blk_hr => 'Pulsaciones';

  @override
  String get blk_cadence => 'Cadencia';

  @override
  String get blk_power => 'Potencia';

  @override
  String get blk_phone_status => 'Barra de estado del teléfono';

  @override
  String get blk_live_badge => 'Indicador REC / EN VIVO';

  @override
  String get setTitle => 'Ajustes';

  @override
  String get setResolution => 'Resolución';

  @override
  String get set1080 => '1080p (30 fps)';

  @override
  String get set720 => '720p (30 fps)';

  @override
  String get setKeepScreen => 'Mantener la pantalla encendida';

  @override
  String get setMic => 'Grabar micrófono';

  @override
  String get setAutoPause => 'Pausa automática (detenido)';

  @override
  String setPrivacy(int m) {
    return 'Zona de privacidad: $m m';
  }

  @override
  String get setPrivacyHint =>
      'El recorrido no aparece en el minimapa dentro de este radio del punto de partida.';

  @override
  String get setSimulation => 'Modo simulación';

  @override
  String get setSimulationHint =>
      'Reproduce un recorrido de ejemplo como si fuera GPS en vivo, para probar el overlay sin pedalear.';

  @override
  String get dbgTitle => 'Depuración del overlay';

  @override
  String get dbgBody =>
      'Dibuja el overlay sobre una imagen estática con datos fijos y guarda un PNG en Pictures/PedalaCast.';

  @override
  String get dbgRender => 'Generar PNG';

  @override
  String dbgSaved(String uri) {
    return 'PNG guardado: $uri';
  }

  @override
  String get bgTitle => 'Evitar que el sistema detenga la grabación';

  @override
  String get bgBody =>
      'En teléfonos como Xiaomi, Redmi y POCO (HyperOS/MIUI), el sistema puede cerrar la app en segundo plano y perder el vídeo. Antes de pedalear: permite el inicio automático y deja la batería de PedalaCast en \"Sin restricciones\".';

  @override
  String get bgAutostart => 'Inicio automático';

  @override
  String get bgBattery => 'Batería';

  @override
  String get setOrientation => 'Orientación del vídeo';

  @override
  String get setLandscape => 'Horizontal';

  @override
  String get setPortrait => 'Vertical';

  @override
  String get recSettings => 'Ajustes';

  @override
  String get homeLive => 'Transmitir en vivo (YouTube)';

  @override
  String get liveTitle => 'Directo en YouTube';

  @override
  String get liveHelp =>
      'En YouTube Studio, crea una transmisión en vivo y copia la URL del servidor y la clave de transmisión. Pégalas abajo.';

  @override
  String get liveUrl => 'URL del servidor (RTMPS)';

  @override
  String get liveKey => 'Clave de transmisión';

  @override
  String get liveKeyHint =>
      'La clave se guarda cifrada en este dispositivo y nunca se muestra ni se registra. No la compartas.';

  @override
  String get liveBadUrl => 'Usa una URL que empiece por rtmps://';

  @override
  String get liveNoKey => 'Pega la clave de transmisión de YouTube.';

  @override
  String get liveQuality => 'Calidad';

  @override
  String get live720 => '720p (hasta 4 Mbps)';

  @override
  String get live1080 => '1080p (hasta 6 Mbps)';

  @override
  String get liveRecordLocal => 'Guardar una copia en el teléfono';

  @override
  String get liveRecordLocalHint =>
      'Usa el mismo vídeo de la transmisión (con overlay) y continúa si la red se cae.';

  @override
  String get liveHideMap => 'Ocultar minimapa';

  @override
  String get liveGo => 'Salir en vivo';

  @override
  String get liveTip =>
      'Prueba primero con una transmisión \"No listada\" en YouTube Studio. El bitrate se ajusta solo a tu red.';

  @override
  String get liveOnAir => 'EN VIVO';

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
    return '$n fotogramas perdidos';
  }

  @override
  String get ovLiveLabel => 'EN VIVO';

  @override
  String get ovHrLabel => 'FC';

  @override
  String get ovRecLabel => 'REC';

  @override
  String get editOpen => 'Mover y cambiar tamaño de bloques';

  @override
  String get editTitle => 'Mover y cambiar tamaño';

  @override
  String get editResetAll => 'Restablecer todo';

  @override
  String get editResetBlock => 'Restablecer bloque';

  @override
  String editHelp(String orientation) {
    return 'Arrastra los bloques donde quieras. Toca un bloque para cambiar su tamaño. Posiciones guardadas para la orientación $orientation.';
  }

  @override
  String editSize(int pct) {
    return '$pct%';
  }

  @override
  String get editTapHint =>
      'Toca un bloque para seleccionarlo y ajustar su tamaño.';

  @override
  String get camSwitch => 'Cambiar cámara';

  @override
  String get camPickTitle => '¿Qué cámara usar?';

  @override
  String get camPickHint =>
      'Elige la cámara para grabar. Puedes cambiarla después con el botón de cámara de la pantalla de grabación.';

  @override
  String get camAuto => 'Automática (trasera principal)';

  @override
  String get camFront => 'Frontal';

  @override
  String get camRearMain => 'Trasera principal';

  @override
  String get camRearUltra => 'Trasera ultra gran angular';

  @override
  String get camRearTele => 'Trasera teleobjetivo';

  @override
  String camMp(int mp) {
    return '$mp MP';
  }

  @override
  String get blk_pip => 'Cámara frontal (PIP)';

  @override
  String get pipHint =>
      'Muestra la cámara frontal en una ventana sobre el vídeo. Arrástrala y cambia su tamaño en \"Mover y cambiar tamaño de bloques\".';

  @override
  String get pipUnsupported =>
      'Este teléfono no puede usar las cámaras frontal y trasera a la vez (o la cámara elegida es la frontal).';
}
