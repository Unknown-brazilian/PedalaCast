// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PedalaCast';

  @override
  String get recordTitle => 'Record';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutAuthor => 'Author';

  @override
  String get aboutSendFeedback => 'Send feedback';

  @override
  String get aboutSupportTitle => 'Support the project';

  @override
  String get aboutSupportText =>
      'PedalaCast is free. If it was useful to you, you can support it with Bitcoin over the Lightning network.';

  @override
  String get aboutLightningNote =>
      'This is a Lightning address (email-like format), not an on-chain address. Sending on-chain will not work.';

  @override
  String get aboutDonationDisclaimer =>
      'Voluntary donation. It does not unlock features or give any advantage.';

  @override
  String get aboutCopy => 'Copy';

  @override
  String get aboutCopied => 'Address copied';

  @override
  String get aboutOpenWallet => 'Open in wallet';

  @override
  String get aboutNoWallet => 'No Lightning wallet app found.';

  @override
  String get aboutLegal => 'Legal';

  @override
  String get aboutPrivacyPolicy => 'Privacy policy';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutSafetyTitle => 'Safety notice';

  @override
  String get aboutSafetyText =>
      'Do not handle your phone while moving. Use a firm mount and respect traffic.';

  @override
  String get homeStart => 'Start ride';

  @override
  String get homeLibrary => 'Recordings';

  @override
  String get homeLayout => 'Overlay layout';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeDebug => 'Overlay debug';

  @override
  String get homeAbout => 'About';

  @override
  String get permTitle => 'Permissions needed';

  @override
  String get permIntro =>
      'To record your ride with the overlay, PedalaCast needs:';

  @override
  String get permCamera => 'Camera: to film your ride.';

  @override
  String get permMic => 'Microphone: to record the ride sound.';

  @override
  String get permLocation =>
      'Precise location: for speed, distance, route and altitude.';

  @override
  String get permNotif => 'Notifications: to show that recording is active.';

  @override
  String get permGrant => 'Grant permissions';

  @override
  String get permDenied =>
      'Some permissions were denied. Open system settings to grant them.';

  @override
  String get permOpenSettings => 'Open settings';

  @override
  String get safetyTitle => 'Before you ride';

  @override
  String get safetyBody =>
      'Do not handle your phone while moving. Use a firm bike mount and respect traffic. To stop recording, hold the button.';

  @override
  String get safetyAccept => 'Got it';

  @override
  String get recGps => 'GPS';

  @override
  String get recGpsNone => 'No GPS';

  @override
  String recFree(String gb) {
    return '$gb GB free';
  }

  @override
  String recTemp(String c) {
    return '$c °C';
  }

  @override
  String get recHoldToStop => 'Hold to stop';

  @override
  String get recStart => 'Start';

  @override
  String get recPause => 'Pause';

  @override
  String get recResume => 'Resume';

  @override
  String get recSaved => 'Recording saved';

  @override
  String get recNoBaro => 'No barometer: grade and climb are less reliable.';

  @override
  String get recHot => 'Phone is hot. Consider lowering the quality.';

  @override
  String get recLowBattery => 'Low battery.';

  @override
  String get recSimulation => 'Simulation';

  @override
  String get recStarting => 'Starting camera…';

  @override
  String recError(String msg) {
    return 'Error: $msg';
  }

  @override
  String get libEmpty => 'No recordings yet.';

  @override
  String get libOpen => 'Open';

  @override
  String get libShare => 'Share';

  @override
  String get libDelete => 'Delete';

  @override
  String get libDeleteConfirm => 'Delete this recording?';

  @override
  String get libCancel => 'Cancel';

  @override
  String get libDeleteDo => 'Delete';

  @override
  String get libNote =>
      'Videos are in Movies/PedalaCast; GPX and JSON files in Documents/PedalaCast.';

  @override
  String get layoutTitle => 'Overlay layout';

  @override
  String get layoutSize => 'Size';

  @override
  String get layoutSmall => 'Small';

  @override
  String get layoutMedium => 'Medium';

  @override
  String get layoutLarge => 'Large';

  @override
  String get layoutBlocks => 'Blocks';

  @override
  String get layoutPhone => 'Phone';

  @override
  String get layoutNoDevice => 'No device';

  @override
  String get layoutNoDeviceHint =>
      'Connect a Bluetooth sensor to show this data (coming soon).';

  @override
  String get layoutFullTrack => 'Show full route on the mini-map';

  @override
  String get blk_speed_gauge => 'Speedometer';

  @override
  String get blk_distance_climb => 'Distance and climb';

  @override
  String get blk_minimap => 'Mini-map';

  @override
  String get blk_elevation_profile => 'Elevation profile';

  @override
  String get blk_grade_badge => 'Grade badge';

  @override
  String get blk_hr => 'Heart rate';

  @override
  String get blk_cadence => 'Cadence';

  @override
  String get blk_power => 'Power';

  @override
  String get blk_phone_status => 'Phone status bar';

  @override
  String get blk_live_badge => 'REC / LIVE badge';

  @override
  String get setTitle => 'Settings';

  @override
  String get setResolution => 'Resolution';

  @override
  String get set1080 => '1080p (30 fps)';

  @override
  String get set720 => '720p (30 fps)';

  @override
  String get setKeepScreen => 'Keep screen on';

  @override
  String get setMic => 'Record microphone';

  @override
  String get setAutoPause => 'Auto-pause (when stopped)';

  @override
  String setPrivacy(int m) {
    return 'Privacy zone: $m m';
  }

  @override
  String get setPrivacyHint =>
      'The route is not drawn on the mini-map within this radius of the starting point.';

  @override
  String get setSimulation => 'Simulation mode';

  @override
  String get setSimulationHint =>
      'Plays a sample route as if it were live GPS, to test the overlay without riding.';

  @override
  String get dbgTitle => 'Overlay debug';

  @override
  String get dbgBody =>
      'Renders the overlay over a static image with fixed data and saves a PNG in Pictures/PedalaCast.';

  @override
  String get dbgRender => 'Generate PNG';

  @override
  String dbgSaved(String uri) {
    return 'PNG saved: $uri';
  }

  @override
  String get bgTitle => 'Prevent the system from stopping the recording';

  @override
  String get bgBody =>
      'On phones such as Xiaomi, Redmi and POCO (HyperOS/MIUI), the system may close the app in the background and lose the video. Before riding: allow autostart and set PedalaCast battery to \"No restrictions\".';

  @override
  String get bgAutostart => 'Autostart';

  @override
  String get bgBattery => 'Battery';

  @override
  String get setOrientation => 'Video orientation';

  @override
  String get setLandscape => 'Landscape';

  @override
  String get setPortrait => 'Portrait';

  @override
  String get recSettings => 'Settings';

  @override
  String get homeLive => 'Go live (YouTube)';

  @override
  String get liveTitle => 'YouTube Live';

  @override
  String get liveHelp =>
      'In YouTube Studio, create a live stream and copy the server URL and the stream key. Paste them below.';

  @override
  String get liveUrl => 'Server URL (RTMPS)';

  @override
  String get liveKey => 'Stream key';

  @override
  String get liveKeyHint =>
      'The key is stored encrypted on this device and is never shown or logged. Do not share it.';

  @override
  String get liveBadUrl => 'Use a URL starting with rtmps://';

  @override
  String get liveNoKey => 'Paste the YouTube stream key.';

  @override
  String get liveQuality => 'Quality';

  @override
  String get live720 => '720p (up to 4 Mbps)';

  @override
  String get live1080 => '1080p (up to 6 Mbps)';

  @override
  String get liveRecordLocal => 'Record a copy on the phone';

  @override
  String get liveRecordLocalHint =>
      'Uses the same video as the stream (with overlay) and keeps going if the network drops.';

  @override
  String get liveHideMap => 'Hide mini-map';

  @override
  String get liveGo => 'Go live';

  @override
  String get liveTip =>
      'Test first with an \"Unlisted\" stream in YouTube Studio. The bitrate adapts to your network automatically.';

  @override
  String get liveOnAir => 'LIVE';

  @override
  String get liveConnecting => 'Connecting…';

  @override
  String get liveReconnecting => 'Reconnecting…';

  @override
  String liveBitrate(String mbps) {
    return '$mbps Mbps';
  }

  @override
  String liveDropped(int n) {
    return '$n dropped frames';
  }

  @override
  String get ovLiveLabel => 'LIVE';

  @override
  String get ovHrLabel => 'HR';

  @override
  String get ovRecLabel => 'REC';

  @override
  String get editOpen => 'Move and resize blocks';

  @override
  String get editTitle => 'Move and resize';

  @override
  String get editResetAll => 'Reset all';

  @override
  String get editResetBlock => 'Reset block';

  @override
  String editHelp(String orientation) {
    return 'Drag blocks wherever you like. Tap a block to change its size. Positions are saved for $orientation orientation.';
  }

  @override
  String editSize(int pct) {
    return '$pct%';
  }

  @override
  String get editTapHint => 'Tap a block to select it and adjust its size.';

  @override
  String get camSwitch => 'Switch camera';

  @override
  String get camPickTitle => 'Which camera to use?';

  @override
  String get camPickHint =>
      'Choose the camera to record with. You can change it later with the camera button on the recording screen.';

  @override
  String get camAuto => 'Automatic (main rear)';

  @override
  String get camFront => 'Front';

  @override
  String get camRearMain => 'Rear main';

  @override
  String get camRearUltra => 'Rear ultra-wide';

  @override
  String get camRearTele => 'Rear telephoto';

  @override
  String camMp(int mp) {
    return '$mp MP';
  }

  @override
  String get blk_pip => 'Front camera (PIP)';

  @override
  String get pipHint =>
      'Shows the front camera in a window on the video. Drag and resize it in \"Move and resize blocks\".';

  @override
  String get pipUnsupported =>
      'This phone cannot use the front and rear cameras at the same time (or the chosen camera is the front one).';
}
