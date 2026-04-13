class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

class ApiResponseList<T> {
  final bool success;
  final String message;
  final List<T> data;
  final int? total;
  final int? page;
  final int? limit;

  ApiResponseList({
    required this.success,
    required this.message,
    this.data = const [],
    this.total,
    this.page,
    this.limit,
  });

  factory ApiResponseList.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    final List<dynamic> dataList = json['data'] ?? [];
    return ApiResponseList(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList.map((item) => fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}