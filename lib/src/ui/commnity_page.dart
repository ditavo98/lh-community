import 'dart:io';

import 'package:collection/collection.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/lh_community.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/cubits/community_artist_post_cubit/community_artist_post_cubit.dart';
import 'package:lh_community/src/ui/cubits/community_cubit.dart';
import 'package:lh_community/src/ui/post_detail.dart';
import 'package:lh_community/src/ui/widgets/artist_selected.dart';
import 'package:lh_community/src/ui/widgets/post_view/post_view.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/community_scaffold.dart';
import 'package:lh_community/src/utils/community_text_widget.dart';
import 'package:lh_community/src/utils/base_simmer_box.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/event_bus.dart';
import 'package:lh_community/src/utils/keep_alive_widget.dart';
import 'package:lh_community/src/utils/loadmore_widget.dart';
import 'package:lh_community/src/utils/no_data.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  final _tabBarKey = GlobalKey(debugLabel: 'profileTabBarKey');
  ValueNotifier<bool> showFakeTabBar = ValueNotifier(false);
  final ValueNotifier<bool> _isSwipingPage = ValueNotifier(false);

  final ScrollController _scrollController = ScrollController();

  final CMPostCubit _cubit = CMPostCubit();

  @override
  void initState() {
    tabController = TabController(length: 1, vsync: this);
    _onTabListener();
    super.initState();
  }

  @override
  void dispose() {
    _cubit.close();
    tabController.removeListener(_onPageChanging);
    tabController.animation?.removeListener(_onPageSwiping);
    tabController.dispose();
    showFakeTabBar.dispose();
    _isSwipingPage.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _onTabListener() {
    tabController.addListener(_onPageChanging);
    tabController.animation?.addListener(_onPageSwiping);
  }

  _onPageChanging() {
    if (tabController.index != tabController.previousIndex) {
      _cubit
          .onSelectSectionType(_cubit.state.sectionTypes[tabController.index]);
      LHEventBus.eventBus.fire(SwitchingSectionType());
    }
  }

  _onPageSwiping() {
    final value = tabController.animation!.value;
    if (value % 1 != 0) {
      _isSwipingPage.value = true;
    } else {
      _isSwipingPage.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: CMScaffold(
        bodyPadding: EdgeInsets.zero,
        body: Stack(
          children: [
            _body(),
            _hiddenTabBar(0),
          ],
        ),
        floatingActionButton: BlocBuilder<CMPostCubit, CMPostState>(
          builder: (context, state) {
            if (state.initial || state.sectionTypes.isNullOrEmpty) {
              return const SizedBox.shrink();
            }
            return ValueListenableBuilder(
                valueListenable: _isSwipingPage,
                builder: (context, changing, _) {
                  return FloatingActionButton(
                    onPressed: changing
                        ? null
                        : () {
                            CMCreatePost.open(
                              context,
                              postTypes: state.sectionTypes,
                              initPostType: state.selectArtist,
                              initSectionType: state.selectSection,
                            );
                          },
                    backgroundColor: CMColor.primary5,
                    shape: const CircleBorder(),
                    child: CMImageView(
                      cmSvg.icEdit3,
                      color: CMColor.white,
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

  _body() {
    return RefreshIndicator(
      notificationPredicate: (notification) {
        _checkTabBarPosition();
        if (notification is OverscrollNotification || Platform.isIOS) {
          return notification.depth == 2;
        }
        return notification.depth == 0;
      },
      onRefresh: () async {
        LHEventBus.eventBus.fire(
            ReloadSectionTypeEvent(id: _cubit.state.selectSection?.id ?? -1));
        return Future.value(true);
      },
      child: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(str.text_fan, style: LHTextStyle.h3),
                  ),
                  const ArtistSelected(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _artistInfo()),
          SliverToBoxAdapter(
            child: BlocConsumer<CMPostCubit, CMPostState>(
              listenWhen: (p, c) =>
                  p.initial != c.initial ||
                  !p.sectionTypes.equal(c.sectionTypes) ||
                  p.selectArtist != c.selectArtist,
              listener: (context, state) {
                final oldCtl = tabController;
                oldCtl.removeListener(_onPageChanging);
                oldCtl.animation?.removeListener(_onPageSwiping);
                oldCtl.dispose();
                final index = state.sectionTypes
                    .indexWhere((c) => c.id == state.selectSection?.id);
                tabController = TabController(
                  initialIndex: index > 0 ? index : 0,
                  length: state.sectionTypes.length,
                  vsync: this,
                );
                _onTabListener();
              },
              buildWhen: (p, c) =>
                  p.initial != c.initial ||
                  !p.sectionTypes.equal(c.sectionTypes) ||
                  p.selectArtist != c.selectArtist,
              builder: (context, state) {
                if (state.initial) return const SizedBox();
                return SizedBox(
                  key: _tabBarKey,
                  child: _tabBar(context, state.sectionTypes),
                );
              },
            ),
          ),
        ],
        body: BlocBuilder<CMPostCubit, CMPostState>(
          buildWhen: (p, c) =>
              p.initial != c.initial ||
              !p.sectionTypes.equal(c.sectionTypes) ||
              p.selectArtist != c.selectArtist,
          builder: (context, state) {
            if (state.initial) return _loading();
            if (state.selectArtist == null ||
                state.sectionTypes.isNullOrEmpty) {
              return NoData(
                text: str.have_no_star,
                onRefresh: () {
                  context.read<CMPostCubit>().getData();
                },
              );
            }
            return _tabBody(state.selectArtist!, state.sectionTypes);
          },
        ),
      ),
    );
  }

  _tabBar(BuildContext context, List<CMSectionTypeDto> sectionTypes) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TabBar.secondary(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            tabs: sectionTypes
                .map((x) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        x.name ?? '',
                      ),
                    ))
                .toList(),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: CMColor.black, width: 2.0),
            ),
            labelStyle: LHTextStyle.button1.copyWith(color: CMColor.black),
            unselectedLabelStyle:
                LHTextStyle.button1.copyWith(color: CMColor.grey5),
            splashFactory: NoSplash.splashFactory,
            dividerColor: CMColor.grey3,
            indicatorWeight: 2,
            onTap: (page) {
              double position = 0;
              if (_scrollController.position.pixels >= 120) {
                position = 120;
              }
              _scrollController.animateTo(
                position,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
              );
            },
          ),
        ),
      ],
    );
  }

  _tabBody(CMPostTypeDto artist, List<CMSectionTypeDto> sectionTypes) {
    return TabBarView(
      controller: tabController,
      children: [
        ...sectionTypes.map(
          (type) => ExtendedVisibilityDetector(
            uniqueKey: ObjectKey(type),
            child: KeepAliveWidget(
              key: ObjectKey(type),
              child: BlocProvider(
                create: (context) => CMArtistPostCubit(
                    artist: artist,
                    sectionType: type,
                    scrollController: _scrollController),
                child: Column(
                  children: [
                    _streamingList(type),
                    Expanded(
                      child: BlocBuilder<CMArtistPostCubit, CMArtistPostState>(
                        builder: (context, state) {
                          if (state.initial) {
                            return _postLoading();
                          }
                          if (state.postList.isNullOrEmpty) {
                            return NoData(
                                text: type.sectionType == SectionType.gallery
                                    ? str.text_no_gallery_registered
                                    : str.text_no_posts_yet);
                          }
                          return LoadMore(
                            onLoadMore: () {
                              return context
                                  .read<CMArtistPostCubit>()
                                  .getPostOfArtist();
                            },
                            isFinish: state.isFinished,
                            child: _postList(state, type.sectionType),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _streamingList(CMSectionTypeDto type) {
    if (type.sectionType != SectionType.fileboard) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () {
        launchUrl(
            Uri.parse(
                'https://startalk.app/streaming/${_cubit.state.selectArtist?.projectTypeId}?os=${Platform.isAndroid ? 'AOS' : 'IOS'}'),
            mode: LaunchMode.externalApplication);
      },
      child: Container(
        decoration: BoxDecoration(
            color: CMColor.parseColor('F3FFEB'),
            borderRadius: BorderRadius.all(Dimen.radius12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.all(16),
        child: Row(
          spacing: 10,
          children: [
            CMImageView(cmSvg.icHeadphones, size: 24),
            Expanded(
              child: CMCustomText(
                str.text_streaming_list_user(
                    _cubit.state.selectArtist?.name ?? ''),
                style: LHTextStyle.subtitle3_1.copyWith(
                  height: 20 / 15,
                  color: CMColor.parseColor('24BF40'),
                ),
                styledValues: {
                  _cubit.state.selectArtist?.name ?? '':
                      LHTextStyle.subtitle3_1.copyWith(
                    height: 20 / 15,
                    color: CMColor.parseColor('24BF40'),
                    fontWeight: FontWeight.w800,
                  ),
                },
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 24,
              color: CMColor.parseColor('24BF40'),
            )
          ],
        ),
      ),
    );
  }

  Widget _postList(CMArtistPostState state, SectionType type) {
    if (type == SectionType.gallery) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          final post = state.postList[index];
          return InkWell(
            onTap: () {
              CMPostDetailScreen.navigated(
                context,
                CMPostDetailArgs(
                  post: post,
                  sectionType: type,
                ),
              );
            },
            child: CMPostView(
              post: post,
              onView: () => context.read<CMPostCubit>().viewItem(post.id),
              sectionType: type,
            ),
          );
        },
        itemCount: state.postList.length,
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final post = state.postList[index];
        return InkWell(
          onTap: () {
            CMPostDetailScreen.navigated(
              context,
              CMPostDetailArgs(
                post: post,
                sectionType: type,
              ),
            );
          },
          child: CMPostView(
            post: post,
            onView: () => context.read<CMPostCubit>().viewItem(post.id),
            sectionType: type,
          ),
        );
      },
      separatorBuilder: (_, __) => Divider(color: CMColor.grey2),
      itemCount: state.postList.length,
    );
  }

  Widget _loading() {
    return ShimmerBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ColoredBox(
            color: Colors.white,
            child: SizedBox(
              height: 45,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _postLoading()),
        ],
      ),
    );
  }

  Widget _postLoading() {
    return ShimmerBox(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (_, __) => _postItemLoading(),
        separatorBuilder: (_, __) => Divider(color: CMColor.grey4),
        itemCount: 20,
      ),
    );
  }

  Widget _postItemLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColoredBox(
            color: Colors.white,
            child: SizedBox(height: 20, width: 50),
          ),
          ColoredBox(
            color: Colors.white,
            child: SizedBox(height: 24, width: double.infinity),
          ),
          ColoredBox(
            color: Colors.white,
            child: SizedBox(height: 18, width: 50),
          ),
          ColoredBox(
            color: Colors.white,
            child: SizedBox(height: 18, width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _artistInfo() {
    return BlocBuilder<CMPostCubit, CMPostState>(
      builder: (context, state) {
        if (state.selectArtist == null) {
          return _artistLoading();
        }
        final artists = LHCommunity().postTypePartnerData;
        final artist = artists
            .firstWhereOrNull((x) => x.nickname == state.selectArtist?.name);
        if (artist == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Dimen.radius16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: CMColor.grey2),
                    color: CMColor.black.withAlpha(10),
                  ),
                  child: CMImageView(
                    key: ValueKey(artist.avatar),
                    artist.avatar,
                    size: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.nickname ?? '',
                        style: LHTextStyle.subtitle1,
                      ),
                      Visibility(
                        visible: artist.message.notNullOrEmpty,
                        child: Text(
                          artist.message ?? '',
                          style:
                              LHTextStyle.body4.copyWith(color: CMColor.grey6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // const ArtistMusicBtn(),
            ],
          ),
        );
      },
    );
  }

  Widget _artistLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ShimmerBox(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Dimen.radius16),
              child: ColoredBox(
                color: Colors.white,
                child: SizedBox.square(
                  dimension: 56,
                ),
              ),
            ),
            Dimen.sBWidth4,
            Column(
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    width: 100,
                    height: 20,
                  ),
                ),
                SizedBox(height: 2),
                ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    width: 100,
                    height: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _checkTabBarPosition() async {
    try {
      RenderBox box =
          _tabBarKey.currentContext?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      double y = position.dy;
      if (y <= MediaQuery.of(context).viewPadding.top) {
        showFakeTabBar.value = true;
      } else {
        showFakeTabBar.value = false;
      }
    } catch (_) {}
  }

  Widget _hiddenTabBar(double padding) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ValueListenableBuilder(
        valueListenable: showFakeTabBar,
        builder: (context, show, child) {
          if (!show) {
            return const SizedBox();
          }
          return SizedBox(
            height: 48 + MediaQuery.of(context).viewPadding.top,
            child: BlocBuilder<CMPostCubit, CMPostState>(
              builder: (context, state) {
                return _tabBar(context, state.sectionTypes);
              },
            ),
          );
        },
      ),
    );
  }
}
