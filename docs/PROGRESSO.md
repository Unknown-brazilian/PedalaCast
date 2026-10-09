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
