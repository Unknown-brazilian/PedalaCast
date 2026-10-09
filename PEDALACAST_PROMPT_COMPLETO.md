# Prompt completo: PedalaCast (todas as funções)

> Substitui os prompts anteriores (`PEDALACAST_PROMPT.md` e a primeira versão deste arquivo, sem a Fase 6). Como usar: coloque `pedalacast-brand.zip` na raiz da pasta do projeto, abra o Claude Code nessa pasta e diga:
> "Leia PEDALACAST_PROMPT_COMPLETO_V2.md e execute a Fase 1."

---

## 1. Objetivo

Criar o **PedalaCast**, um app **somente Android** que grava passeios de bike e transmite ao vivo no YouTube, com um **overlay de telemetria gravado dentro do vídeo**, no estilo de câmeras de ação: velocímetro em arco, mini-mapa do trajeto, distância, ganho de elevação, inclinação e perfil de elevação. Tudo funciona só com o celular (GPS, barômetro, bateria, sinal). Sensores externos (cinta de batimentos, cadência, potência) entram depois, e arquivos FIT/GPX de ciclocomputadores e relógios também.

O app tem ainda uma tela **Sobre** (autor e doação em Bitcoin), uma aba **Equipamentos** com catálogo atualizável remotamente e links de afiliado e, por fim, uma tela de **pontos de interesse e rotas patrocinadas** (cafés, oficinas, pontos de água) com cupons e rotas em GPX, para ajudar a manter o app gratuito.

Público principal: brasileiro. Interface em português do Brasil (pt-BR), números com vírgula decimal, unidades km/h, km e m.

## 2. Decisões já tomadas (não reabrir sem motivo forte)

- **Somente Android.** Nada de iOS.
- **Flutter para as telas, Kotlin para o núcleo de vídeo e telemetria.** Câmera, compositor, encoder, GPS, sensores e serviço em primeiro plano ficam em `android/`. O Flutter conversa com ele por MethodChannel/EventChannel.
- **Um único pipeline em tempo real:** câmera → compositor OpenGL (com overlay) → encoder H.264 → arquivo MP4 e, quando ativo, RTMPS para o YouTube. O overlay vai gravado no vídeo, na gravação local e na live.
- **Sempre salvar um log de telemetria** (GPX e JSON) junto de cada vídeo.
- **Live só para YouTube.** Sem TikTok e sem Instagram.
- **Sem conta de usuário e sem coleta de dados pessoais.** Rede só quando o usuário transmite, quando baixa o catálogo de equipamentos ou quando usa a API do YouTube.
- **Patrocinadores nunca recebem a localização nem o rastreio dos usuários.** Cupons, e não check-in por GPS, medem o resultado. Nada patrocinado aparece no overlay do vídeo.
- Uma pessoa desenvolve e mantém o app: prefira soluções simples e bem mantidas.
- Todos os textos de interface em arquivos ARB (`flutter gen-l10n`), com pt-BR agora e estrutura pronta para en/es no futuro. Sem texto fixo em widgets.

## 3. Passo 0: identidade visual (faça primeiro)

Assets em `pedalacast-brand.zip` (`svg/`, `png/`, `brand_colors.json`).

1. Extraia para `assets/brand/` e registre no `pubspec.yaml`. Não sobrescreva nada sem avisar.
2. Se não existir projeto Flutter na pasta, **pergunte o nome do pacote/organização** e rode `flutter create --platforms=android pedalacast`.
3. `flutter_launcher_icons` (dev_dependency): `android: true`, `ios: false`, `image_path: assets/brand/png/app_icon.png`, `adaptive_icon_background: "#1F2430"`, `adaptive_icon_foreground: assets/brand/png/ic_launcher_foreground.png`, `adaptive_icon_monochrome: assets/brand/png/ic_launcher_monochrome.png`. Confirme na documentação da versão instalada se `monochrome` é suportado; se não for, adicione `<monochrome>` manualmente em `res/mipmap-anydpi-v26/ic_launcher.xml`.
4. `flutter_native_splash` (dev_dependency): `color: "#1F2430"`, `image: assets/brand/png/splash_icon.png`, bloco `android_12` com a mesma cor e imagem, `ios: false`, `web: false`.
5. `android:label` = "PedalaCast". Não altere o `applicationId` depois de definido.
6. Tema escuro em `lib/theme/`: `primary` = laranja, `onPrimary` = fundo escuro (**nunca branco sobre laranja**, o contraste é ruim). Dois tons neutros derivados do fundo (superfície e texto secundário), documentados.

