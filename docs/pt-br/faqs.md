# Dúvidas Frequentes

## Estado não está atualizando

❔ **Dúvida**: Estou dando yield num estado no meu bloco, mas a interface do usuário não está atualizando. O que estou fazendo de errado?

💡 **Resposta**: Se você estiver usando o Equatable, certifique-se de passar todas as propriedades para o props getter.

✅ **BOM**

[my_state.dart](../_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **RUIM**

[my_state.dart](../_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](../_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

Além disso, verifique se você está dando yield numa nova instância do estado em seu bloco.

✅ **BOM**

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **RUIM**

[my_bloc.dart](../_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

## Quando usar Equatable

❔ **Pergunta**: Quando devo usar o Equatable?

💡 **Resposta**:

[my_bloc.dart](../_snippets/faqs/equatable_yield.dart.md ':include')

No cenário acima, se `StateA` estender `Equatable`, apenas uma alteração de estado ocorrerá (o segundo rebuild será ignorado).
Em geral, você deve usar o `Equatable` se quiser otimizar seu código para reduzir o número de reconstruções.
Você não deve usar o `Equatable` se desejar que o mesmo estado seja consecutivo para disparar várias transições.

Além disso, o uso de `Equatable` facilita muito o teste de blocos, já que podemos esperar instâncias específicas de estados de bloco em vez de usar `Matchers` ou `Predicates`.

[my_bloc_test.dart](../_snippets/faqs/equatable_bloc_test.dart.md ':include')

Sem o `Equatable`, o teste acima falharia e precisaria ser reescrito como:

[my_bloc_test.dart](../_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

## Bloc vs Redux

❔ **Pergunta**: Qual é a diferença entre Bloc e Redux?

💡 **Resposta**:

BLoC é um padrão de design definido pelas seguintes regras:

1. A entrada e saída do BLoC são fluxos e sumidouros simples.
2. As dependências devem ser injetáveis ​​e a Plataforma agnóstica.
3. Nenhuma ramificação de plataforma é permitida.
4. A implementação pode ser o que você quiser, desde que siga as regras acima.

As diretrizes da interface do usuário são:

1. Cada componente "suficientemente complexo" possui um BLoC correspondente.
2. Os componentes devem enviar entradas "como estão".
3. Os componentes devem mostrar as saídas o mais próximo possível de "como estão".
4. Todas as ramificações devem ser baseadas em saídas booleanas simples de BLoC.

A Biblioteca Bloc implementa o BLoC Design Pattern e visa abstrair o RxDart para simplificar a experiência do desenvolvedor.

Os três princípios do Redux são:

1. Fonte única da verdade
2. Estado é somente leitura
3. Alterações são feitas com funções puras

A biblioteca bloc viola o primeiro princípio; com o estado do bloco é distribuído por vários blocos.
Além disso, não há conceito de middleware no bloc e o bloc é projetado para facilitar muito as alterações de estado assíncronas, permitindo emitir vários estados para um único evento.

## Bloc vs Provider

❔ **Pergunta**: Qual é a diferença entre Bloc e Provider?

💡 **Resposta**: O `provider` é projetado para injeção de dependência (envolve o` InheritedWidget`).
Você ainda precisa descobrir como gerenciar seu estado (via `ChangeNotifier`,`Bloc`, `Mobx`, etc ...).
A Biblioteca de Blocs usa o `provedor` internamente para facilitar o fornecimento e o acesso aos blocos em toda a árvore de widgets.

## Navegação com Bloc

❔ **Pergunta**: Como faço para navegar com o Bloc?

💡 **Resposta**: Confira https://bloclibrary.dev/#/recipesflutternavigation

## BlocProvider.of() não encontra o bloco

❔ **Pergunta**: Ao usar o `BlocProvider.of(context)`, ele não pode encontrar o bloco. Como posso consertar isso?

💡 **Resposta**: Você não pode acessar um bloc no mesmo contexto em que ele foi fornecido, portanto, você deve garantir que `BlocProvider.of()` seja chamado dentro de um filho `BuildContext`.

✅ **BOM**

[my_page.dart](../_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](../_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **RUIM**

[my_page.dart](../_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## Estrutura de projeto

❔ **Pergunta**: Como devo estruturar meu projeto?

💡 **Resposta**: Embora não haja realmente uma resposta certa/errada para esta pergunta, algumas referências recomendadas são:

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

O mais importante é ter uma estrutura de projeto **consistente** e **intencional**.
