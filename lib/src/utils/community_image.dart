import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lh_community/generated/assets.gen.dart';
import 'package:lh_community/src/utils/community_image_cache_manager.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:photo_gallery/photo_gallery.dart';

class CMImageView extends StatefulWidget {
  final dynamic image;
  final double? size;
  final double? width;
  final double? height;
  final double? holderSize;
  final Color? color;
  final bool oval;
  final BoxFit? fit;
  final Function()? onTap;
  final Widget Function()? errorWidget;
  final Widget Function()? placeholder;
  final ImageWidgetBuilder? imageBuilder;
  final double? radius;

  const CMImageView(
    this.image, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit,
    this.oval = false,
    this.errorWidget,
    this.placeholder,
    this.onTap,
    this.color,
    this.holderSize,
    this.imageBuilder,
    this.radius,
  });

  @override
  State<CMImageView> createState() => _ImageViewState();

  static ImageProvider imageProvider(dynamic image) {
    if (image is Medium) {
      return PhotoProvider(mediumId: image.id);
    }
    if (image is File) {
      return FileImage(image);
    }
    if (image is XFile) {
      return FileImage(File(image.path));
    }
    if (image is Uint8List) {
      return MemoryImage(image);
    }
    if (image is ImageProvider) {
      return image;
    }
    String path = image is String ? image : image.toString();

    var isAsset = path.split('/').firstOrNull == 'assets';
    if (isAsset) {
      return AssetImage(path);
    }
    return CachedNetworkImageProvider(path);
  }
}

class _ImageViewState extends State<CMImageView> {
  double? get _width => widget.size ?? widget.width;

  double? get _height => widget.size ?? widget.height;

  ColorFilter? get _colorFilter => widget.color != null
      ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
      : null;

  final ValueNotifier sourceInitNotifier = ValueNotifier(null);
  late dynamic _image;

  @override
  void initState() {
    _image = _imageSource(widget.image);
    super.initState();
  }

  dynamic _imageSource(image) {
    if (image is AssetGenImage || image is SvgGenImage) return image.keyName;
    return image;
  }

  @override
  Widget build(BuildContext context) {
    if (_image is Future) {
      var future = _image as Future;
      future.then((value) => sourceInitNotifier.value = value);
      return _ovalWidget(
        child: ValueListenableBuilder(
          valueListenable: sourceInitNotifier,
          builder: (context, value, child) {
            if (value != null) {
              return _gestureWidget(value);
            } else {
              return _placeHolderView();
            }
          },
        ),
      );
    }
    if (sourceInitNotifier.value != null) {
      return _ovalWidget(
        child: _gestureWidget(sourceInitNotifier.value),
      );
    }
    return _ovalWidget(
      child: _gestureWidget(_image),
    );
  }

  Widget _gestureWidget(dynamic image) {
    Widget sizedImage = SizedBox(
      width: _width,
      height: _height,
      child: _imageWidget(image),
    );
    if (widget.onTap != null) {
      sizedImage = GestureDetector(
        onTap: widget.onTap,
        child: sizedImage,
      );
    }
    if (widget.radius != null) {
      sizedImage = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(widget.radius!)),
        child: sizedImage,
      );
    }
    return sizedImage;
  }

  Widget _imageWidget(dynamic image) {
    if (image is File) {
      var ext = image.path.split('.').lastOrNull;
      return _fileImage(image, ext);
    }
    if (image is XFile) {
      var ext = image.path.split('.').lastOrNull;
      return _fileImage(File(image.path), ext);
    }
    if (image is Uint8List) {
      return _uInt8ListImage(image);
    }
    if (image is ImageProvider) {
      return Image(
        image: image,
        width: _width,
        height: _height,
        fit: widget.fit,
      );
    }
    if (image is Medium) {
      return _mediumImage(image);
    }
    String path = image is String ? image : image.toString();
    var ext = path.split('.').lastOrNull;
    var isAsset = ['assets', 'packages'].contains(path.split('/').firstOrNull);
    if (isAsset) {
      return _assetImage(path, ext);
    }
    return _networkImage(path, ext);
  }

  Widget _fileImage(dynamic source, String? ext) {
    if (ext == 'svg') {
      return SvgPicture.file(
        source,
        width: _width,
        height: _height,
        colorFilter: _colorFilter,
        fit: widget.fit ?? BoxFit.contain,
        placeholderBuilder: (_) => _placeHolderView(),
      );
    }
    return Image.file(
      source,
      width: _width,
      height: _height,
      fit: widget.fit,
      color: widget.color,
      errorBuilder: (_, __, ___) => _errorView(),
    );
  }

  Widget _uInt8ListImage(dynamic source) {
    return Image.memory(
      source,
      width: _width,
      height: _height,
      fit: widget.fit,
      color: widget.color,
      errorBuilder: (_, __, ___) => _errorView(),
    );
  }

  Widget _networkImage(dynamic source, String? ext) {
    if (ext == 'svg') {
      return SvgPicture.network(
        source,
        width: _width,
        height: _height,
        colorFilter: _colorFilter,
        fit: widget.fit ?? BoxFit.contain,
        placeholderBuilder: (_) => _placeHolderView(),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxHeight * 2;
      return CachedNetworkImage(
        memCacheWidth: maxWidth.toInt(),
        imageUrl: LHUtils.getMediaUrl(source) ?? '',
        width: _width,
        height: _height,
        fit: widget.fit,
        errorWidget: (_, __, ___) => _errorView(),
        placeholder: (_, __) => _placeHolderView(),
        imageBuilder: widget.imageBuilder,
      );
    });
  }

  Widget _assetImage(dynamic source, String? ext) {
    if (ext == 'svg') {
      return SvgPicture.asset(
        source,
        width: _width,
        height: _height,
        colorFilter: _colorFilter,
        fit: widget.fit ?? BoxFit.contain,
      );
    }
    return Image.asset(
      source,
      width: _width,
      height: _height,
      color: widget.color,
      fit: widget.fit,
    );
  }

  Widget _mediumImage(dynamic source) {
    return FadeInImage(
      fit: widget.fit,
      width: _width,
      height: _height,
      placeholder: MemoryImage(kTransparentImage),
      image: PhotoProvider(mediumId: source.id),
    );
  }

  Widget _errorView() {
    return widget.errorWidget?.call() ??
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Image.asset(Assets.images.placeholder.keyName, width: _width),
        );
  }

  Widget _ovalWidget({required Widget child}) {
    if (widget.oval) {
      return ClipOval(
        child: child,
      );
    }
    return child;
  }

  Widget _placeHolderView() {
    return SizedBox(
      width: _width,
      height: _height,
      child: Center(
        child: widget.placeholder?.call() ??
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Image.asset(Assets.images.placeholder.keyName, width: _width),
            ),
      ),
    );
  }

  @override
  void dispose() {
    sourceInitNotifier.dispose();
    super.dispose();
  }
}

