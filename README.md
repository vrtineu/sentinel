# Sentinel

Sentinel é uma aplicação de monitoramento de câmeras de segurança que envia notificações por email.

## Como executar

Requisitos:

- Erlang/OTP (Utilizei a versão 26.2)
- Elixir (Utilizei a versão 1.16)
- Phoenix (Utilizei a versão 1.7)
- Docker
- Postgres (Utilizei a versão latest da imagem docker)

Para executar o projeto, siga os passos:

1. Instale as dependências com:

```sh
mix deps.get
```

2. Execute o comando Docker para subir o banco de dados para testes/desenvolvimento:

```sh
docker run -d --name sentinel_db -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=postgres  postgres
```

3. Execute o comando para criar o banco de dados, rodar as migrations e seedar o banco:

```sh
mix ecto.setup
```

4. Inicie o servidor Phoenix com:

```sh
iex -S mix phx.server
```

## Como utilizar/testar

Com o servidor rodando, você pode acessar a interface GraphQL em `http://localhost:4000/api/graphiql` e testar as queries e mutations disponíveis.

Você também pode utilizar a rota `http://localhost:4000/api` para fazer requisições GraphQL diretamente.

Para visualizar os emails enviados, acesse `http://localhost:4000/dev/mailbox`.

## Detalhes da implementação

### Decisões

- Optei por utilizar a estrutura de contextos sugerida pelo próprio framework Phoenix.
- Optei por utilizar GraphQL para a API, pois é uma tecnologia que tenho interesse em aprender melhor, até então tenho noções e conhecimentos básicos, e achei que seria uma boa oportunidade para praticar.
- Para recursos de usuários e câmeras, optei por implementar as operações básicas de CRUD, apesar de não disponibilizá-las para este teste.
- Para o recurso de alertas/notificações, optei por implementar alguns recursos para garantir resiliência e escalabilidade, neste contexto, acredito ser um recurso crítico devido a natureza do negócio. Recursos implementados:
  - Retentativas de envio de notificações em casos de falhas.
  - Dead letter queue para armazenar mensagens que não puderam ser entregues no momento para posterior processamento.
  - Circuit breaker para evitar sobrecarga do sistema que está enviando as notificações, uma vez que em um cenário de instabilidade, queremos que o sistema se recupere o mais rápido possível.
- Optei por não utilizar autênticação para este teste.
- Como solicitado, tentei fazer com que o script de seed seja performático, utilizando como base o módulo `Stream` e batch inserts.
- Como as associações entre os recursos são One-to-Many, me atentei para que não houvessem problemas de N+1 queries em nenhum momento.

### Limitações

- Acredito que poderia ter escrito mais documentações para os módulos e funções, tornando a manutenção e entendimento do código mais fácil para outros desenvolvedores.
- Acredito que poderia ter escrito mais testes para a aplicação, principalmente o módulo de notificações, mas devido ao tempo e a complexidade do módulo, optei por focar em outras partes da aplicação.
- Apesar de ter implementado algumas estratégias para garantir resiliência e escalabilidade, acredito que ainda há espaço para melhorias e otimizações utilizando outras tecnologias, como por exemplo, RabbitMQ ou Kafka para implementar a fila de notificações.
- Talvez em um cenário real, seria interessante implementar um sistema de logs mais robusto, para que seja possível rastrear e monitorar o envio de notificações.
- Acredito que se fosse preciso implementar os recursos de CRUD, tornando-os públicos, seria necessário fazer melhores validações de dados e implementar autenticação.

*Obs*: Acho importante ressaltar que todos os pontos de limitações citados acima são considerados por mim como oportunidades de melhorias futuras, e não como falhas no desenvolvimento do projeto.

## Testes manuais

É possível forçar erros no envio de notificações para testar o comportamento do sistema. Para isso, basta seguir os passos:

1. Alterar o arquivo `config/dev.exs` e substituir a seguinte configuração:

```diff
- config :sentinel, Sentinel.Mailer, adapter: Swoosh.Adapters.Local
+ config :sentinel, Sentinel.Mailer, adapter: Sentinel.Adapters.Postmark,
+   api_key: "fake_api_key"
```

2. Reiniciar o servidor Phoenix.

3. Fazer uma requisição GraphQL para criar um alerta. Ou utilizar o iex para criar um alerta manualmente, para um único alerta, onde a visualização é mais fácil.

```ex
iex> %{name: "John Doe", email: "dummy@mail.com", brand: "Hikvision"} |> Sentinel.Accounts.UserNotification.email_by_camera_brand() |> then(&Sentinel.Notifications.Email.send_bulk_emails([&1]))
```

Após realizar esses passos, o envio de notificações irá falhar e o comportamento do GenServer de envio de emails irá ser logado no terminal.

*Obs*: É possível alterar a configuração do sistema, como tempo e quantidade de retentativas. Para isso, basta alterar o arquivo `config/config.exs`.

*Obs 2*: Não esqueça de alterar a configuração de volta para o adapter local para que o envio de emails volte a funcionar corretamente.