### Cores da marca (fonte única: `assets/brand/brand_colors.json`)

| Papel | Valor | Uso |
|---|---|---|
| background | `#1F2430` | fundo do app e dos painéis do overlay |
| accent | `#FF7A2F` | destaques: arco do velocímetro, trajeto, botões principais |
| live | `#FF4D3D` | **somente** "AO VIVO" e "gravando". Nunca para erro |
| text | `#FFFFFF` | texto |
| onAccent | `#1F2430` | texto sobre fundo laranja |
| warning | `#FFC857` | avisos e erros, sempre com ícone e texto |

O módulo Kotlin do overlay lê essas mesmas cores do JSON (passado pelo Flutter ou lido dos assets), sem duplicar valores no código.

## 4. Arquitetura

### 4.1 Flutter (`lib/`)
Organização por feature, estado com Riverpod:
- `features/record`: tela principal (preview + iniciar/parar), contador e indicadores.
- `features/live`: tela de transmissão (Fase 2).
- `features/layout`: "Layout do overlay" (tamanho pequeno/médio/grande, interruptores por bloco, seção "Celular").
- `features/devices`: sensores e importação (Fases 3 e 4).
- `features/library`: lista de gravações (abrir no player do sistema, compartilhar, excluir).
- `features/shop`: aba Equipamentos (Fase 5).
- `features/places`: pontos de interesse e rotas patrocinadas (Fase 6).
- `features/about`: tela Sobre (Fase 1).
- `features/settings`: resolução, fps, unidades, manter tela ligada, microfone, zona de privacidade.
- `core/telemetry`: modelos Dart espelhando o formato da seção 5.
- `theme/`: cores e tema.

Preview: avalie e escolha, documentando em `docs/DECISIONS.md`, entre `AndroidView` (PlatformView) hospedando a view GL da biblioteca de vídeo ou um `Texture`. Critério: sem quedas de fps e o preview mostra o **quadro real já composto com o overlay**.

### 4.2 Kotlin (`android/app/src/main/kotlin/...`)
- `TelemetryEngine`: coleta e processa os dados (seção 5). Usa **um único relógio** (`SystemClock.elapsedRealtimeNanos`) para todas as amostras, inclusive as de BLE.
- `TelemetrySource` (interface): GPS, barômetro, bateria e sinal na Fase 1; BLE na Fase 3; arquivo FIT/GPX na Fase 4.
- `OverlayRenderer`: desenha o overlay em um `Canvas` sobre um `Bitmap`, a partir de um **layout em JSON** e do último `TelemetrySample`. Atualiza ~5 vezes/s (velocímetro até 10 Hz) e só envia nova textura à GPU quando algo mudou. Tamanhos proporcionais à altura do vídeo (referência: 720 px).
- `VideoPipeline`: câmera, composição com o overlay, encoder, gravação em MP4 e, na Fase 2, RTMPS.
- `RecordingService`: serviço em primeiro plano.
- `Channels`: `MethodChannel("pedalacast/control")` para iniciar/parar/pausar/configurar; `EventChannel("pedalacast/telemetry")` e `EventChannel("pedalacast/status")` para a UI (preview, tempo, GPS, armazenamento, temperatura, rede, bitrate).

### 4.3 Biblioteca de vídeo
Primeira opção: **RootEncoder** (câmera, filtros OpenGL, gravação e RTMP/RTMPS no Android). **Antes de adotar:** verifique a versão atual, a manutenção e como ela aceita um `Bitmap` como camada de overlay, além de gravar e transmitir ao mesmo tempo com o mesmo encoder. Se não servir, proponha alternativa e registre em `docs/DECISIONS.md` antes de seguir. Não invente nomes de classes: confirme na documentação/código da versão instalada.

## 5. Telemetria

### 5.1 Formato interno (`TelemetrySample`)
Campos anuláveis onde o dado pode faltar:
`tMs` (relógio monotônico), `epochMs`, `lat`, `lon`, `speedMps`, `altitudeM` (já combinada), `gradePct`, `distanceM`, `ascentM`, `hrBpm?`, `cadenceRpm?`, `powerW?`, `batteryPct`, `charging`, `signalLevel?` (0–4), `networkType?`, `tempC?` (da bateria).

