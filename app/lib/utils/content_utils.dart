import 'package:html2md/html2md.dart' as html2md;

/// Detects if content contains HTML tags.
bool isHtmlContent(String content) {
  return RegExp(
    r'<(p|div|span|h[1-6]|ul|ol|li|br|img|a|table|tr|td|th|strong|em|b|i|pre|code|blockquote|section|article|header|footer|nav|main|figure|figcaption|hr)\b[^>]*/?>',
    caseSensitive: false,
  ).hasMatch(content);
}

/// Prepares content for rendering with [MarkdownBody].
///
/// If [content] is detected as HTML, converts it to Markdown using [html2md].
/// Otherwise returns it as-is.
String prepareContent(String content) {
  if (isHtmlContent(content)) {
    return html2md.convert(content);
  }
  return content;
}
