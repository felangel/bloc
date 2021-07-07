// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final String id;
  final bool complete;
  final String task;
  final String? note;

  const TodoEntity({
    required this.id,
    required this.task,
    required this.complete,
    this.note,
  });

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'task': task,
      'complete': complete,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [id, task, complete, note];

  @override
  String toString() {
    return 'TodoEntity { complete: $complete, task: $task, note: $note, id: $id }';
  }

  static TodoEntity fromJson(Map<String, Object> json) {
    return TodoEntity(
      id: json['id'] as String,
      task: json['task'] as String,
      complete: json['complete'] as bool,
      note: json['note'] as String?,
    );
  }

  static TodoEntity fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data();
    if (data == null) throw Exception();
    return TodoEntity(
      id: data['id'],
      task: data['task'],
      complete: data['complete'],
      note: data['note'],
    );
  }

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'complete': complete,
      'task': task,
      'note': note,
    };
  }
}