### 5.2 Regras de cálculo
- **GPS a 1 Hz.** Velocidade: use a velocidade do `Location` e suavize com média móvel de 3–5 amostras. Se a precisão for ruim, mostre "—" em vez de um número errado.
- **Altitude:** barômetro (`TYPE_PRESSURE`) para as variações, ancorado pelo GPS (filtro complementar). Sem barômetro, use só o GPS e **avise o usuário** de que inclinação e D+ ficam menos confiáveis.
- **Ganho de elevação (D+):** soma só das subidas, com histerese de 2–3 m.
- **Inclinação (%):** variação de altitude / distância em janela deslizante de 50–100 m (só o trecho já percorrido). O selo só aparece quando |inclinação| ≥ 3%.
- **Distância:** Haversine entre pontos válidos, ignorando saltos de GPS e paradas.
- **Pausa automática** opcional por velocidade baixa.
- **Bateria, sinal, temperatura:** `BatteryManager` e `TelephonyManager`/`SignalStrength`. Ausência de permissão ou de dado vira "indisponível", nunca erro.

### 5.3 Log
Gravar `.gpx` e `.json` com as amostras, ao lado do vídeo, com o mesmo nome base. Escrita incremental para não perder dados se o app morrer.

## 6. Overlay: especificação visual

Estilo câmera de ação, discreto. Painéis `background` com transparência (0,35–0,75), texto branco, laranja só no dado em destaque.

- **Velocímetro em arco** (canto inferior esquerdo): arco de 270° (trilha branca a 30%, progresso laranja), número grande no centro, "km/h" abaixo, na abertura do arco. Ao lado: distância (`31,4 km`) e `D+ 182 m`.
- **Mini-mapa redondo** (canto inferior direito): sem tiles de mapa. Polyline normalizada do trajeto: percorrido em laranja, restante (se conhecido) branco a 40%, ponto atual com contorno branco. Padrão: trecho recente (~2 km) centralizado na posição atual, norte para cima. Opção "trajeto completo".
- **Perfil de elevação** (faixa na base, entre velocímetro e mapa): área branca translúcida, trecho percorrido em laranja, marcador na posição atual.
- **Selo de inclinação** (acima do perfil): só quando |inclinação| ≥ 3%. Cor por faixa: 3–6% amarelo `#FFC857`, 6–10% laranja `#FF7A2F`, >10% laranja escuro `#D9480F`. **Nunca o vermelho "live".**
- **Chips de sensores** (canto superior esquerdo): batimentos, cadência, potência, só com dado.
- **Faixa de status do celular** (canto superior direito, opcional, desligada por padrão): horário, barras de sinal, bateria.
- **Selo "AO VIVO"/"REC"** (canto superior esquerdo): vermelho `live`, com tempo decorrido.
- **Tamanhos:** pequeno ≈ 5%, médio ≈ 10%, grande ≈ 18% da área do quadro. Padrão: pequeno.
- **Regra geral:** bloco sem dado não é desenhado e não deixa buraco no layout.

### Layout em JSON
Lista de blocos com `id`, `type` (`speed_gauge`, `distance_climb`, `minimap`, `elevation_profile`, `grade_badge`, `hr`, `cadence`, `power`, `phone_status`, `live_badge`), `enabled`, `anchor` e `sizePreset`. O Flutter edita e salva esse JSON; o Kotlin só lê e desenha. Todo o visual é definido **no Kotlin**: não duplique a renderização em Flutter.

## 7. Plano em fases

**Regra de execução:** ao fim de cada fase, rode as verificações, escreva o resumo em `docs/PROGRESSO.md`, apresente o checklist e **pare até eu dizer "continuar"**. Nunca comece a fase seguinte por conta própria.

