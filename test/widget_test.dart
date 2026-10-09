import 'package:flutter_test/flutter_test.dart';
import 'package:pedalacast/core/about_config.dart';

void main() {
  test('valida endereço Lightning', () {
    expect(
      AboutConfig.isValidLightningAddress('opt_out@walletofsatoshi.com'),
      isTrue,
    );
    expect(AboutConfig.isValidLightningAddress('bc1qxyz'), isFalse);
    expect(AboutConfig.isValidLightningAddress(''), isFalse);
  });
}
