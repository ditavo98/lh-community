import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  final int? status;
  final int? code;
  final DateTime? timestamp;
  final String? message;
  final T? data;

  BaseResponse({
    this.code,
    this.status,
    this.data,
    this.message,
    this.timestamp,
  });

  bool get success {
    if (message?.toLowerCase() == "success" || data != null || isSuccess) {
      return true;
    }
    return false;
  }

  bool get isSuccess {
    final resCode = code ?? status;
    return resCode != null && resCode >= 200 && resCode <= 299;
  }

  factory BaseResponse.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$BaseResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class BasePagination2<T> {
  final List<T>? items;
  final Pagination2? pagination;

  BasePagination2({this.items, this.pagination});

  factory BasePagination2.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$BasePagination2FromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$BasePagination2ToJson(this, toJsonT);
}

@JsonSerializable()
class Pagination2 {
  final int? total;
  final int? page;
  final int? limit;

  factory Pagination2.fromJson(Map<String, dynamic> json) =>
      _$Pagination2FromJson(json);

  Pagination2({this.total, this.page, this.limit});

  Map<String, dynamic> toJson() => _$Pagination2ToJson(this);
}
