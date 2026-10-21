/// A validated external V2EX topic link.
class TopicLink {
  final String topicId;
  final Map<String, String> parameters;
  TopicLink(this.topicId, this.parameters);
  String get route => '/t/$topicId';
  String get location =>
      Uri(path: route, queryParameters: parameters.isEmpty ? null : parameters)
          .toString();

  static TopicLink? parse(String? text) {
    if (text == null) return null;
    final uri = Uri.tryParse(text.trim());
    if (uri == null ||
        !const ['http', 'https', 'vvex'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        !(uri.host == 'v2ex.com' || uri.host.endsWith('.v2ex.com'))) {
      return null;
    }
    final match = RegExp(r'^/t/([1-9][0-9]*)/?$').firstMatch(uri.path);
    if (match == null) return null;
    final parameters = <String, String>{};
    final page = int.tryParse(uri.queryParameters['p'] ?? '');
    if (page != null && page > 0) parameters['p'] = '$page';
    final reply = RegExp(r'^r_([1-9][0-9]*)$').firstMatch(uri.fragment);
    final floor = RegExp(r'^reply([1-9][0-9]*)$').firstMatch(uri.fragment);
    if (reply != null) {
      parameters['replyId'] = reply[1]!;
      parameters.putIfAbsent('p', () => '1');
    } else if (floor != null) {
      parameters['floorNumber'] = floor[1]!;
    }
    return TopicLink(match[1]!, parameters);
  }

  static TopicLink? fromText(String? text) {
    if (text == null) return null;
    final direct = parse(text);
    if (direct != null) return direct;
    for (final match
        in RegExp(r'''https?://[^\s<>"'，。；）】]+''', caseSensitive: false)
            .allMatches(text)) {
      final link = parse(match[0]!.replaceFirst(RegExp(r'[).,;!]+$'), ''));
      if (link != null) return link;
    }
    return null;
  }
}
