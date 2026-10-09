# PedalaCast

App Android que grava passeios de bike com um overlay de telemetria dentro do vídeo: velocímetro em arco, mini-mapa, distância, ganho de elevação, inclinação e perfil de elevação.

Status: Fase 1 (gravação com overlay + Sobre). **Ainda não testado em aparelho.** Live no YouTube, sensores BLE e demais fases virão depois.

Detalhes técnicos em `docs/` e `CLAUDE.md`. Para compilar: Flutter estável, Android SDK 37, JDK 21 (`flutter build apk`).

O APK de cada versão está em *Releases*. Ele é assinado com a chave de debug (não é um build para a Play Store).
