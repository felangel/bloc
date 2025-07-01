import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Ball extends Equatable {
  const Ball({
    required this.id,
    required this.position,
    required this.isMoving,
    required this.color,
  });
  final int id;
  final double position; // 0.0 = start, 1.0 = end
  final bool isMoving;
  final Color color;

  Ball copyWith({int? id, double? position, bool? isMoving, Color? color}) {
    return Ball(
      id: id ?? this.id,
      position: position ?? this.position,
      isMoving: isMoving ?? this.isMoving,
      color: color ?? this.color,
    );
  }

  @override
  List<Object> get props => [id, position, isMoving, color];
}
