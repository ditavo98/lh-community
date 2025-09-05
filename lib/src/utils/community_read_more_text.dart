import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum TrimMode { length, line }

class CMReadMoreText extends StatefulWidget {
  const CMReadMoreText(
    this.data, {
    super.key,
    this.trimExpandedText = '\t간략히',
    this.trimCollapsedText = '...더보기',
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.length,
    required this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.buildTextSpan,
  });

  final String data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final int trimLength;
  final int trimLines;
  final TrimMode trimMode;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final TextSpan Function(String text)? buildTextSpan;

  @override
  CMReadMoreTextState createState() => CMReadMoreTextState();
}

const String _kEllipsis = '\u2026';

const String _kLineSeparator = '\u2028';

class CMReadMoreTextState extends State<CMReadMoreText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() => _readMore = !_readMore);
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final textScaleFactor =
        widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
    final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    TextSpan link = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: widget.style.copyWith(
        color: widget.colorClickableText,
      ),
      // effectiveTextStyle.copyWith(
      //   color: colorClickableText,
      //   fontSize: 15,
      //   fontWeight: FontWeight.bold,
      // ),
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Create a TextSpan with data
        final text = TextSpan(
          style: effectiveTextStyle,
          text: widget.data,
        );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
          locale: locale,
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        bool linkLongerThanLine = false;
        int? endIndex;

        if (linkSize.width < maxWidth) {
          final pos = textPainter.getPositionForOffset(Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset);
        } else {
          var pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        TextSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.trimLength < widget.data.length) {
              if (widget.buildTextSpan != null) {
                textSpan = widget.buildTextSpan!(_readMore
                    ? widget.data.substring(0, widget.trimLength)
                    : widget.data)
                  ..children!.add(link);
              } else {
                textSpan = TextSpan(
                  style: effectiveTextStyle,
                  text: _readMore
                      ? widget.data.substring(0, widget.trimLength)
                      : widget.data,
                  children: <TextSpan>[link],
                );
              }
            } else {
              if (widget.buildTextSpan != null) {
                textSpan = widget.buildTextSpan!(widget.data);
              } else {
                textSpan = TextSpan(
                  style: effectiveTextStyle,
                  text: widget.data,
                );
              }
            }
            break;
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              if (widget.buildTextSpan != null) {
                textSpan = widget.buildTextSpan!(_readMore
                    ? widget.data.substring(0, endIndex) +
                        (linkLongerThanLine ? _kLineSeparator : '')
                    : widget.data)
                  ..children!.add(link);
              } else {
                textSpan = TextSpan(
                  style: effectiveTextStyle,
                  text: _readMore
                      ? widget.data.substring(0, endIndex) +
                          (linkLongerThanLine ? _kLineSeparator : '')
                      : widget.data,
                  children: <TextSpan>[link],
                );
              }
            } else {
              if (widget.buildTextSpan != null) {
                textSpan = widget.buildTextSpan!(widget.data);
              } else {
                textSpan = TextSpan(
                  style: effectiveTextStyle,
                  text: widget.data,
                );
              }
            }
            break;
          default:
            throw Exception(
                'TrimMode type: ${widget.trimMode} is not supported');
        }

        return RichText(
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          //softWrap,
          overflow: TextOverflow.clip,
          //overflow,
          textScaleFactor: textScaleFactor,
          text: textSpan,
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }
    return result;
  }
}
