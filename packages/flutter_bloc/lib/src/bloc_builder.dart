import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template flutter_bloc.bloc_builder.bloc_widget_builder}
/// Signature for the builder function which takes the [BuildContext] and state
/// and is responsible for returning a [Widget] which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
/// {@endtemplate}
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the condition function which takes the previous state and the current state
/// and is responsible for returning a `bool` which determines whether or not to rebuild
/// [BlocBuilder] with the current state.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

class BlocBuilder<B extends Bloc<dynamic, S>, S> extends BlocBuilderBase<B, S> {
  /// {@template flutter_bloc.bloc_builder.builder}
  /// The `builder` function which will be invoked on each widget build.
  /// The `builder` takes the [BuildContext] and current bloc state and
  /// must return a [Widget].
  /// This is analogous to the `builder` function in [StreamBuilder].
  /// {@endtemplate}
  final BlocWidgetBuilder<S> builder;

  /// {@template flutter_bloc.bloc_builder.constructor}
  /// [BlocBuilder] handles building a widget in response to new states.
  /// [BlocBuilder] is analogous to [StreamBuilder] but has simplified API
  /// to reduce the amount of boilerplate code needed as well as bloc-specific performance improvements.

  /// Please refer to [BlocListener] if you want to "do" anything in response to state changes such as
  /// navigation, showing a dialog, etc...
  ///
  /// If the bloc parameter is omitted, [BlocBuilder] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  ///
  /// ```dart
  /// BlocBuilder<BlocA, BlocAState>(
  ///   builder: (context, state) {
  ///   // return widget here based on BlocA's state
  ///   }
  /// )
  /// ```
  ///
  /// Only specify the bloc if you wish to provide a bloc that is otherwise
  /// not accessible via [BlocProvider] and the current [BuildContext].
  ///
  /// ```dart
  /// BlocBuilder<BlocA, BlocAState>(
  ///   bloc: blocA,
  ///   builder: (context, state) {
  ///   // return widget here based on BlocA's state
  ///   }
  /// )
  /// ```
  ///
  /// An optional `condition` can be implemented for more granular control
  /// over how often [BlocBuilder] rebuilds.
  /// The `condition` function will be invoked on each bloc state change.
  /// The `condition` takes the previous state and current state and must return a `bool`
  /// which determines whether or not the `builder` function will be invoked.
  /// The previous state will be initialized to `currentState` when the [BlocBuilder] is initialized.
  /// `condition` is optional and if it isn't implemented, it will default to return `true`.
  ///
  /// ```dart
  /// BlocBuilder<BlocA, BlocAState>(
  ///   condition: (previousState, currentState) {
  ///     // return true/false to determine whether or not
  ///     // to rebuild the widget with currentState
  ///   },
  ///   builder: (context, state) {
  ///     // return widget here based on BlocA's state
  ///   }
  ///)
  /// ```
  /// {@endtemplate}
  const BlocBuilder({
    Key key,
    @required this.builder,
    B bloc,
    BlocBuilderCondition<S> condition,
  })  : assert(builder != null),
        super(key: key, bloc: bloc, condition: condition);

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder2<StateA, StateB> = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
);