### Fase 1: gravação com overlay + Sobre
1. Passo 0 (identidade visual).
2. Permissões em tempo de execução (câmera, microfone, localização precisa; notificações no Android 13+) com telas explicativas em pt-BR. Aviso de segurança no primeiro uso: não mexer no celular em movimento e usar suporte firme.
3. `RecordingService` em primeiro plano com os tipos corretos (câmera, localização, microfone), declarados no manifesto, incluindo as permissões de serviço em primeiro plano do Android 14+. `WAKE_LOCK` e opção de manter a tela ligada.
4. `TelemetryEngine` completo (seção 5), com testes unitários.
5. `OverlayRenderer` com os blocos: velocímetro, distância/D+, mini-mapa, perfil de elevação, selo de inclinação, faixa de status do celular e selo REC.
6. `VideoPipeline`: preview com overlay, gravação MP4 com overlay (padrão 1080p/30 fps, opção 720p), pausar/retomar, parar.
7. Salvar em `Movies/PedalaCast` via MediaStore, com `.gpx` e `.json`. Investigue e documente como garantir que uma gravação interrompida (app morto, bateria, falta de espaço) deixe um arquivo reproduzível.
8. Tela "Layout do overlay" (tamanho, interruptores, seção "Celular").
9. Biblioteca simples de gravações.
10. **Modo simulação:** reproduz um GPX de exemplo como se fosse GPS ao vivo, para testar o overlay sem pedalar. Crie um GPX de exemplo com uma subida e uma descida.
11. **Tela de debug do overlay:** renderiza o overlay sobre uma imagem estática com dados fixos e salva um PNG.
12. **Tela Sobre** (seção 8).

### Fase 2: live no YouTube
Detalhes na seção 9.

### Fase 3: sensores Bluetooth
- BLE implementado **em Kotlin**, alimentando o `TelemetryEngine` no mesmo relógio. Perfis padrão: Heart Rate (`0x180D`), Cycling Speed and Cadence (`0x1816`), Cycling Power (`0x1818`).
- Tela "Dispositivos": buscar, conectar, reconectar sozinho, esquecer, mostrar bateria do sensor quando disponível. Permissões `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` (Android 12+) e as equivalentes para versões anteriores.
- Blocos de sensor do overlay aparecem só com dado. No layout, a linha do bloco mostra "Sem dispositivo" quando não há sensor, e ao tocar avisa o que conectar (nada de interruptor desabilitado).
- Prioridade de fontes: sensor externo > celular para batimentos/cadência/potência; velocidade pelo GPS, ou pelo sensor de roda se existir.
- Smartwatch: só o que ele expuser por BLE padrão (ex.: transmissão de batimentos). Não prometa integração além disso.
- Se um sensor cair durante a gravação, o bloco some e a gravação continua.

### Fase 4: importar FIT/GPX e reprocessar vídeo (opcional)
- Importar arquivos `.fit` e `.gpx` (ciclocomputador, relógio, outros apps). Para FIT, confira a licença e a biblioteca disponível antes de escolher.
- **Reprocessar vídeo:** escolher um vídeo existente e um log (do próprio app ou importado), ajustar o **offset** de sincronização (deslizador com preview) e gerar um novo MP4 com o overlay, usando o mesmo `OverlayRenderer`.
- Mostrar progresso, permitir cancelar, e avisar que vídeos longos demoram.

### Fase 5: aba Equipamentos + painel admin
Detalhes na seção 10.

### Fase 6: pontos de interesse, rotas e cupons patrocinados
Detalhes na seção 11. Depende da Fase 4 (leitura de GPX) e da Fase 5 (backend e painel admin).

## 8. Tela Sobre

Dados em `assets/about_config.json` (nada fixo no código):
```json
{
  "authorName": "Arthur",
  "bio": "Técnico em eletrônica e desenvolvedor. Ciclista.",
  "links": [{ "label": "GitHub", "url": "https://github.com/Unknown-brazilian" }],
  "feedbackEmail": "",
  "privacyPolicyUrl": "",
  "lightningAddress": "opt_out@walletofsatoshi.com"
}
```
Campos vazios escondem a respectiva seção. Confirme comigo o nome, a bio e os links antes de publicar.

Conteúdo da tela:
- **Cabeçalho:** ícone do app, "PedalaCast", versão (`package_info_plus`).
- **Autor:** nome, bio curta, links (abrem no navegador), botão "Enviar feedback" se houver e-mail.
- **Apoie o projeto:**
  - Texto: "O PedalaCast é gratuito. Se ele foi útil, você pode apoiar com Bitcoin pela rede Lightning."
  - **Campo somente leitura** com o endereço Lightning (`lightningAddress`), botão **Copiar** (clipboard + confirmação "Endereço copiado"), **QR code** do endereço (`qr_flutter`, fundo branco para leitura) e botão **Abrir na carteira** (`url_launcher` com `lightning:<endereço>`; se nenhum app tratar, mostrar mensagem simples).
  - Observação visível: é um **endereço Lightning** (formato parecido com e-mail), não um endereço on-chain. Enviar on-chain não funciona.
  - Aviso: "Doação voluntária. Não libera recursos nem dá vantagens."
  - Validar o formato do endereço (`nome@dominio`); se for inválido ou vazio, esconder a seção.
  - Teste o QR com pelo menos duas carteiras Lightning diferentes e registre em `docs/TESTES.md` qual formato (endereço puro ou `lightning:`) as duas leram.
  - **Não processar pagamento dentro do app**, não pedir dados e não condicionar nada à doação.
