import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/src/lh_community.dart';

class LHLoadingScreen {
  static final LHLoadingScreen _instance = LHLoadingScreen._();

  LHLoadingScreen._();

  factory LHLoadingScreen() {
    return _instance;
  }

  OverlayEntry? entry;

  bool _isShowLoading = false;
  String? _messageContent;

  void showLoadingWithMessage(BuildContext context, {String? message}) {
    _messageContent = message;
    _show(context);
  }

  void _show([BuildContext? context]) {
    try {
      if (_isShowLoading) return;
      entry = createOverlayEntry(context ?? LHCommunity().context);
      Overlay.of(context ?? LHCommunity().context).insert(entry!);
      _isShowLoading = true;
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static void show([BuildContext? context]) {
    _instance._show(context);
  }

  void _close() {
    try {
      _messageContent = null;
      if (entry != null) {
        entry?.remove();
        entry = null;
        _isShowLoading = false;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static void close() {
    _instance._close();
  }

  OverlayEntry createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onLongPress: kDebugMode
            ? () {
                close();
              }
            : null,
        child: Material(
          color: const Color(0x80000000),
          elevation: 4.0,
          child: _LoadingIndicatorWidget(
            messageContent: _messageContent,
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicatorWidget extends StatefulWidget {
  final String? messageContent;
  final Color? loadingColor;
  final Color? primaryTextColor;
  final Color? backgroundLoadingColor;

  const _LoadingIndicatorWidget({
    this.messageContent,
    this.loadingColor,
    this.primaryTextColor,
    this.backgroundLoadingColor,
  });

  @override
  __LoadingIndicatorWidgetState createState() =>
      __LoadingIndicatorWidgetState();
}

class __LoadingIndicatorWidgetState extends State<_LoadingIndicatorWidget> {
  String? get _messageContent => widget.messageContent;

  TextStyle get _messageTextStyle => TextStyle(
        fontWeight: FontWeight.w400,
        color: widget.primaryTextColor ??
            Theme.of(context).textTheme.bodyLarge?.color ??
            Colors.black,
        fontSize: 16,
        height: 20 / 16,
      );
  static const double DEFAULT_SIZE = 80.0;

  double _resolveBoxHeight = DEFAULT_SIZE;

  double _resolveBoxWidth = DEFAULT_SIZE;

  final GlobalKey _textSizeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      automaticallyAdjustContent();
    });
  }

  @override
  void didUpdateWidget(covariant _LoadingIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    automaticallyAdjustContent();
  }

  void automaticallyAdjustContent() {
    if (_messageContent == null) {
      _resolveBoxHeight = DEFAULT_SIZE;
      _resolveBoxWidth = DEFAULT_SIZE;
    } else {
      Size textSize = _textSize(_messageContent, _messageTextStyle);
      double horizontalPadding = 16;
      _resolveBoxWidth = textSize.width + horizontalPadding * 2;
      _resolveBoxHeight = DEFAULT_SIZE + textSize.height;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Size _textSize(String? text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout(
          minWidth: 0, maxWidth: MediaQuery.of(context).size.width * 3 / 4);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: _resolveBoxWidth,
          height: _resolveBoxHeight,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
              SizedBox(
                height: _messageContent != null ? 12 : 0,
              ),
              _messageContent != null
                  ? Flexible(
                      child: Text(
                        _messageContent ?? '',
                        key: _textSizeKey,
                        style: _messageTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
