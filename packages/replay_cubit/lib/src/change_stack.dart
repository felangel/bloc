part of 'replay_cubit.dart';

class _ChangeStack<T> {
  _ChangeStack({this.limit});

  final Queue<_Change<T>> _history = ListQueue();
  final Queue<_Change<T>> _redos = ListQueue();

  int limit;

  bool get canRedo => _redos.isNotEmpty;
  bool get canUndo => _history.isNotEmpty;

  void add(_Change<T> change) {
    change.execute();
    if (limit != null && limit == 0) {
      return;
    }

    _history.addLast(change);
    _redos.clear();

    if (limit != null && _history.length > limit) {
      if (limit > 0) {
        _history.removeFirst();
      }
    }
  }

  void clear() {
    _history.clear();
    _redos.clear();
  }

  void redo() {
    if (canRedo) {
      final change = _redos.removeFirst()..execute();
      _history.addLast(change);
    }
  }

  void undo() {
    if (canUndo) {
      final change = _history.removeLast()..undo();
      _redos.addFirst(change);
    }
  }
}

class _Change<T> {
  _Change(
    this._oldValue,
    this._execute(),
    this._undo(T oldValue),
  );

  final T _oldValue;
  final Function _execute;
  final Function(T oldValue) _undo;

  void execute() => _execute();
  void undo() => _undo(_oldValue);
}
