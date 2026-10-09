import 'package:flutter_test/flutter_test.dart';
import 'package:pedalacast/features/live/live_store.dart';

void main() {
  test('valida URL de ingestão', () {
    expect(
      LiveStore.isValidUrl('rtmps://a.rtmps.youtube.com:443/live2'),
      isTrue,
    );
    expect(LiveStore.isValidUrl('rtmp://192.168.0.10/live'), isTrue);
    expect(LiveStore.isValidUrl('https://example.com'), isFalse);
    expect(LiveStore.isValidUrl('rtmps://'), isFalse);
    expect(LiveStore.isValidUrl('rtmps://a b'), isFalse);
  });
}
