import 'dart:async';

/// LinkedStateBloc is a bloc in which you can navigate between it's all
/// pervious and present states.
abstract class LinkedStateBloc<T, W extends Event> {
  /// LinkedStateBloc is a bloc in which you can navigate between it's all
  /// pervious and present states.
  LinkedStateBloc(T data, W event) : _state = NodeState<T, W>(data, event);

  /// The controller of LinkedStateBloc events.
  StreamController<NodeState<T, W>> _controller =
      StreamController<NodeState<T, W>>();

  /// The stream of State events.
  Stream<NodeState<T, W>> get stream => _controller.stream;

  /// The current event of the bloc.
  NodeState<T, W> _state;

  /// The current event of the bloc.
  NodeState<T, W> get state => _state;

  /// State length.
  int _length = 0;

  /// State events number.
  int get length => _length;

  /// Pop times.
  int _pops = 0;

  /// Pop times.
  int get pops => _pops;

  /// Can it pop?
  bool get canPop => _length > _pops;

  /// Can it go next?
  bool get canNext => _pops > 0;

  /// Emit event to the bloc.
  NodeState<T, W> emit(T data, W w) {
    var event = NodeState<T, W>(data, w);
    state.next = event;
    event.previous = state;
    _length = _length - _pops + 1;
    _pops = 0;
    _state = event;
    _controller.add(event);
    return event;
  }

  /// Pop event from the bloc.
  NodeState<T, W>? pop() {
    if (state.previous != null) {
      _controller.add(state.previous!);
      _pops++;
      return state;
    }
    return null;
  }

  /// Go to the next event of the linked list.
  NodeState<T, W>? next() {
    if (state.next != null) {
      _controller.add(state.next!);
      _pops--;
      return state;
    }
    return null;
  }

  /// Get the last state node.
  NodeState<T, W> last() {
    var local = state;
    while (local.next != null) {
      local = local.next!;
    }
    _controller.add(local);
    return local;
  }

  /// Get the first state node.
  NodeState<T, W> first() {
    var local = state;
    while (local.previous != null) {
      local = local.previous!;
    }
    _controller.add(local);
    return local;
  }

  /// Clear states.
  NodeState<T, W> clear() {
    state
      ..next = null
      ..previous = null;
    return state;
  }

  /// Reset bloc controller.
  Future<void> reset() async {
    await _controller.close();
    _controller = StreamController<NodeState<T, W>>();
    _controller.add(_state);
  }

  /// The timeline of the Bloc in a form of a String.
  String timeline() {
    var toBePrinted = '';
    NodeState<T, W>? node = state;
    while (node != null) {
      toBePrinted += '${node.event} <- ';
      node = node.previous;
    }
    toBePrinted += 'State';
    return toBePrinted;
  }
}

/// [NodeState] is basically a node of a linked list so that we enable
/// navigating between bloc states across time so easily.
class NodeState<T, W extends Event> {
  /// [NodeState] is basically a node of a linked list so that we enable
  /// navigating between bloc states across time so easily.
  NodeState(this.data, this.event);

  /// The current data of this node.
  final T data;

  /// The current event of this node.
  final W event;

  /// The previous node.
  NodeState<T, W>? previous;

  /// The next node.
  NodeState<T, W>? next;
}

/// The Event class of the [LinkedStateBloc]
abstract class Event {
  @override
  String toString() {
    return runtimeType.toString();
  }
}
