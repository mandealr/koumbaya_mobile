import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final List<String>? errors;
  final Map<String, dynamic>? meta;

  ApiResponse({
    this.data,
    this.message,
    this.success = false,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => _$ApiResponseToJson(this, toJsonT);

  bool get isSuccess => success && errors == null;
  String get errorMessage => errors?.join(', ') ?? message ?? 'Une erreur est survenue';
}