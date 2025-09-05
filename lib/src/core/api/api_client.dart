import 'package:dio/dio.dart';
import 'package:lh_community/src/core/model/base/base_response.dart';
import 'package:lh_community/src/core/model/comment/comment_dto.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/core/model/signed_url/signed_url_dto.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _ApiClient;


  @GET('post-types')
  Future<BaseResponse<BasePagination2<CMPostTypeDto>>> getPostType({
    @Query("projectTypeIds") required List<String> projectTypeIds,
  });

  @GET('section-types')
  Future<BaseResponse<BasePagination2<CMSectionTypeDto>>> getSectionType({
    @Query('page') required int page,
    @Query('limit') int size = 25,
    @Query('postTypeId') int? postTypeId,
  });

  @GET('posts')
  Future<BaseResponse<BasePagination2<CommunityPostDto>>> getPosts({
    @Query('page') required int page,
    @Query('limit') int size = 25,
    @Query('postTypeId') int? postTypeId,
    @Query('sectionTypeId') int? sectionTypeId,
    @Query('includeFiles') int includeFiles = 1,
  });

  @POST('post-types')
  Future<BaseResponse> addArtist({@Body() required data});

  @DELETE('post-types/{id}')
  Future<BaseResponse> deleteArtist({@Path() required int id});

  ///{
  //   "postTypeId": 14,
  //   "name": "Artist Section 1",
  //   "description": "New Artist Section 1 fans",
  //   "ordering": 1
  // }
  @POST('section-types')
  Future<BaseResponse> addSection({@Body() required data});

  ///{
  ///     "postTypeId": 16,
  ///     "sectionTypeId": 16,
  ///     "title": "플레이리스트에 나영 곡 추가 완료!",
  ///     "contents": "하루 시작은 나영 노래로🎧 여러분도 들어보세요~ 강추"
  /// }
  @POST('posts')
  Future<BaseResponse<CommunityPostDto>> createPost({@Body() required data});

  @PUT('posts/{id}')
  Future<BaseResponse<CommunityPostDto>> updatePost({
    @Body() required data,
    @Path('id') required int id,
  });

  @GET('posts/{id}')
  Future<BaseResponse<CommunityPostDto>> getPost({
    @Path('id') required int id,
  });

  ///{
  ///   "ids": [46, 28],
  ///   "type": "view"
  /// }
  @POST('posts/logs')
  Future<BaseResponse> postViewLogs({@Body() required data});

  @POST('comments')
  Future<BaseResponse<CommunityCommentDto>> comment(
      {@Body() required CommunityCommentDto comment});

  @PUT('comments/{id}')
  Future<BaseResponse> updateComment({
    @Path('id') required int postId,
    @Body() required CommunityCommentDto comment,
  });

  @GET('comments')
  Future<BaseResponse<BasePagination2<CommunityCommentDto>>> getComments({
    @Query('page') required int page,
    @Query('limit') int size = 25,
    @Query('postId') int? postId,
  });

  @DELETE('comments/{id}')
  Future<BaseResponse> deleteComment({@Path('id') required int commentId});

  @POST('posts/like/{id}')
  Future<BaseResponse> likePost({@Path('id') required int postId});

  ///{
  ///   "reason": "The comment is spam!",
  ///   "type": "HARM",
  ///   "target": "comment", // post | comment | user
  ///   "targetId": 2
  /// }
  @POST('reports')
  Future<BaseResponse> createReport(@Body() data);

  ///{
  ///   "targetUserId": 124,
  ///   "reason": "Spam user post" // optional
  /// }
  @POST('blocks')
  Future<BaseResponse> blocks(@Body() data);

  @DELETE('posts/{id}')
  Future<BaseResponse> deletePost({@Path('id') required int postId});

  @POST('comments/{id}/like')
  Future<BaseResponse> likeComment({@Path('id') required int commentId});

  //{
  //   "filePath": "p.888@park.jurassic@plane.com.jpg"
  // }
  @POST('upload/presigned-url')
  Future<BaseResponse<SignedUrlDto>> presigned({@Body() required data});
}