class ImageViewCircular extends StatelessWidget {
  final double borderWidth;
  final Color? borderColor;
  final dynamic image;
  final double size;
  final BoxFit? fit;
  final Function()? onTap;
  final Widget Function()? errorWidget;
  final Widget Function()? placeholder;

  const ImageViewCircular(
    this.image, {
    super.key,
    required this.size,
    this.fit,
    this.errorWidget,
    this.placeholder,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var radius = BorderRadius.all(Radius.circular(size / 2));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          width: borderWidth,
          color: borderColor ?? Colors.transparent,
        ),
        color: Colors.transparent,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CMImageView(
          image,
          size: size,
          errorWidget: errorWidget,
          placeholder: placeholder,
          fit: fit,
          onTap: onTap,
        ),
      ),
    );
  }
}

class ImageIconHolder extends StatelessWidget {
  IconData icon;
  double? size;
  double? iconSize;
  Color? color;
  Color? background;

  ImageIconHolder(
    this.icon, {
    super.key,
    this.size,
    this.iconSize,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: background ?? Colors.grey.shade300,
      child: Center(
        child: Icon(
          icon,
          size: iconSize ??
              (size == null || size == double.infinity ? 20 : size! * 0.5),
          color: color ?? Colors.white,
        ),
      ),
    );
  }
}

class ImageInfo extends StatelessWidget {
  String url;

  ImageInfo(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    Image image = Image.network('https://i.stack.imgur.com/lkd0a.png');
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      completer.complete(image.image);
    }));
    return Stack(
      children: [
        image,
        Positioned(
          top: 0,
          left: 0,
          child: FutureBuilder<ui.Image>(
            future: completer.future,
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;
                return Text('${data.width}x${data.height}');
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }
}

class CustomCacheImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const CustomCacheImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
  });

  bool isRemoteUrl(String? url) {
    return url?.startsWith('http://') == true ||
        url?.startsWith('https://') == true;
  }

  @override
  Widget build(BuildContext context) {
    if (url.isNullOrEmpty || !isRemoteUrl(url)) {
      return SizedBox(
        width: width,
        height: height,
        child: ColoredBox(color: Colors.grey.shade200),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxHeight * 2.5;
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            cacheKey: url,
            memCacheWidth: maxWidth.toInt(),
            fadeInDuration: const Duration(milliseconds: 250),
            fadeOutDuration: const Duration(milliseconds: 250),
            imageUrl: url,
            cacheManager: CMImageCacheManager(),
            placeholder: (context, url) => SizedBox(
              width: width,
              height: height,
              child: ColoredBox(color: Colors.grey.shade200),
            ),
            errorWidget: (context, url, error) => ImageIconHolder(
              Icons.image_not_supported_outlined,
            ),
          );
        },
      ),
    );
  }
}
