import 'package:json_annotation/json_annotation.dart';

part 'signed_url_dto.g.dart';

@JsonSerializable()
class SignedUrlDto {
  final String? signedUrl;
  final String? filePath;
  final String? extension;
  final String? contentType;

  SignedUrlDto({
    this.signedUrl,
    this.filePath,
    this.extension,
    this.contentType,
  });

  factory SignedUrlDto.fromJson(Map<String, dynamic> json) =>
      _$SignedUrlDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignedUrlDtoToJson(this);
}
