# Receitas: Exibir SnackBar com o BlocListener

> Nesta receita, veremos como usar o `BlocListener` para exibir um `SnackBar` em resposta a uma alteração de estado em um bloc.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

Vamos construir um `DataBloc` básico que manipulará o `DataEvents` e produzirá o `DataStates`.

### DataEvent

Para ficar mais simples, nosso `DataBloc` responderá apenas a um único `DataEvent` chamado `FetchData`.

[data_event.dart](../_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### DataState

Nosso `DataBloc` pode ter entre um e três `DataStates` diferentes:

- `Inicial` - o estado inicial antes de adicionar um evento
- `Loading` - o estado do Bloc enquanto ele está "buscando dados de forma assíncrona"
- `Success` - o estado do Bloc quando ele "buscou dados" com sucesso

[data_state.dart](../_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### DataBloc

Nosso `DataBloc` deve ficar assim:

[data_bloc.dart](../_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **Nota:** Nós estamos usando `Future.delayed` para simular a latência.

## UI Layer

Agora vamos dar uma olhada em como conectar nosso `DataBloc` a um widget e mostrar um `SnackBar` como resposta a um estado de sucesso.

[main.dart](../_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> Nós usamos o widget `BlocListener` para **FAZER AS COISAS** como resposta as alterações de estado em nosso `DataBloc`.

?> Nós usamos o widget `BlocBuilder` para **RENDERIZAR OS WIDGETS** como resposta as mudanças de estado em nosso `DataBloc`.

!> **NUNCA** "fazemos as coisas" em resposta a alterações de estado no método `builder` do `BlocBuilder` porque esse método só pode ser chamado várias vezes pela estrutura do Flutter. O método `builder` deve ser uma [função pura](https://en.wikipedia.org/wiki/Pure_function) que retorna um widget como resposta ao estado do Bloc.

O código completo desta receita você encontra [aqui](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).