- **Legal:** política de privacidade (URL de `about_config.json`), licenças de código aberto (`showLicensePage`), aviso de segurança.

Para a publicação na Play Store: registre em `docs/PUBLICACAO.md` que as políticas de pagamentos e de cripto da Google precisam ser conferidas antes do envio (o app só exibe um endereço de doação voluntária, sem vender nada). Não afirme que está de acordo: apenas liste os pontos a verificar.

## 9. Live no YouTube (Fase 2)

### 9.1 Transmissão
- RTMPS para o YouTube (confira na documentação atual os endereços de ingestão; em geral `rtmps://a.rtmps.youtube.com:443/live2`).
- Parâmetros iniciais: 720p/30 fps com 1,5–4 Mbps; opção 1080p/30 fps com 3–6 Mbps (confirme as faixas recomendadas atuais do YouTube). Keyframe a cada 2 s, áudio AAC 128 kbps.
- **Bitrate adaptativo** conforme a rede (veja se a biblioteca já oferece um adaptador; registre a escolha).
- **Reconexão automática** com espera crescente quando o RTMP cair. **A gravação local nunca para** por causa de problema de rede.
- Gravação local com overlay durante a live (compartilhando o encoder). Opção avançada, desligada por padrão: cópia limpa com segundo encoder, com aviso de calor e bateria.
- Microfone ligado/desligado e medidor de nível.

### 9.2 Duas formas de configurar (nesta ordem)
1. **Chave manual (padrão):** campo para colar URL e chave do YouTube Studio, guardados criptografados (`flutter_secure_storage` ou equivalente), mascarados na tela e **nunca registrados em log**.
2. **Login Google + API do YouTube Live (opcional):** criar a transmissão automaticamente (título, visibilidade), vincular o stream, iniciar e encerrar (`liveBroadcasts` e `liveStreams`). Use a API de autorização atual do Android (verifique a documentação vigente), com o menor escopo possível. Avise-me desde o início que o escopo do YouTube exige verificação do app pela Google para uso público e que há cota diária de API: registre isso em `docs/PUBLICACAO.md`.

### 9.3 Tela de transmissão
- Preview com overlay, selo "AO VIVO" com o tempo.
- Indicadores: rede, bitrate real, quadros perdidos, bateria, temperatura, espaço livre.
- Título e visibilidade (público, não listado, privado). Padrão: **não listado** nos testes.
- **Ocultar mini-mapa** (interruptor).
- **Zona de privacidade:** raio configurável (padrão 300 m) em torno do ponto de partida, onde o trajeto não é desenhado no mini-mapa. Disponível também para a gravação local.
- Iniciar com um toque, **parar exige segurar o botão**.
- Aviso quando a bateria ficar baixa ou o celular esquentar, com opção de reduzir a qualidade.

### 9.4 Testes da live
- Primeiro contra um servidor RTMP local (por exemplo, MediaMTX) na rede Wi-Fi, depois contra o YouTube com transmissão não listada.
- Teste com rede móvel instável, troca de Wi-Fi para 4G e perda total de rede por alguns minutos.

## 10. Aba Equipamentos + painel admin (Fase 5)

### 10.1 No app
- Aba "Equipamentos": filtros por categoria, cartões com imagem, título, descrição curta, selo "Compatível com o app" (só nos itens marcados) e botão "Ver na loja".
- O botão abre o **navegador externo** (`url_launcher`, modo externo). Nenhum pagamento no app.
- **Aviso de afiliado sempre visível:** "Alguns links são de afiliados: o app pode receber uma comissão, sem custo extra para você."
- **Sem preços** na interface.
- Link por país (`BR`, `ES`, `default`), escolhido pela região do aparelho.
- Catálogo baixado do servidor (`ETag`/`If-None-Match`), guardado em cache local e funcionando offline com a última versão. Imagens em cache.
- Um campo `enabled` no catálogo permite desligar a aba remotamente.
- Contagem de cliques: **desligada por padrão**. Se for ligada no futuro, agregada e sem dados pessoais, e a declaração de segurança de dados da Play Store deve ser atualizada.
- Ligação com a tela Dispositivos: "Não tem um sensor? Veja opções compatíveis" leva à categoria Sensores.

