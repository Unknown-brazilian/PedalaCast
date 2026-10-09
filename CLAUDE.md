# PedalaCast

App **somente Android** que grava passeios de bike com overlay de telemetria (velocímetro em arco, mini-mapa, distância, D+, inclinação, perfil de elevação) gravado dentro do vídeo. Fases 2+ (live YouTube, BLE, FIT/GPX, Equipamentos, Pontos e rotas) estão em `PEDALACAST_PROMPT_COMPLETO.md`.

## Decisões (resumo; detalhes em docs/DECISIONS.md)
- Flutter para telas, Kotlin para câmera/compositor/encoder/GPS/sensores/serviço (`android/app/src/main/kotlin/br/com/arthur/pedalacast`).
- Um pipeline: câmera → OpenGL (overlay) → H.264 → MP4 (e RTMPS na Fase 2). RootEncoder 2.8.1.
- Sem conta, sem analytics, sem dados pessoais. Nada patrocinado no overlay. UI em pt-BR via ARB.
- applicationId `br.com.arthur.pedalacast` (não alterar). minSdk 29.
- Cores: fonte única `assets/brand/brand_colors.json`. Vermelho "live" só para REC/AO VIVO; avisos em `warning`.

## Comandos
```
export PATH=$HOME/development/flutter/bin:$PATH ANDROID_HOME=$HOME/Android/Sdk
flutter gen-l10n && flutter analyze && flutter test
cd android && ./gradlew :app:testDebugUnitTest      # testes Kotlin (telemetria)
flutter build apk --debug
dart run flutter_launcher_icons && dart run flutter_native_splash:create
```

## Convenções
- Textos só em `lib/l10n/app_pt.arb`. Visual do overlay só no Kotlin (`overlay/OverlayRenderer.kt`).
- Layout do overlay é JSON (Flutter edita, Kotlin lê). Telemetria: `TelemetrySample` (Kotlin) ⇄ `core/telemetry` (Dart).
- Não fazer commit sem pedido. Pare ao fim de cada fase e espere "continuar".
