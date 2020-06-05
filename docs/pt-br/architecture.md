# Architecture

![Bloc Architecture](../assets/bloc_architecture.png)

O uso do Bloc nos permite separar nosso aplicativo em três camadas:

- Apresentação
- Lógica de Negócio
- Dados
  - Repositório
  - Provedor de Dados

Vamos começar na camada de nível mais baixo (o mais distante da interface do usuário) e seguir até a camada de apresentação.

## Camada de Dados

> A responsabilidade da camadas de dados é recuperar / manipular dados de uma ou mais fontes.

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

## Camada Bloc (Lógica de Negócio)

> A responsabilidade da camada de bloc é responder a eventos da camada de apresentação com novos estados. A camada de bloc pode depender de um ou mais repositórios para recuperar dados necessários para construir o estado do aplicativo.

Pense na camada de bloc como a ponte entre a interface do usuário (camada de apresentação) e a camada de dados. A camada de bloc pega os eventos gerados pela entrada do usuário e depois se comunica com o repositório para criar um novo estado para a camada de apresentação consumir.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Comunicação entre Blocs

> Todo bloc tem um fluxo de estado no qual outros blocs podem se inscrever para reagir às mudanças dentro do bloc.

Os blocs podem ter dependências de outros blocs para reagir às mudanças de estado. No exemplo a seguir, `MyBloc` depende de `OtherBloc` e pode `adicionar` eventos em resposta a alterações de estado em `OtherBloc`. O `StreamSubscription` é fechado na instrução `close` no `MyBloc`, a fim de evitar vazamentos de memória.

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## Camada de Apresentação

> A responsabilidade da camada de apresentação é descobrir como se renderizar com base em um ou mais estados do bloc. Além disso, ela deve lidar com a entrada do usuário e os eventos do ciclo de vida do aplicativo.

A maioria dos fluxos de aplicativos começará com um evento `AppStart` que aciona o aplicativo para buscar alguns dados para apresentar ao usuário.

Nesse cenário, a camada de apresentação adicionaria um evento `AppStart`.

Além disso, a camada de apresentação terá que descobrir o que renderizar na tela com base no estado da camada do bloc.

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

Até agora, apesar de termos alguns trechos de código, tudo isso tem sido de alto nível. Na seção do tutorial, vamos juntar tudo isso à medida que criamos vários aplicativos de exemplo diferentes.
