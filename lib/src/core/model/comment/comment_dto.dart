import 'package:json_annotation/json_annotation.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/utils/lh_utils.dart';

part 'comment_dto.g.dart';

@JsonSerializable()
class CommunityCommentDto {
  final int? id;
  final int? postId;
  final int? parentCommentId;
  final String? comment;
  final List<LHFileAttachment>? files;
  final int? likeCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? type;
  final String? source;
  final String? status;
  final bool? isLiked;
  final int? replyCount;
  final LHUserDto? user;
  final List<CommunityCommentDto>? replies;

  final String? nickname;
  final String? nicknameAvatarUrl;

  CommunityCommentDto({
    this.id,
    this.postId,
    this.parentCommentId,
    this.comment,
    this.files,
    this.likeCount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.type,
    this.source,
    this.status,
    this.isLiked,
    this.user,
    this.replies,
    this.replyCount,
    this.nickname,
    this.nicknameAvatarUrl,
  });

  String? get cmtAuthorName => nickname ?? user?.name;

  String? get cmtAuthorAvatar =>
      LHUtils.getMediaUrl(nicknameAvatarUrl ?? user?.avatar);

  factory CommunityCommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityCommentDtoToJson(this);

  CommunityCommentDto copyWith({
    int? id,
    int? postId,
    int? parentCommentId,
    String? comment,
    List<LHFileAttachment>? files,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? type,
    String? source,
    String? status,
    bool? isLiked,
    LHUserDto? user,
    List<CommunityCommentDto>? replies,
    int? replyCount,
    String? nickname,
    String? nicknameAvatarUrl,
  }) {
    return CommunityCommentDto(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      comment: comment ?? this.comment,
      files: files ?? this.files,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      type: type ?? this.type,
      source: source ?? this.source,
      status: status ?? this.status,
      isLiked: isLiked ?? this.isLiked,
      user: user ?? this.user,
      replies: replies ?? this.replies,
      replyCount: replyCount ?? this.replyCount,
      nicknameAvatarUrl: nicknameAvatarUrl ?? this.nicknameAvatarUrl,
      nickname: nickname ?? this.nickname,
    );
  }
}

@JsonSerializable()
class LHFileAttachment {
  final String? url;
  final String? thumbnailUrl;
  final String? type;
  final String? caption;
  final String? mime;

  LHFileAttachment({
    this.url,
    this.thumbnailUrl,
    this.type,
    this.caption,
    this.mime,
  });

  factory LHFileAttachment.fromJson(Map<String, dynamic> json) =>
      _$LHFileAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$LHFileAttachmentToJson(this);
}
