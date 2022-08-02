class SearchResultError implements Exception {
  SearchResultError({required this.message});

  factory SearchResultError.fromJson(Map<String, dynamic> json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }

  final String message;
}
