# Publicação (Play Store) — pontos a verificar

Não afirma conformidade; apenas lista o que conferir.

## Declaração de segurança de dados
- Localização precisa: usada no aparelho (telemetria e log local). Nada enviado a servidores (Fase 1).
- Câmera/microfone: gravação local.
- Sem analytics, sem contas, sem anúncios.
- Rede só quando houver live (Fase 2), catálogos (Fases 5 e 6) ou API do YouTube.
- Contagem de cliques/resgates: desligada; se ligada, atualizar a declaração.

## Permissões e serviços
- Serviço em primeiro plano nos tipos camera, location e microphone; justificar no formulário de declaração de serviços (Android 14+).
- `READ_PHONE_STATE` (intensidade do sinal) é opcional: avaliar se vale a declaração; pode ser removido.
- `INTERNET`/`ACCESS_NETWORK_STATE` presentes antes da Fase 2 (usados para o tipo de rede).

## Doação em Bitcoin (tela Sobre)
- Verificar as políticas de pagamentos e de cripto da Google. O app só exibe um endereço Lightning de doação voluntária, sem vender nada nem condicionar recursos.
- Política de privacidade: preencher `privacyPolicyUrl` antes de publicar.

## Fase 2 (live)
- Escopo do YouTube na API exige verificação do app pela Google para uso público; há cota diária de API.

## Fase 6 (patrocinados)
- Publicidade identificada no Brasil: conferir o Código de Defesa do Consumidor e as orientações do CONAR.
- Regras de anúncios da Play Store.
