# Testing

> Bloc foi pensado para ser extremamente fácil de testar.

Prezando pela simplicidade, vamos escrever testes para o `CounterBloc` que criamos em [Conceitos Fundamentais](coreconcepts.md).

Relembrando, a implementação do `CounterBloc` é algo como:

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

Antes de começarmos a escrever nossos testes precisamos adicionar um framework de teste nas dependências.

Precisamos adicionar [test](https://pub.dev/packages/test) em nosso `pubspec.yaml`.

```yaml
dev_dependencies:
  test: ">=1.3.0 <2.0.0"
```

Vamos começar criando o arquivo `counter_bloc_test.dart` para os nossos testes de `CounterBloc` e importanto o package test.

```dart
import 'package:test/test.dart';
```

Agora, precisamos criar o nosso `main` e o nosso grupo de teste.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **Nota**: grupos são para organizar testes individuais assim como criar um contexto em que é possível compartilhar `setUp` e `tearDown` com todos os testes individuais.

Vamos começar criando uma instância do nosso `CounterBloc` que será utilizado em todos os nossos testes.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Agora podemos começar a escrever nossos testes individuais.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
    });
});
```

?> **Nota**: Podemos executar todos os nossos testes com o comando `pub run test`.

At this point we should have our first passing test! Now let's write a more complex test.

Nesse momento devemos ter o primeiro teste passando! Agora vamos escrever um teste mais complexo.

```dart
test('single Increment event updates state to 1', () {
    final List<int> expected = [0, 1];

    expectLater(
        counterBloc,
        emitsInOrder(expected),
    );

    counterBloc.add(CounterEvent.increment);
});

test('single Decrement event updates state to -1', () {
    final List<int> expected = [0, -1];

    expectLater(
        counterBloc,
        emitsInOrder(expected),
    );

    counterBloc.add(CounterEvent.decrement);
});
```

Agora devemos poder rodar os testes e ver que todos estão passando.

É só isso! Testar deve ser fácil e devemos ter confiança ao fazer mudanças e refatorar nosso código.