import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// URL e chave de transmissão do YouTube, guardadas criptografadas.
/// A chave nunca é registrada em log nem mostrada sem o usuário pedir.
class LiveStore {
  static const defaultUrl = 'rtmps://a.rtmps.youtube.com:443/live2';
  static const _kUrl = 'live_url';
  static const _kKey = 'live_key';
  final _s = const FlutterSecureStorage();

  Future<String> url() async => (await _s.read(key: _kUrl)) ?? defaultUrl;
  Future<String?> key() => _s.read(key: _kKey);

  Future<void> save(String url, String key) async {
    await _s.write(key: _kUrl, value: url.trim());
    await _s.write(key: _kKey, value: key.trim());
  }

  Future<void> clear() async {
    await _s.delete(key: _kKey);
  }

  /// URL completa de ingestão (URL + "/" + chave) ou null se não há chave.
  Future<String?> endpoint() async {
    final k = (await key())?.trim();
    if (k == null || k.isEmpty) return null;
    final u = (await url()).trim().replaceAll(RegExp(r'/+$'), '');
    return '$u/$k';
  }

  /// Só aceita rtmps:// (ou rtmp:// para testes em rede local).
  static bool isValidUrl(String u) {
    final t = u.trim();
    return RegExp(r'^rtmps?://[^\s/]+(:\d+)?(/[^\s]*)?$').hasMatch(t);
  }
}