class BlocBuilder2<BlocA extends Bloc<dynamic, StateA>, StateA,
    BlocB extends Bloc<dynamic, StateB>, StateB> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder2<StateA, StateB> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@macro flutter_bloc.bloc_builder.constructor}
  const BlocBuilder2({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.blocA,
    this.blocB,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocA, StateA>(
      bloc: blocA,
      condition: conditionA,
      builder: (_, stateA) => BlocBuilder<BlocB, StateB>(
        bloc: blocB,
        condition: conditionB,
        builder: (_, stateB) => builder(context, stateA, stateB),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder3<StateA, StateB, StateC> = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
);

class BlocBuilder3<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder3<StateA, StateB, StateC> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder3({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.blocA,
    this.blocB,
    this.blocC,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder2<BlocA, StateA, BlocB, StateB>(
      blocA: blocA,
      blocB: blocB,
      conditionA: conditionA,
      conditionB: conditionB,
      builder: (_, stateA, stateB) => BlocBuilder<BlocC, StateC>(
        bloc: blocC,
        condition: conditionC,
        builder: (_, stateC) => builder(context, stateA, stateB, stateC),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder4<StateA, StateB, StateC, StateD> = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
  StateD stateD,
);

class BlocBuilder4<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC,
    BlocD extends Bloc<dynamic, StateD>,
    StateD> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder4<StateA, StateB, StateC, StateD> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateD> conditionD;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocD blocD;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder4({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.conditionD,
    this.blocA,
    this.blocB,
    this.blocC,
    this.blocD,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder3<BlocA, StateA, BlocB, StateB, BlocC, StateC>(
      blocA: blocA,
      blocB: blocB,
      blocC: blocC,
      conditionA: conditionA,
      conditionB: conditionB,
      conditionC: conditionC,
      builder: (_, stateA, stateB, stateC) => BlocBuilder<BlocD, StateD>(
        bloc: blocD,
        condition: conditionD,
        builder: (_, stateD) =>
            builder(context, stateA, stateB, stateC, stateD),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder5<StateA, StateB, StateC, StateD, StateE> = Widget
    Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
  StateD stateD,
  StateE stateE,
);

class BlocBuilder5<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC,
    BlocD extends Bloc<dynamic, StateD>,
    StateD,
    BlocE extends Bloc<dynamic, StateE>,
    StateE> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder5<StateA, StateB, StateC, StateD, StateE> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateD> conditionD;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateE> conditionE;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocD blocD;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocE blocE;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder5({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.conditionD,
    this.conditionE,
    this.blocA,
    this.blocB,
    this.blocC,
    this.blocD,
    this.blocE,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder4<BlocA, StateA, BlocB, StateB, BlocC, StateC, BlocD,
        StateD>(
      blocA: blocA,
      blocB: blocB,
      blocC: blocC,
      blocD: blocD,
      conditionA: conditionA,
      conditionB: conditionB,
      conditionC: conditionC,
      conditionD: conditionD,
      builder: (_, stateA, stateB, stateC, stateD) =>
          BlocBuilder<BlocE, StateE>(
        bloc: blocE,
        condition: conditionE,
        builder: (_, stateE) =>
            builder(context, stateA, stateB, stateC, stateD, stateE),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder6<StateA, StateB, StateC, StateD, StateE, StateF>
    = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
  StateD stateD,
  StateE stateE,
  StateF stateF,
);

class BlocBuilder6<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC,
    BlocD extends Bloc<dynamic, StateD>,
    StateD,
    BlocE extends Bloc<dynamic, StateE>,
    StateE,
    BlocF extends Bloc<dynamic, StateF>,
    StateF> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder6<StateA, StateB, StateC, StateD, StateE, StateF>
      builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateD> conditionD;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateE> conditionE;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateF> conditionF;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocD blocD;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocE blocE;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocF blocF;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder6({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.conditionD,
    this.conditionE,
    this.conditionF,
    this.blocA,
    this.blocB,
    this.blocC,
    this.blocD,
    this.blocE,
    this.blocF,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder5<BlocA, StateA, BlocB, StateB, BlocC, StateC, BlocD,
        StateD, BlocE, StateE>(
      blocA: blocA,
      blocB: blocB,
      blocC: blocC,
      blocD: blocD,
      blocE: blocE,
      conditionA: conditionA,
      conditionB: conditionB,
      conditionC: conditionC,
      conditionD: conditionD,
      conditionE: conditionE,
      builder: (_, stateA, stateB, stateC, stateD, stateE) =>
          BlocBuilder<BlocF, StateF>(
        bloc: blocF,
        condition: conditionF,
        builder: (_, stateF) =>
            builder(context, stateA, stateB, stateC, stateD, stateE, stateF),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder7<StateA, StateB, StateC, StateD, StateE, StateF,
        StateG>
    = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
  StateD stateD,
  StateE stateE,
  StateF stateF,
  StateG stateG,
);

class BlocBuilder7<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC,
    BlocD extends Bloc<dynamic, StateD>,
    StateD,
    BlocE extends Bloc<dynamic, StateE>,
    StateE,
    BlocF extends Bloc<dynamic, StateF>,
    StateF,
    BlocG extends Bloc<dynamic, StateG>,
    StateG> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder7<StateA, StateB, StateC, StateD, StateE, StateF,
      StateG> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateD> conditionD;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateE> conditionE;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateF> conditionF;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateG> conditionG;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocD blocD;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocE blocE;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocF blocF;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocG blocG;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder7({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.conditionD,
    this.conditionE,
    this.conditionF,
    this.conditionG,
    this.blocA,
    this.blocB,
    this.blocC,
    this.blocD,
    this.blocE,
    this.blocF,
    this.blocG,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder6<BlocA, StateA, BlocB, StateB, BlocC, StateC, BlocD,
        StateD, BlocE, StateE, BlocF, StateF>(
      blocA: blocA,
      blocB: blocB,
      blocC: blocC,
      blocD: blocD,
      blocE: blocE,
      blocF: blocF,
      conditionA: conditionA,
      conditionB: conditionB,
      conditionC: conditionC,
      conditionD: conditionD,
      conditionE: conditionE,
      conditionF: conditionF,
      builder: (_, stateA, stateB, stateC, stateD, stateE, stateF) =>
          BlocBuilder<BlocG, StateG>(
        bloc: blocG,
        condition: conditionG,
        builder: (_, stateG) => builder(
            context, stateA, stateB, stateC, stateD, stateE, stateF, stateG),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder8<StateA, StateB, StateC, StateD, StateE, StateF,
        StateG, StateH>
    = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
  StateD stateD,
  StateE stateE,
  StateF stateF,
  StateG stateG,
  StateH stateH,
);

class BlocBuilder8<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC,
    BlocD extends Bloc<dynamic, StateD>,
    StateD,
    BlocE extends Bloc<dynamic, StateE>,
    StateE,
    BlocF extends Bloc<dynamic, StateF>,
    StateF,
    BlocG extends Bloc<dynamic, StateG>,
    StateG,
    BlocH extends Bloc<dynamic, StateH>,
    StateH> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder8<StateA, StateB, StateC, StateD, StateE, StateF,
      StateG, StateH> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateD> conditionD;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateE> conditionE;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateF> conditionF;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateG> conditionG;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateH> conditionH;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocD blocD;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocE blocE;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocF blocF;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocG blocG;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocH blocH;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder8({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.conditionD,
    this.conditionE,
    this.conditionF,
    this.conditionG,
    this.conditionH,
    this.blocA,
    this.blocB,
    this.blocC,
    this.blocD,
    this.blocE,
    this.blocF,
    this.blocG,
    this.blocH,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder7<BlocA, StateA, BlocB, StateB, BlocC, StateC, BlocD,
        StateD, BlocE, StateE, BlocF, StateF, BlocG, StateG>(
      blocA: blocA,
      blocB: blocB,
      blocC: blocC,
      blocD: blocD,
      blocE: blocE,
      blocF: blocF,
      blocG: blocG,
      conditionA: conditionA,
      conditionB: conditionB,
      conditionC: conditionC,
      conditionD: conditionD,
      conditionE: conditionE,
      conditionF: conditionF,
      conditionG: conditionG,
      builder: (_, stateA, stateB, stateC, stateD, stateE, stateF, stateG) =>
          BlocBuilder<BlocH, StateH>(
        bloc: blocH,
        condition: conditionH,
        builder: (_, stateH) => builder(context, stateA, stateB, stateC, stateD,
            stateE, stateF, stateG, stateH),
      ),
    );
  }
}

/// {@macro flutter_bloc.bloc_builder.bloc_widget_builder}
typedef BlocWidgetBuilder9<StateA, StateB, StateC, StateD, StateE, StateF,
        StateG, StateH, StateI>
    = Widget Function(
  BuildContext context,
  StateA stateA,
  StateB stateB,
  StateC stateC,
  StateD stateD,
  StateE stateE,
  StateF stateF,
  StateG stateG,
  StateH stateH,
  StateI stateI,
);

class BlocBuilder9<
    BlocA extends Bloc<dynamic, StateA>,
    StateA,
    BlocB extends Bloc<dynamic, StateB>,
    StateB,
    BlocC extends Bloc<dynamic, StateC>,
    StateC,
    BlocD extends Bloc<dynamic, StateD>,
    StateD,
    BlocE extends Bloc<dynamic, StateE>,
    StateE,
    BlocF extends Bloc<dynamic, StateF>,
    StateF,
    BlocG extends Bloc<dynamic, StateG>,
    StateG,
    BlocH extends Bloc<dynamic, StateH>,
    StateH,
    BlocI extends Bloc<dynamic, StateI>,
    StateI> extends StatelessWidget {
  /// {@macro flutter_bloc.bloc_builder.builder}
  final BlocWidgetBuilder9<StateA, StateB, StateC, StateD, StateE, StateF,
      StateG, StateH, StateI> builder;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateA> conditionA;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateB> conditionB;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateC> conditionC;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateD> conditionD;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateE> conditionE;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateF> conditionF;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateG> conditionG;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateH> conditionH;

  /// {@macro flutter_bloc.bloc_builder.bloc_builder_condition}
  final BlocBuilderCondition<StateI> conditionI;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocA blocA;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocB blocB;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocC blocC;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocD blocD;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocE blocE;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocF blocF;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocG blocG;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocH blocH;

  /// {@template flutter_bloc.bloc_builder.bloc}
  final BlocI blocI;

  /// {@template flutter_bloc.bloc_builder.constructor}
  const BlocBuilder9({
    @required this.builder,
    this.conditionA,
    this.conditionB,
    this.conditionC,
    this.conditionD,
    this.conditionE,
    this.conditionF,
    this.conditionG,
    this.conditionH,
    this.conditionI,
    this.blocA,
    this.blocB,
    this.blocC,
    this.blocD,
    this.blocE,
    this.blocF,
    this.blocG,
    this.blocH,
    this.blocI,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder8<BlocA, StateA, BlocB, StateB, BlocC, StateC, BlocD,
        StateD, BlocE, StateE, BlocF, StateF, BlocG, StateG, BlocH, StateH>(
      blocA: blocA,
      blocB: blocB,
      blocC: blocC,
      blocD: blocD,
      blocE: blocE,
      blocF: blocF,
      blocG: blocG,
      blocH: blocH,
      conditionA: conditionA,
      conditionB: conditionB,
      conditionC: conditionC,
      conditionD: conditionD,
      conditionE: conditionE,
      conditionF: conditionF,
      conditionG: conditionG,
      conditionH: conditionH,
      builder:
          (_, stateA, stateB, stateC, stateD, stateE, stateF, stateG, stateH) =>
              BlocBuilder<BlocI, StateI>(
        bloc: blocI,
        condition: conditionI,
        builder: (_, stateI) => builder(context, stateA, stateB, stateC, stateD,
            stateE, stateF, stateG, stateH, stateI),
      ),
    );
  }
}

abstract class BlocBuilderBase<B extends Bloc<dynamic, S>, S>
    extends StatefulWidget {
  /// Base class for widgets that build themselves based on interaction with
  /// a specified [Bloc].
  ///
  /// A [BlocBuilderBase] is stateful and maintains the state of the interaction
  /// so far. The type of the state and how it is updated with each interaction
  /// is defined by sub-classes.
  const BlocBuilderBase({Key key, this.bloc, this.condition}) : super(key: key);

  /// {@template flutter_bloc.bloc_builder.bloc}
  /// The [Bloc] that the [BlocBuilderBase] will interact with.
  /// If omitted, [BlocBuilderBase] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  /// {@endtemplate}
  final B bloc;

  /// {@template flutter_bloc.bloc_builder.bloc_builder_condition}
  /// The [BlocBuilderCondition] that the [BlocBuilderBase] will invoke.
  /// The `condition` function will be invoked on each bloc state change.
  /// The `condition` takes the previous state and current state and must return a `bool`
  /// which determines whether or not the `builder` function will be invoked.
  /// The previous state will be initialized to `currentState` when the [BlocBuilderBase] is initialized.
  /// `condition` is optional and if it isn't implemented, it will default to return `true`.
  /// {@endtemplate}
  final BlocBuilderCondition<S> condition;

  /// Returns a [Widget] based on the [BuildContext] and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<B, S>> createState() => _BlocBuilderBaseState<B, S>();
}

class _BlocBuilderBaseState<B extends Bloc<dynamic, S>, S>
    extends State<BlocBuilderBase<B, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  S _state;
  B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? BlocProvider.of<B>(context);
    _previousState = _bloc?.currentState;
    _state = _bloc?.currentState;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocBuilderBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Stream<S> oldState =
        oldWidget.bloc?.state ?? BlocProvider.of<B>(context).state;
    final Stream<S> currentState = widget.bloc?.state ?? oldState;
    if (oldState != currentState) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = widget.bloc ?? BlocProvider.of<B>(context);
        _previousState = _bloc?.currentState;
        _state = _bloc?.currentState;
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_bloc?.state != null) {
      _subscription = _bloc.state.skip(1).listen((S state) {
        if (widget.condition?.call(_previousState, state) ?? true) {
          setState(() {
            _state = state;
          });
        }
        _previousState = state;
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
