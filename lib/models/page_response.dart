class PageResponse<T> {
  final List<T> list;
  final int total;
  final int page;
  final int limit;

  PageResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse<T>(
      list: (json['list'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
