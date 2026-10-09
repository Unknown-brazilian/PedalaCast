# Progresso

## Fase 1: gravação com overlay + Sobre — código pronto, NÃO testado em aparelho
Feito e verificado por ferramentas (`flutter analyze` sem problemas, `flutter test` e testes unitários Kotlin passando, `flutter build apk --debug` OK):
- Passo 0: identidade visual em `assets/brand/`, ícone adaptativo (com monocromático) e splash gerados, nome "PedalaCast", tema escuro com as cores da marca.
- `TelemetryEngine/Processor` + testes (velocidade, D+, inclinação, distância, altitude, zona de privacidade).
- Logger incremental GPX/JSON; leitor de GPX (sem XXE, limite de pontos).
- `OverlayRenderer` com todos os blocos da Fase 1 + layout JSON.
- `PedalaCore` (preview com overlay, gravação MP4 via MediaStore, pausa/retoma, pausa automática), `RecordingService` (câmera/localização/microfone, Android 14).
- Telas: início, gravação (segurar para parar), permissões com explicação, aviso de segurança, layout do overlay, biblioteca, ajustes, debug do overlay, Sobre (Lightning, QR, copiar, abrir carteira).
- Modo simulação (`assets/sim/sample.gpx`, ~6 km com subida e descida).
- Docs: CLAUDE.md, DECISIONS, TESTES, PUBLICACAO.

Pendente / não verificado (sem aparelho Android conectado nesta máquina):
- Tudo que depende de câmera, GPS e encoder: gravação real, fps do preview, orientação, 1080p/30, segundo plano, tela bloqueada.
- Gravação interrompida deixa MP4 ilegível (ver DECISIONS).
- Confirmar nome, bio e links do `about_config.json`; `privacyPolicyUrl` e `feedbackEmail` estão vazios (seções ocultas).
- Blocos de sensores (FC/cadência/potência) existem no renderizador, mas só terão dados na Fase 3.
- QR em duas carteiras (ver TESTES).

## Verificação no emulador (Android 14, x86_64, câmera virtual) — v0.2.1
Gravação completa verificada: preview com overlay, modo simulação (25 km/h, distância subindo), MP4 H.264 1920x1080 + AAC com overlay gravado, GPX e JSON salvos, parar segurando, idiomas en/es, tela de debug do overlay (PNG).
Bugs achados e corrigidos nesse teste: leitor de GPX quebrava no Android (parser XML); aviso de segurança reaparecia e configurações podiam ser ignoradas ao abrir a gravação (carregamento assíncrono); idioma fixo em português; tela de debug sem rótulos; botão tonal fora da paleta.
Ainda NÃO verificado: sensores reais (GPS/barômetro), desempenho em aparelho físico, live contra servidor real, orientação vertical, Xiaomi.
