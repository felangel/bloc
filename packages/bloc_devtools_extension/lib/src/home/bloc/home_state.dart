part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({this.blocs = const []});

  final List<BlocNode> blocs;

  @override
  List<Object?> get props => [blocs];
}

class BlocNode extends Equatable {
  const BlocNode._({
    required this.name,
    required this.state,
    required this.hash,
    required this.lastModified,
  });

  factory BlocNode.fromJson(Map<String, dynamic> json) {
    return BlocNode._(
      name: json['name'] as String? ?? 'Unknown',
      state: json['state'] as String? ?? '--',
      hash: json['hash'] as int? ?? 0,
      lastModified: DateTime.now(),
    );
  }

  final String name;
  final String state;
  final int hash;
  final DateTime lastModified;

  @override
  List<Object> get props => [name, state, hash, lastModified];
}
