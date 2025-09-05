import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/map_ex.dart';
import 'package:lh_community/src/utils/string_ex.dart';


class CMCustomText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Map<String, TextStyle>? styledValues;

  const CMCustomText(
    this.text, {
    super.key,
    required this.style,
    this.styledValues,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isNullOrEmpty || styledValues.isNullOrEmpty) {
      return Text(text, style: style);
    }

    List<TextSpan> spans = [];
    String remainingText = text;
    int currentIndex = 0;

    // Sort styled values by length (descending) to handle longer matches first
    // This prevents shorter substrings from matching prematurely
    var sortedKeys = styledValues!.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    while (remainingText.isNotEmpty) {
      bool foundMatch = false;

      // Try to find the next styled value
      for (String value in sortedKeys) {
        if (remainingText.startsWith(value)) {
          // Add the styled value
          spans.add(TextSpan(
            text: value,
            style: styledValues![value],
          ));
          remainingText = remainingText.substring(value.length);
          currentIndex += value.length;
          foundMatch = true;
          break;
        }
      }

      if (!foundMatch) {
        // Find the next occurrence of any styled value
        int? nextMatchIndex;
        String? nextMatchValue;

        for (String value in sortedKeys) {
          int index = remainingText.indexOf(value);
          if (index >= 0 &&
              (nextMatchIndex == null || index < nextMatchIndex)) {
            nextMatchIndex = index;
            nextMatchValue = value;
          }
        }

        if (nextMatchIndex != null && nextMatchValue != null) {
          // Add the text before the next match with restStyle
          if (nextMatchIndex > 0) {
            spans.add(TextSpan(
              text: remainingText.substring(0, nextMatchIndex),
              style: style,
            ));
          }
          // Add the matched styled value
          spans.add(TextSpan(
            text: nextMatchValue,
            style: styledValues![nextMatchValue],
          ));
          remainingText =
              remainingText.substring(nextMatchIndex + nextMatchValue.length);
          currentIndex += nextMatchIndex + nextMatchValue.length;
        } else {
          // No more matches, add the remaining text
          spans.add(TextSpan(
            text: remainingText,
            style: style,
          ));
          remainingText = '';
        }
      }
    }
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
