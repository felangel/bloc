part of 'replay_cubit.dart';

typedef _Predicate<T> = bool Function(T);

class _ChangeStack<T> {
  _ChangeStack({required _Predicate<T> shouldReplay, int? limit})
      : _shouldReplay = shouldReplay,
        _limit = limit;

  final Queue<_Change<T>> _history = ListQueue();
  final Queue<_Change<T>> _redos = ListQueue();
  final _Predicate<T> _shouldReplay;

  int? _limit;

  int? get limit => _limit;

  set limit(int? limit) {
    _limit = limit;
    _trimHistory();
  }

  bool get canRedo => _redos.any((c) => _shouldReplay(c._newValue));
  bool get canUndo => _history.any((c) => _shouldReplay(c._oldValue));

  void add(_Change<T> change) {
    if (limit != null && limit == 0) return;

    _history.addLast(change);
    _redos.clear();
    _trimHistory();
  }

  void _trimHistory() {
    final limit = _limit;
    if (limit == null || limit < 0) return;
    while (_history.length > limit) {
      _history.removeFirst();
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
      _trimHistory();
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
