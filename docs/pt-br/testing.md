# Testing

> Bloc foi pensado para ser extremamente fácil de testar.

Prezando pela simplicidade, vamos escrever testes para o `CounterBloc` que criamos em [Conceitos Fundamentais](coreconcepts.md).

Relembrando, a implementação do `CounterBloc` é algo como:

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Antes de começarmos a escrever nossos testes precisamos adicionar um framework de teste nas dependências.

Precisamos adicionar [test](https://pub.dev/packages/test) e [bloc_test](https://pub.dev/packages/bloc_test) em nosso `pubspec.yaml`.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

Vamos começar criando o arquivo `counter_bloc_test.dart` para os nossos testes de `CounterBloc` e importanto o package test.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Agora, precisamos criar o nosso `main` e o nosso grupo de teste.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Nota**: grupos são para organizar testes individuais assim como criar um contexto em que é possível compartilhar `setUp` e `tearDown` com todos os testes individuais.

Vamos começar criando uma instância do nosso `CounterBloc` que será utilizado em todos os nossos testes.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Agora podemos começar a escrever nossos testes individuais.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Nota**: Podemos executar todos os nossos testes com o comando `pub run test`.

At this point we should have our first passing test! Now let's write a more complex test.

Nesse momento devemos ter o primeiro teste passando! Agora vamos escrever um teste mais complexo.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Agora devemos poder rodar os testes e ver que todos estão passando.

É só isso! Testar deve ser fácil e devemos ter confiança ao fazer mudanças e refatorar nosso código.
