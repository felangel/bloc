# Architetura

![Architetura Bloc](../assets/bloc_architecture_full.png)

O uso do Bloc nos permite separar nosso aplicativo em três camadas:

- Apresentação
- Lógica de Negócio
- Dados
  - Repositório
  - Provedor de Dados

Vamos começar na camada de nível mais baixo (o mais distante da interface do usuário) e seguir até a camada de apresentação.

## Camada de Dados

> A responsabilidade da camadas de dados é recuperar/manipular dados de uma ou mais fontes.

A camada de dados pode ser dividida em duas partes:

- Repositório
- Provedor de Dados

Essa camada é o nível mais baixo do aplicativo e interage com bancos de dados, solicitações de rede e outras fontes de dados assíncronas.

### Provedor de Dados

> A responsabilidade da camada provedora de dados é fornecer dados brutos. O provedor de dados deve ser genérico e versátil.

A camada provedora de dados geralmente expõe APIs simples para executar operações [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete).
Podemos ter métodos `createData`, `readData`, `updateData` e `deleteData` como parte de nossa camada de dados.

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repositório

> A camada de repositório é um invólucro em torno de um ou mais provedores de dados com os quais a camada de bloc se comunica.

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

Como você pode ver, nossa camada de repositório pode interagir com vários provedores de dados e realizar transformações nos dados antes de entregar o resultado à camada de lógica de negócios.

## Camada de Lógica de Negócios

> A responsabilidade da camada de lógica de negócios é responder a eventos da camada de apresentação com novos estados. Essa camada pode depender de um ou mais repositórios para recuperar os dados necessários para construir o estado do aplicativo.

Pense na camada de lógica de negócios como a ponte entre a interface do usuário (camada de apresentação) e a camada de dados. A camada de lógica de negócios é notificada sobre eventos/ações na camada de apresentação e então se comunica com o repositório para criar um novo estado para a camada de apresentação consumir.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Comunicação entre Blocs

Como os blocs expõem streams, pode ser tentador fazer com que um bloc escute outro bloc. Você **não** deve fazer isso. Existem alternativas melhores do que recorrer ao código abaixo:

[do_not_do_this_at_home.dart](../_snippets/architecture/do_not_do_this_at_home.dart.md ':include')

Embora o código acima esteja livre de erros (e até mesmo se auto finalize), ele tem um grande problema: ele cria uma dependência entre dois blocs.

Geralmente, dependências irmãs entre duas entidades na mesma camada de arquitetura devem ser evitadas a todo custo, pois isso cria um forte acoplamento que é difícil de manter. Como os blocs residem na camada de arquitetura da lógica de negócios, nenhum bloc deve saber sobre qualquer outro bloc.

![Camadas de Arquitetura de Aplicativos](../assets/architecture.png)

Um bloc só deve receber informações por meio de eventos e de repositórios injetados (ou seja, repositórios passados ao bloc em seu construtor).

Se você estiver em uma situação em que um bloc precisa responder a outro bloc, você tem duas outras opções. Você pode enviar o problema para uma camada acima (para a camada de apresentação) ou para uma camada abaixo (para a camada de domínio).

#### Conectando Blocs através da Apresentação

Você pode usar um `BlocListener` para ouvir um bloc e adicionar um evento a outro bloc sempre que o primeiro bloc mudar.

[blocs_presentation.dart.md](../_snippets/architecture/blocs_presentation.dart.md ':include')

O código acima evita que o `SecondBloc` precise saber sobre o `FirstBloc`, encorajando o acoplamento solto. O aplicativo [flutter_weather](flutterweathertutorial.md) usa [esta técnica](https://github.com/felangel/bloc/blob/b4c8db938ad71a6b60d4a641ec357905095c3965/examples/flutter_weather/lib/weather/view/weather_page.dart#L38-L42) para alterar o tema do aplicativo com base nas informações meteorológicas recebidas.

Em algumas situações, talvez você não queira acoplar dois blocs na camada de apresentação. Em vez disso, muitas vezes pode fazer sentido que dois blocs compartilhem a mesma fonte de dados e atualizem sempre que os dados forem alterados.

#### Conectando Blocs através do Domínio

Dois blocs podem ouvir um stream de um repositório e atualizar seus estados independentemente um do outro sempre que os dados do repositório forem alterados. O uso de repositórios reativos para manter o estado sincronizado é comum em aplicativos corporativos de grande escala.

Primeiro, crie ou use um repositório que forneça um `Stream` de dados. Por exemplo, o repositório a seguir expõe um stream interminável das mesmas poucas ideias de aplicativos:

[app_ideas_repo.dart.md](../_snippets/architecture/app_ideas_repo.dart.md ':include')

O mesmo repositório pode ser injetado em cada bloc que precisa reagir a novas ideias de aplicativos. Abaixo está um `AppIdeaRankingBloc` que produz um estado para cada ideia de aplicativo recebida do repositório acima:

[blocs_domain.dart.md](../_snippets/architecture/blocs_domain.dart.md ':include')

Para saber mais sobre como usar streams com Bloc, consulte [Como usar Bloc com streams e concorrência](https://verygood.ventures/blog/how-to-use-bloc-with-streams-and-concurrency).

## Camada de Apresentação

> A responsabilidade da camada de apresentação é descobrir como se renderizar com base em um ou mais estados do bloc. Além disso, ela deve lidar com a entrada do usuário e os eventos do ciclo de vida do aplicativo.

A maioria dos fluxos de aplicativos começará com um evento `AppStart` que aciona o aplicativo para buscar alguns dados para apresentar ao usuário.

Nesse cenário, a camada de apresentação adicionaria um evento `AppStart`.

Além disso, a camada de apresentação terá que descobrir o que renderizar na tela com base no estado da camada do bloc.

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

Até agora, apesar de termos alguns trechos de código, tudo isso tem sido de alto nível. Na seção do tutorial, vamos juntar tudo isso à medida que criamos vários aplicativos de exemplo diferentes.
