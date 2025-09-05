import 'package:json_annotation/json_annotation.dart';

part 'post_type_dto.g.dart';

@JsonSerializable()
class CMPostTypeDto {
  final int? id;
  final String? name;
  final String? description;
  final int? ordering;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? projectTypeId;

  CMPostTypeDto({
    this.id,
    this.name,
    this.description,
    this.ordering,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.projectTypeId,
  });

  factory CMPostTypeDto.fromJson(Map<String, dynamic> json) =>
      _$PostTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostTypeDtoToJson(this);
}

@JsonSerializable()
class CMSectionTypeDto extends CMPostTypeDto {
  final String? type;

  CMSectionTypeDto({
    super.createdAt,
    super.deletedAt,
    super.description,
    super.id,
    super.name,
    super.ordering,
    super.updatedAt,
    this.type,
  });

  SectionType get sectionType => SectionType.getType(type ?? '');

  factory CMSectionTypeDto.fromJson(Map<String, dynamic> json) =>
      _$SectionTypeDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SectionTypeDtoToJson(this);
}

enum SectionType {
  board,
  feed,
  gallery,
  fileboard;

  static SectionType getType(String value) => switch (value) {
        'feed' => SectionType.feed,
        'board' => SectionType.board,
        'gallery' => SectionType.gallery,
        'fileboard' => SectionType.fileboard,
        _ => SectionType.board,
      };
}
