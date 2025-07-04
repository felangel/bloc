import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Ball model representing a ball in a game or animation.
class Ball extends Equatable {
  /// Creates a [Ball] instance with the given parameters.
  const Ball({
    required this.id,
    required this.position,
    required this.isMoving,
    required this.color,
  });

  /// Unique identifier for the ball.
  final int id;

  /// Position of the ball in the range [0.0, 1.0], where 0.0 is the start and 1.0 is the end.
  final double position; // 0.0 = start, 1.0 = end
  /// Indicates whether the ball is currently moving.
  final bool isMoving;

  /// Color of the ball.
  final Color color;

  /// Creates a copy of the ball with optional new values for its properties.
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