### 10.2 Contrato do catálogo (JSON)
```json
{
  "version": 1,
  "updatedAt": "2026-01-01T00:00:00Z",
  "enabled": true,
  "categories": [{ "id": "sensors", "name": "Sensores", "order": 1 }],
  "items": [{
    "id": "hr-strap-1",
    "title": "Cinta de batimentos Bluetooth",
    "description": "Mostra batimentos no overlay",
    "imageUrl": "https://.../hr.webp",
    "categoryId": "sensors",
    "compatibleWithApp": true,
    "store": "Nome da loja",
    "links": { "BR": "https://...", "ES": "https://...", "default": "https://..." },
    "active": true,
    "order": 1
  }]
}
```

### 10.3 Painel admin (projeto separado, pasta `admin/`)
- Acesso **exclusivo do administrador**, no site do autor. O usuário citou "bit food.app": **confirme comigo o domínio exato** e qual stack o site usa.
- **Pergunte-me qual backend usar** antes de implementar. Recomendação: Supabase ou Firebase, com leitura pública do catálogo e escrita só para o usuário admin; alternativa: endpoint próprio no site com um banco simples. Registre a decisão em `docs/DECISIONS.md`.
- Funções: login do admin, criar/editar/ativar/desativar itens e categorias, upload de imagem (com redimensionamento), ordenar, links por país (somente `https://`), pré-visualizar como aparece no app, publicar (gera o JSON do contrato acima).
- Segurança: nenhuma credencial de admin dentro do app; regras de escrita só para o admin; proteção contra abuso no login.
- O app só lê o catálogo.

## 11. Pontos de interesse, rotas e cupons patrocinados (Fase 6)

Reaproveite o backend, o domínio e o painel admin da Fase 5 (registre em `docs/DECISIONS.md` qualquer ajuste). A leitura de GPX vem da Fase 4.

### 11.1 No app (`features/places`)
- Tela **"Pontos e rotas"** com filtros por categoria (as categorias vêm do catálogo; exemplos: Cafés, Oficinas, Água, Rotas) e lista **ordenada por distância**. A distância é calculada **no aparelho**, a partir da localização atual, e nunca é enviada ao servidor. Sem permissão de localização, ordene pela ordem do catálogo e ofereça pedir a permissão.
- **Cartão** com ícone ou imagem, nome, categoria, distância, oferta curta e botões. Itens patrocinados levam o selo **"Patrocinado"** (cor `warning`, sempre visível). Itens não patrocinados (por exemplo, pontos de água) aparecem misturados, sem selo.
- **"Ir até lá":** abre o app de mapas externo com o destino preenchido em modo bicicleta (verifique qual intent ou URL funciona nos mapas mais comuns e use o navegador como alternativa). **Sem motor de rotas e sem mapa com tiles dentro do app.**
- **"Ver cupom":** mostra o código, a validade e a instrução "Mostre esta tela no balcão". **Sem check-in por GPS e sem verificação de presença.** O comerciante mede os resgates.
- **Rotas:** cartão com distância, ganho de elevação, tempo estimado e patrocinador. **"Usar no mini-mapa"** baixa o GPX, valida (tamanho máximo, formato, número de pontos), guarda localmente e carrega o trajeto planejado: o trecho ainda não percorrido aparece em branco a 40% no mini-mapa. Permita remover a rota ativa. O app **não recalcula** o trajeto se o usuário sair da rota.
- Rodapé fixo: "Itens marcados como Patrocinado são anúncios de parceiros. Confira o trajeto antes de sair e respeite o trânsito."
- Cache do último catálogo (funciona offline) e estado vazio amigável ("Nenhum ponto por perto"). A aba some se `enabled` for `false`.
- Itens fora da janela de contrato (início/fim) não aparecem; o filtro roda no servidor e também no app.
- **Nunca** mostrar conteúdo patrocinado durante a gravação ou a live, nem no overlay do vídeo.
- Sem preços. Links externos abrem fora do app.

