# Roteiro de testes manuais (Android)

Marque ao executar. Nada abaixo foi executado ainda.

- [ ] Gravação curta (1 min), 1080p/30: vídeo em Movies/PedalaCast com overlay; GPX/JSON em Documents/PedalaCast.
- [ ] Modo simulação (Ajustes): overlay mostra velocidade, mini-mapa, perfil, selo de inclinação (subida > 3%), D+ crescendo.
- [ ] Tela Debug do overlay: PNG salvo em Pictures/PedalaCast; conferir os blocos e as cores.
- [ ] Preview sem quedas de fps e igual ao vídeo gravado; orientação correta nas duas paisagens (esquerda/direita).
- [ ] Gravação de 30+ min: temperatura, bateria, tamanho do arquivo.
- [ ] App em segundo plano e tela bloqueada: gravação continua; notificação com "Parar".
- [ ] Sem GPS (modo avião/interior): "—" no velocímetro, grava normalmente.
- [ ] Sem barômetro: aviso exibido.
- [ ] Pouco espaço: recusa iniciar < 500 MB; para com segurança < 100 MB.
- [ ] Chamada telefônica durante a gravação.
- [ ] Parar exige segurar o botão (1,5 s); soltar antes cancela.
- [ ] Zona de privacidade: trajeto não aparece perto do ponto de partida.
- [ ] Permissões negadas: tela explicativa e atalho para os ajustes.
- [ ] Matar o app durante a gravação: verificar se o MP4 abre (esperado: pode não abrir).
- [ ] Sobre: copiar endereço, abrir na carteira, QR lido por duas carteiras Lightning. Registrar abaixo qual formato (endereço puro ou `lightning:`) cada uma leu.

| Carteira | Formato lido | OK |
|---|---|---|
| | | |
| | | |

## Xiaomi 14C (Android 14, HyperOS, MediaTek G85) e similares
- [ ] Aviso de bateria/início automático aparece ao abrir a gravação; os atalhos abrem as telas certas (senão cai em Informações do app).
- [ ] Com bateria "Sem restrições" + início automático: gravação de 30+ min com tela bloqueada não é encerrada pelo sistema.
- [ ] Sem esses ajustes: observar se o sistema mata o app (esperado em HyperOS) e se o MP4 fica ilegível.
- [ ] Sem barômetro: aviso exibido, D+ e inclinação aceitáveis só com GPS.
- [ ] 1080p/30 contra 720p/30: fps do preview, temperatura e tamanho do arquivo no chip G85.
- [ ] Permissão de localização "durante o uso" mantém o GPS com tela bloqueada via serviço em primeiro plano.

## Orientação vertical e botão de ajustes (v0.1.2)
- [ ] Ajustes > Orientação > Vertical: preview em retrato, vídeo gravado em retrato e na posição certa, overlay legível (perfil de elevação estreito).
- [ ] Botão de ajustes na tela de gravação: abre sem parar a gravação; mudar resolução/orientação/microfone fora da gravação reinicia o preview.

## Live no YouTube (v0.2.0)
- [ ] Contra MediaMTX local (`rtmp://IP:1935/live`) na mesma rede Wi-Fi: vídeo com overlay chega; selo AO VIVO.
- [ ] YouTube Studio, transmissão "Não listada": chave colada aparece mascarada; live inicia e o preview do Studio mostra o overlay.
- [ ] Derrubar o Wi-Fi/dados por alguns minutos: estado "Reconectando…", volta sozinho; a cópia local segue gravando.
- [ ] Trocar Wi-Fi ↔ 4G durante a live.
- [ ] Rede lenta: bitrate real cai e quadros perdidos sobem; sem travar o app.
- [ ] Parar exige segurar; MP4 local abre depois.
- [ ] Ocultar mini-mapa durante a live; chave nunca aparece em `adb logcat`.
- [ ] Idiomas: trocar o idioma do sistema para en/es/fr e conferir telas, notificação e rótulos do overlay.

## Mover e redimensionar blocos (v0.3.0)
- [x] Emulador: arrastar o mini-mapa e aumentar o velocímetro no editor; o perfil de elevação e a distância reorganizam; ao abrir a gravação, o preview mostra as posições salvas.
- [ ] Aparelho real: arrastar com o dedo, pinça não existe (usa o slider); posições persistem após fechar o app.
- [ ] Posições separadas em horizontal e vertical; "Restaurar tudo" volta ao automático.
- [ ] Vídeo gravado com blocos movidos: conferir que o MP4 tem os blocos nas mesmas posições do preview.
- [ ] "Ocultar mini-mapa" na live realmente some com o mini-mapa (corrigido nesta versão).

## Escolha de câmera (v0.3.1)
- [x] Emulador (1 câmera): botão aparece, lista mostra "Traseira principal (3 MP · 37mm)", escolher por ID abre a câmera e mostra o preview com overlay.
- [ ] Aparelho real com várias câmeras (ex.: Xiaomi 14C): a pergunta aparece na primeira gravação; a lista mostra frontal e traseiras; sensores de 2 MP aparecem identificáveis.
- [ ] Frontal: imagem na orientação certa na paisagem esquerda/direita e no modo vertical; vídeo gravado igual ao preview.
- [ ] Trocar câmera várias vezes seguidas não trava nem vaza câmera aberta.
