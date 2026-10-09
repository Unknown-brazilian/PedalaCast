# Decisões técnicas

## Biblioteca de vídeo: RootEncoder 2.8.1 (Apache-2.0)
Versão estável mais recente (set/2026), mantida. Confirmado no código da tag 2.8.1: `GenericStream` (câmera + microfone, preview em `Surface`, gravação e RTMP/RTMPS com o mesmo encoder), `ImageFilterRender.setImage(Bitmap)` como camada de overlay, `pauseRecord/resumeRecord`, `ConnectChecker` para RTMP.
Alternativas: Media3/CameraX + GL próprio (muito mais código), pedroSG94 apenas encoder (idem). Via JitPack (`maven("https://jitpack.io")`).
- `StreamBase.startRecord` só aceita caminho; como gravamos via MediaStore (scoped storage), `video/FdRecordController` delega ao `AndroidMuxerRecordController` usando o `FileDescriptor`.
- `setImage` não copia o Bitmap: usamos **dois bitmaps alternados** para não desenhar sobre o que a GPU lê.

## Preview: Texture (TextureRegistry), não PlatformView
`createSurfaceTexture()` → `Surface` → `GenericStream.startPreview(surface)`. O preview mostra o quadro **já composto com o overlay** (o mesmo do encoder). Evita PlatformView (custo de fps). Ainda **não medido em aparelho**: validar fps no roteiro de `TESTES.md`.

## minSdk 29 (Android 10)
Scoped storage/MediaStore sem caminho legado, `RELATIVE_PATH`, sem WRITE_EXTERNAL_STORAGE. Cobre a grande maioria dos aparelhos ativos. Android 12 (BLE novo, notificações), 13 (POST_NOTIFICATIONS) e 14 (tipos de serviço em primeiro plano) tratados no manifesto/permissões.

## compileSdk 37
`permission_handler_android` exige compileSdk 37; o AGP 9.1 recomenda ≤ 36. Usamos `android.suppressUnsupportedCompileSdk=37`. Reavaliar ao atualizar o AGP.

## Orientação: tela de gravação em paisagem
A tela de gravação trava em paisagem (`rotation=0` no pipeline). Suporte na bike em retrato não é tratado na Fase 1. O resto do app é livre.

## Armazenamento
Vídeo em `Movies/PedalaCast`; **GPX/JSON em `Documents/PedalaCast`** (MediaStore só aceita arquivos não-mídia em Documents/Downloads) com o mesmo nome base do vídeo. Isto difere de "ao lado do vídeo" da especificação.
Logs: escrita incremental com flush a cada amostra; o JSON é um array aberto (falta só o `]` se o app morrer).

## Gravação interrompida (app morto, bateria, sem espaço)
`MediaMuxer` grava o índice (`moov`) só no fim; se o processo morre, o MP4 fica **ilegível**. Mitigações implementadas: serviço em primeiro plano + wake lock (reduz mortes), parada segura quando o espaço livre cai de 100 MB, verificação de 500 MB antes de iniciar, parada em erro do gravador. **Não resolvido:** morte súbita/bateria. Opções para depois: segmentar a gravação em arquivos curtos (ex.: 10 min) ou um muxer MP4 fragmentado próprio. Decisão pendente, a validar com o usuário.

## Telemetria
Núcleo puro e testável (`TelemetryMath.kt`, `TelemetryProcessor.kt`); relógio único `elapsedRealtime`. GPS via `LocationManager` (sem Play Services). Altitude: barômetro para variações + GPS como âncora lenta (ganho 0,02); sem barômetro, GPS suavizado e aviso na tela. D+ histerese 2,5 m; inclinação janela 50–100 m, selo só com |grade| ≥ 3%; distância ignora saltos (>25 m/s), passos < 2 m e precisão > 30 m.

## Overlay
Bitmap do tamanho do vídeo, redesenhado a ~5 Hz **só quando algo muda** (assinatura da amostra/tempo/layout). Escalas por preset: pequeno 1,0 / médio 1,45 / grande 2,0 sobre a altura/720. O campo `anchor` do JSON é lido mas, na Fase 1, a posição é fixa por tipo de bloco (layout automático sem buracos). Cores lidas de `flutter_assets/assets/brand/brand_colors.json`; a única cor fora da paleta é o laranja escuro `#D9480F` (inclinação > 10%), definido na especificação.

## Interface
Riverpod; configurações em `shared_preferences`. Telas pt-BR em ARB (`nullable-getter: false`). Biblioteca de gravações lista via MediaStore (sem plugin extra); abrir/compartilhar/excluir pelo Kotlin.

## Orientação do vídeo (v0.1.2)
Ajuste "Horizontal/Vertical". Vertical usa `rotation=90` no `prepareVideo` (RootEncoder troca largura/altura do encoder); o bitmap do overlay e o preview usam o tamanho final do quadro. A escala do overlay passa a usar o lado menor/720, então os blocos têm o mesmo tamanho nas duas orientações. A tela de gravação trava na orientação escolhida. **Não testado em aparelho**: conferir se o preview e o vídeo saem na posição certa em retrato.

## Live no YouTube (v0.2.0, Fase 2 parcial)
- RTMPS pelo mesmo `GenericStream` (um encoder serve transmissão e gravação local com overlay). Consequência: o bitrate adaptativo também afeta o MP4 gravado durante a live.
- Chave manual (padrão): URL + chave em `flutter_secure_storage`, campo mascarado, nunca em log (o `ConnectChecker` ignora a URL). A chave só é lida na hora de ir ao vivo.
- Qualidade da live: 720p até 4 Mbps ou 1080p até 6 Mbps; keyframe a cada 2 s; áudio AAC 128 kbps. Bitrate adaptativo com `BitrateAdapter` (mínimo 1 Mbps) usando a congestão da fila de envio.
- Reconexão: falha/queda → `reTry` com espera crescente (2, 4, 8, 16, 30 s, até 1000 tentativas). A gravação local não depende da rede.
- Parar exige segurar o botão (para live e cópia local juntas). Ocultar mini-mapa por interruptor; zona de privacidade vale para live e gravação.
- **Não feito ainda:** criação automática da transmissão pela API do YouTube (login Google, escopo verificado), cópia limpa com segundo encoder, aviso/redução automática de qualidade por calor.
- **Não testado** contra servidor local (MediaMTX) nem contra o YouTube.

## Idiomas (v0.2.0)
pt (padrão do projeto), en, es, fr via ARB. Fora desses, cai em inglês. O overlay é desenhado no Kotlin: idioma (formato de números) e rótulos (AO VIVO/LIVE/EN VIVO/EN DIRECT, FC/HR) são enviados pelo Flutter ao iniciar o preview. Textos da notificação em `res/values*/strings.xml`. Mensagens de erro vindas do Kotlin ainda estão em português.
