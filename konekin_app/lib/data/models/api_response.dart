class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? total;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.total,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      total: json['total'],
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      total: statusCode,
    );
  }
}