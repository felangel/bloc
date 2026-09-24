part of 'replay_cubit.dart';

typedef _Predicate<T> = bool Function(T);

class _ChangeStack<T> {
  _ChangeStack({required _Predicate<T> shouldReplay, this.limit})
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

  void redo(int steps) {
    if (steps <= 0) return;

    var effectiveSteps = steps;
    while (effectiveSteps > 0 && canRedo) {
      _Change<T>? changeToExecute;
      while (_redos.isNotEmpty) {
        final change = _redos.first;
        if (_shouldReplay(change._newValue)) {
          changeToExecute = _redos.removeFirst();
          break;
        } else {
          _history.addLast(_redos.removeFirst());
        }
      }

      if (changeToExecute != null) {
        _history.addLast(changeToExecute);
        changeToExecute.execute();
        effectiveSteps--;
      } else {
        break;
      }
    }
  }

  void undo(int steps) {
    if (steps <= 0) return;

    var effectiveSteps = steps;
    while (effectiveSteps > 0 && canUndo) {
      _Change<T>? changeToUndo;
      while (_history.isNotEmpty) {
        final change = _history.last;
        if (_shouldReplay(change._oldValue)) {
          changeToUndo = _history.removeLast();
          break;
        } else {
          _redos.addFirst(_history.removeLast());
        }
      }

      if (changeToUndo != null) {
        _redos.addFirst(changeToUndo);
        changeToUndo.undo();
        effectiveSteps--;
      } else {
        break;
      }
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
