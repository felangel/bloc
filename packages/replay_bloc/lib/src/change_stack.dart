part of 'replay_cubit.dart';

typedef _Predicate<T> = bool Function(T);

class _ChangeStack<T> {
  _ChangeStack({this.limit, required _Predicate<T> shouldReplay})
      : _shouldReplay = shouldReplay;

  final Queue<_Change<T>> _history = ListQueue();
  final Queue<_Change<T>> _redos = ListQueue();
  final _Predicate<T> _shouldReplay;

  int? limit;

  bool get canRedo => _redos.any((c) => _shouldReplay(c._newValue));
  bool get canUndo => _history.any((c) => _shouldReplay(c._oldValue));

  void add(_Change<T> change) {
    if (limit != null && limit == 0) return;

    _history.addLast(change);
    _redos.clear();

    if (limit != null && _history.length > limit!) {
      if (limit! > 0) _history.removeFirst();
    }
  }

  void clear() {
    _history.clear();
    _redos.clear();
  }

  void redo() {
    if (canRedo) {
      final change = _redos.removeFirst();
      _history.addLast(change);
      return _shouldReplay(change._newValue) ? change.execute() : redo();
    }
  }

  void undo() {
    if (canUndo) {
      final change = _history.removeLast();
      _redos.addFirst(change);
      return _shouldReplay(change._oldValue) ? change.undo() : undo();
    }
  }
}

class _Change<T> {
  _Change(
    this._oldValue,
    this._newValue,
    this._execute,
    this._undo,
  );

  final T _oldValue;
  final T _newValue;
  final void Function() _execute;
  final void Function(T oldValue) _undo;

  void execute() => _execute();
  void undo() => _undo(_oldValue);
}
