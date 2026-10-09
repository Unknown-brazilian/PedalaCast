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
