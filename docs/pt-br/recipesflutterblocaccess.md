# Receita: Acesso ao Bloc

> Nesta receita, veremos como usar o BlocProvider para tornar um bloc acessível em toda a árvore de widgets. Vamos explorar três cenários: acesso local, acesso à rota e acesso global.

## Accesso Local

> Neste exemplo, vamos usar o BlocProvider para disponibilizar um bloc para uma subárvore local. Nesse contexto, local significa dentro de um contexto em que não há rotas sendo empurradas / estouradas.

### Bloc

Por uma questão de simplicidade, usaremos um `Counter` como nosso aplicativo de exemplo.

Nossa implementação do `CounterBloc` será parecida com:

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

### UI

Teremos três partes em nossa interface do usuário:

- App: o widget do aplicativo raiz
- CounterPage: o widget Container que gerencia o `CounterBloc` e expõe o` FloatingActionButtons` ao `incremento` e `decrementa` o contador.
- CounterText: um widget de texto responsável por exibir a contagem atual.

#### App

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider(
        create: (BuildContext context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

Nosso widget `App` é um `StatelessWidget` que usa um `MaterialApp` e define nosso` CounterPage` como o widget inicial. O widget `App` é responsável por criar e fechar o `CounterBloc`, além de disponibilizá-lo à `CounterPage` usando um `BlocProvider`.

?>**Nota:** Quando envolvemos um widget com `BlocProvider`, podemos fornecer um bloc para todos os widgets dentro dessa subárvore. Nesse caso, podemos acessar o `CounterBloc` de dentro do widget `CounterPage` e quaisquer filhos do widget `CounterPage` usando o `BlocProvider.of <CounterBloc> (context)`.

#### CounterPage

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: CounterText(),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

O widget `CounterPage` é um` StatelessWidget` que acessa o `CounterBloc` através do` BuildContext`.

#### CounterText

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) {
        return Text('$count');
      },
    );
  }
}
```

Nosso widget `CounterText` está usando um `BlocBuilder` para se reconstruir sempre que o estado do `CounterBloc` mudar. Utilizamos `BlocProvider.of <CounterBloc> (context)` para acessar o CounterBloc fornecido e retornar um widget `Text` com a contagem atual.

Isso envolve a parte de acesso ao bloc local desta receita e o código fonte completo pode ser encontrado [aqui](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

A seguir, veremos como fornecer um bloc em várias páginas / rotas.

## Accesso a Rota

> Neste exemplo, vamos usar o `BlocProvider` para acessar um bloc através das rotas. Quando uma nova rota é adicionada, ela terá um `BuildContext` diferente, que não possui mais uma referência aos blocs fornecidos anteriormente. Como resultado, temos que agrupar a nova rota em um `BlocProvider` separado.

### Bloc

Novamente, vamos usar o `CounterBloc` para simplificar.

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

### UI

Novamente, teremos três partes na interface do usuário do nosso aplicativo:

- App: o widget do aplicativo raiz
- HomePage: o widget Container que gerencia o `CounterBloc` e expõe o `FloatingActionButtons` ao `incremento` e `decrementa` o contador.
- CounterPage: um widget responsável por exibir a `contagem atual` como uma rota separada.

#### App

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider(
        create: (BuildContext context) => CounterBloc(),
        child: HomePage(),
      ),
    );
  }
}
```

Novamente, nosso widget `App` é o mesmo de antes.

#### HomePage

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<CounterPage>(
                builder: (context) {
                  return BlocProvider.value(
                    value: counterBloc,
                    child: CounterPage(),
                  );
                },
              ),
            );
          },
          child: Text('Counter'),
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              heroTag: 0,
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              heroTag: 1,
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

A `HomePage` é semelhante à `CounterPage` no exemplo acima; no entanto, em vez de renderizar um widget `CounterText`, ele renderiza um `RaisedButton` no centro, o que permite ao usuário navegar para uma nova tela que exibe a contagem atual.