### 11.2 Contrato do catálogo (JSON)
```json
{
  "version": 1,
  "updatedAt": "2026-01-01T00:00:00Z",
  "enabled": true,
  "categories": [{ "id": "cafes", "name": "Cafés", "icon": "coffee", "order": 1 }],
  "places": [{
    "id": "cafe-roda-livre",
    "name": "Café Roda Livre",
    "categoryId": "cafes",
    "lat": -23.55,
    "lon": -46.63,
    "address": "Rua Exemplo, 100",
    "hours": "Seg a sáb, 7h às 19h",
    "description": "Café com espaço para bicicletas",
    "imageUrl": "https://.../cafe.webp",
    "sponsored": true,
    "offer": { "text": "10% de desconto para ciclistas", "couponCode": "PEDALA10", "validUntil": "2026-12-31" },
    "contract": { "startsAt": "2026-01-01", "endsAt": "2026-12-31" },
    "active": true,
    "order": 1
  }],
  "routes": [{
    "id": "volta-da-represa",
    "name": "Volta da represa",
    "distanceKm": 28,
    "ascentM": 240,
    "estimatedMinutes": 90,
    "gpxUrl": "https://.../represa.gpx",
    "sponsorName": "Padaria Pão e Pedal",
    "safetyNote": "Trecho com trânsito moderado entre os km 5 e 8.",
    "contract": { "startsAt": "2026-01-01", "endsAt": "2026-12-31" },
    "active": true,
    "order": 1
  }]
}
```
Para itens não patrocinados, `sponsored` é `false` e `offer` e `contract` são opcionais.

### 11.3 Painel admin (estende o da Fase 5)
- **Pontos:** nome, categoria, latitude/longitude com validação (geocodificação por endereço só se os termos do serviço escolhido permitirem; pergunte-me antes), horário, imagem (redimensionada), patrocinado sim/não, oferta (texto, código, validade), contrato (início e fim) e ativo.
- **Rotas:** upload de GPX. O painel **calcula distância, ganho de elevação e tempo estimado** e mostra o traçado em uma pré-visualização. O campo de **aviso de segurança é obrigatório**. Campo do patrocinador e contrato.
- **Rotina:** itens vencidos saem da lista sozinhos; painel com contratos próximos do vencimento; botão "pré-visualizar como aparece no app"; **publicar** gera o JSON do contrato acima; guarde a versão anterior para desfazer.
- **Validações:** somente `https://`; coordenadas em faixas válidas; limite de tamanho do GPX; sanitização de textos.
- Segurança igual à da Fase 5: login só do administrador, escrita só para ele, nenhuma credencial dentro do app.

### 11.4 Privacidade e regras
- A localização do usuário **nunca** sai do aparelho para o servidor ou para anunciantes.
- Contagem de cliques e de resgates: **desligada por padrão**. Se for ligada no futuro, deve ser agregada e sem dados pessoais, e a declaração de segurança de dados da Play Store precisa ser atualizada.
- Anúncios sempre identificados como "Patrocinado". Em `docs/PUBLICACAO.md`, liste os pontos a verificar sobre publicidade identificada no Brasil (por exemplo, o Código de Defesa do Consumidor e as orientações do CONAR) e as regras de anúncios da Play Store. **Não afirme conformidade**: apenas liste.
- Rotas patrocinadas passam por **revisão humana** antes de publicar. Inclua texto de isenção ("o trajeto é uma sugestão; avalie as condições antes de seguir").

### 11.5 Testes específicos
Leitura do catálogo, filtro por janela de contrato, ordenação por distância, estatísticas de GPX, tratamento de GPX inválido ou grande, e o roteiro manual: abrir destino no app de mapas, mostrar cupom, carregar e remover rota no mini-mapa, comportamento sem rede e sem permissão de localização.

## 12. Requisitos não funcionais

- **Bateria e calor são o maior risco.** Evite trabalho por quadro desnecessário (textura só quando muda, 30 fps). Registre a temperatura da bateria e mostre aviso quando passar de um limite razoável.
- **Robustez:** sem GPS mostrar "—" e seguir gravando; sem barômetro usar o fallback; sem espaço livre suficiente, avisar antes de iniciar e parar com segurança; ciclo de vida do app (segundo plano, tela bloqueada, rotação, chamada telefônica).
- **Uso na bike:** botões grandes, iniciar/parar com um toque, **parar exige segurar**. Mínimo de interação durante o passeio.
- **Privacidade e dados:** nada sai do aparelho, exceto a transmissão que o usuário inicia, o download dos catálogos (equipamentos, pontos e rotas) e o uso da API do YouTube. Sem analytics. Mantenha `docs/PUBLICACAO.md` com o que declarar no formulário de segurança de dados da Play Store.
- **Compatibilidade:** `minSdk` razoável (justifique) e tratamento de Android 12, 13 e 14.

