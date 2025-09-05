import 'package:json_annotation/json_annotation.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/num_ex.dart';

part 'post_dto.g.dart';

@JsonSerializable()
class CommunityPostDto {
  final int? id;
  final int? userId;
  final int? postTypeId;
  final String? title;
  final String? contents;
  final dynamic hashtag;
  final DateTime? postedAt;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;
  final String? status;
  final dynamic source;
  final dynamic ratings;
  final dynamic storeName;
  final String? createdType;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? weight;
  final bool? generatedByAi;
  final dynamic approvalStatus;
  final List<CommunityFileElementDto>? files;
  final LHUserDto? user;
  final CMPostTypeDto? postType;
  final String? nickname;
  final String? nicknameAvatarUrl;
  final int? fileCount;

  final bool? isLiked;

  bool get isMy => user?.projectUserId == LHCommunity().userId;

  String? get postAuthorName => nickname ?? user?.name;

  String? get postAuthorAvatar =>
      LHUtils.getMediaUrl(nicknameAvatarUrl ?? user?.avatar);

  CommunityPostDto({
    this.id,
    this.userId,
    this.postTypeId,
    this.title,
    this.contents,
    this.hashtag,
    this.postedAt,
    this.viewCount,
    this.likeCount,
    this.commentCount,
    this.status,
    this.source,
    this.ratings,
    this.storeName,
    this.createdType,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.weight,
    this.generatedByAi,
    this.approvalStatus,
    this.files,
    this.user,
    this.postType,
    this.isLiked = false,
    this.nickname,
    this.nicknameAvatarUrl,
    this.fileCount,
  });

  factory CommunityPostDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityPostDtoToJson(this);

  CommunityPostDto copyWith({
    int? id,
    int? userId,
    int? postTypeId,
    String? title,
    String? contents,
    dynamic hashtag,
    DateTime? postedAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    String? status,
    dynamic source,
    dynamic ratings,
    dynamic storeName,
    String? createdType,
    dynamic deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? weight,
    bool? generatedByAi,
    dynamic approvalStatus,
    List<CommunityFileElementDto>? files,
    LHUserDto? user,
    dynamic postType,
    bool? isLiked,
    String? nickname,
    String? nicknameAvatarUrl,
    int? fileCount,
  }) {
    return CommunityPostDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postTypeId: postTypeId ?? this.postTypeId,
      title: title ?? this.title,
      contents: contents ?? this.contents,
      hashtag: hashtag ?? this.hashtag,
      postedAt: postedAt ?? this.postedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      status: status ?? this.status,
      source: source ?? this.source,
      ratings: ratings ?? this.ratings,
      storeName: storeName ?? this.storeName,
      createdType: createdType ?? this.createdType,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weight: weight ?? this.weight,
      generatedByAi: generatedByAi ?? this.generatedByAi,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      files: files ?? this.files,
      user: user ?? this.user,
      postType: postType ?? this.postType,
      isLiked: isLiked ?? this.isLiked,
      nickname: nickname ?? this.nickname,
      nicknameAvatarUrl: nicknameAvatarUrl ?? this.nicknameAvatarUrl,
      fileCount: fileCount ?? this.fileCount,
    );
  }
}

@JsonSerializable(includeIfNull: false)
class CommunityFileElementDto {
  final int? id;
  final int? postId;
  final String? type;
  final String? url;
  final String? caption;
  final dynamic mime;
  final int? width;
  final int? height;
  final dynamic ratio;
  final String? thumbnailUrl;

  CommunityFileElementDto({
    this.id,
    this.postId,
    this.type,
    this.url,
    this.caption,
    this.mime,
    this.width,
    this.height,
    this.ratio,
    this.thumbnailUrl,
  });

  double? get displayRatio {
    if (ratio != null) return ratio;
    if (width.haveValue && height.haveValue) return width! / height!;
    return null;
  }

  factory CommunityFileElementDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityFileElementDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityFileElementDtoToJson(this);
}

@JsonSerializable()
class LHUserDto {
  final int? id;
  final String? name;
  final String? email;
  final dynamic avatar;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? projectUserId;

  const LHUserDto({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.projectUserId,
  });

  factory LHUserDto.fromJson(Map<String, dynamic> json) =>
      _$LHUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LHUserDtoToJson(this);
}