Quando o usuário toca no `RaisedButton`, adicionamos uma nova `MaterialPageRoute` e retornamos o `CounterPage`; no entanto, estamos agrupando o `CounterPage` em um `BlocProvider` para disponibilizar a instância atual do `CounterBloc` na próxima página.

!> É fundamental que estejamos usando o construtor de valor do `BlocProvider` neste caso, porque estamos fornecendo uma instância existente do `CounterBloc`. O construtor de valor do `BlocProvider` deve ser usado apenas nos casos em que desejamos fornecer um bloc existente para uma nova subárvore. Além disso, o uso do construtor value não fechará o bloc automaticamente, o que, neste caso, é o que queremos (já que ainda precisamos do `CounterBloc` para funcionar nos widgets ancestrais). Em vez disso, simplesmente passamos o `CounterBloc` existente para a nova página como um valor existente, em oposição a um construtor. Isso garante que o único `BlocProvider` de nível superior lide com o fechamento do `CounterBloc` quando não for mais necessário.

#### CounterPage

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text('$count'),
          );
        },
      ),
    );
  }
}
```

O `CounterPage` é um `StatelessWidget` super super simples que usa o `BlocBuilder` para renderizar novamente um widget `Text` com a contagem atual. Assim como antes, somos capazes de usar o `BlocProvider.of <CounterBloc> (context)` para acessar o `CounterBloc`.

É tudo o que existe neste exemplo e a fonte completa pode ser encontrada [aqui](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

Por fim, veremos como disponibilizar globalmente um bloc para a árvore de widgets.

## Accesso Global

> Neste último exemplo, demonstraremos como disponibilizar uma instância de bloc para toda a árvore de widgets. Isso é útil para casos específicos como um `AuthenticationBloc` ou` ThemeBloc` porque esses estados se aplicam a todas as partes do aplicativo.

### Bloc

Como sempre, vamos usar o `CounterBloc` como nosso exemplo de simplicidade.

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

### UI

Vamos seguir a mesma estrutura de aplicativo do exemplo "Acesso local". Como resultado, teremos três partes em nossa interface:

- App: o widget do aplicativo raiz que gerencia a instância global do nosso `CounterBloc`.
- CounterPage: o widget Container que expõe `FloatingActionButtons` para `incrementar` e `decrementar` o contador.
- CounterText: um widget de texto responsável por exibir a contagem atual.

#### App

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        home: CounterPage(),
      ),
    );
  }
}
```

Assim como no exemplo de acesso local acima, o `App` gerencia criando, fechando e fornecendo o `CounterBloc` para a subárvore usando o `BlocProvider`. A principal diferença está neste caso, `MaterialApp` é filho do `BlocProvider`.

Envolvendo todo o `MaterialApp` em um `BlocProvider` é a chave para tornar nossa instância do `CounterBloc` acessível globalmente. Agora podemos acessar nosso `CounterBloc` de qualquer lugar em nosso aplicativo, onde temos um `BuildContext` usando `BlocProvider.of <CounterBloc> (context);`

?> **Nota:** Essa abordagem ainda funciona se você estiver usando um `CupertinoApp` ou `WidgetsApp`.

#### CounterPage

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: CounterText(),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

Nosso `CounterPage` é um `StatelessWidget` porque não precisa gerenciar nada do seu próprio estado. Assim como mencionamos acima, ele usa o `BlocProvider.of <CounterBloc> (context)` para acessar a instância global do `CounterBloc`.

#### CounterText

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) {
        return Text('$count');
      },
    );
  }
}
```

Nada de novo aqui; o widget `CounterText` é o mesmo que no primeiro exemplo. É apenas um `StatelessWidget` que usa um `BlocBuilder` para renderizar novamente quando o estado do `CounterBloc` muda e acessa a instância global do `CounterBloc` usando o `BlocProvider.of <CounterBloc> (context)`.

Isso é tudo! O código fonte completo pode ser encontrado [aqui](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).