## 13. Testes e verificação

- Testes unitários: suavização de velocidade, histerese do D+, inclinação por janela, distância, formato do log, zona de privacidade, interpretação do catálogo, validação do endereço Lightning, filtro de pontos por janela de contrato, ordenação por distância e leitura/estatísticas de GPX de rota.
- Rodar `flutter analyze`, `flutter test` e `flutter build apk --debug` a cada marco.
- Roteiro manual no aparelho, em `docs/TESTES.md`: gravação curta; gravação de 30+ minutos; app em segundo plano; tela bloqueada; sem GPS; sem barômetro; pouco espaço; live com rede instável; sensor BLE que desconecta; QR de doação em duas carteiras; abrir destino no app de mapas; cupom; rota patrocinada no mini-mapa.

## 14. Como trabalhar

- Crie `CLAUDE.md` na raiz com: resumo do projeto, decisões da seção 2, comandos úteis e convenções.
- Registre decisões técnicas em `docs/DECISIONS.md` (o quê, por quê, alternativas) e o andamento em `docs/PROGRESSO.md`.
- Passos pequenos e verificáveis. Antes de usar uma biblioteca, confira versão atual e manutenção.
- **Não faça commit sem eu pedir.**
- Se uma dúvida bloquear o progresso, faça **uma pergunta por vez**. Para o resto, escolha o caminho mais simples, registre em `DECISIONS.md` e siga.

## 15. Critérios de aceitação

### Fase 1
- [ ] Ícone adaptativo (com camada monocromática) e splash aplicados; nome "PedalaCast".
- [ ] Tema com as cores da marca; vermelho só para "live/REC".
- [ ] Grava MP4 em 1080p/30 fps **com o overlay dentro do vídeo**, em primeiro e em segundo plano.
- [ ] Overlay com velocidade, distância, D+, mini-mapa, perfil de elevação, selo de inclinação (≥ 3%), selo REC e status do celular opcional.
- [ ] Layout configurável e persistido; `.gpx` e `.json` salvos junto de cada vídeo.
- [ ] Modo simulação e tela de debug do overlay funcionando.
- [ ] Tela Sobre com autor, endereço Lightning copiável, QR e botão "Abrir na carteira".
- [ ] `flutter analyze` sem erros, testes passando, APK de debug compilando; `CLAUDE.md`, `DECISIONS.md`, `PROGRESSO.md`, `TESTES.md` e `PUBLICACAO.md` criados.

### Fase 2
- [ ] Transmite para o YouTube com overlay (chave manual), com reconexão e gravação local contínua.
- [ ] Bitrate adaptativo, indicadores de rede/bateria/temperatura, ocultar mini-mapa e zona de privacidade.
- [ ] Parar exige segurar. Chave nunca aparece em log.
- [ ] (Opcional) criação automática da transmissão via API.

### Fase 3
- [ ] Conecta cinta de batimentos, sensor de cadência/velocidade e medidor de potência; reconecta sozinho; blocos aparecem só com dado.

### Fase 4
- [ ] Importa FIT/GPX e gera MP4 reprocessado com offset ajustável.

### Fase 5
- [ ] Aba Equipamentos lê o catálogo remoto com cache offline, aviso de afiliado e links por país.
- [ ] Painel admin publica o catálogo e só o administrador consegue editar.

### Fase 6
- [ ] Tela "Pontos e rotas" lista itens por distância (calculada no aparelho), com selo "Patrocinado" e aviso no rodapé.
- [ ] "Ir até lá" abre o app de mapas em modo bicicleta; "Ver cupom" mostra código e validade, sem check-in nem rastreio.
- [ ] Rotas em GPX carregam no mini-mapa e podem ser removidas.
- [ ] Itens fora da janela de contrato não aparecem; catálogo funciona offline.
- [ ] Painel admin cadastra pontos e rotas (com cálculo automático de distância, elevação e tempo e aviso de segurança obrigatório) e publica.
- [ ] Nada patrocinado aparece no overlay, na gravação ou na live.

## 16. Fora de escopo

iOS, TikTok, Instagram, mapas com tiles, contas de usuário, pagamentos dentro do app, edição de vídeo geral, preços no catálogo, qualquer coleta de dados pessoais, check-in por GPS em estabelecimentos, rastreamento de localização para anunciantes, navegação curva a curva dentro do app.
