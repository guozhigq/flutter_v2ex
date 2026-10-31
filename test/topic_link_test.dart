import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v2ex/utils/topic_link.dart';

void main() {
  test('accepts V2EX topic links and mirrors', () {
    for (final url in [
      'https://www.v2ex.com/t/123',
      'http://v2ex.com/t/123/',
      'https://cn.v2ex.com/t/123',
      'vvex://v2ex.com/t/123',
    ]) {
      expect(TopicLink.parse(url)?.route, '/t/123');
    }
  });

  test('preserves page and reply anchors with safe defaults', () {
    expect(TopicLink.parse('https://v2ex.com/t/123?p=2#r_456')?.parameters,
        {'p': '2', 'replyId': '456'});
    expect(TopicLink.parse('https://v2ex.com/t/123?p=bad#r_456')?.parameters,
        {'p': '1', 'replyId': '456'});
    expect(TopicLink.parse('https://v2ex.com/t/123#reply101')?.parameters,
        {'floorNumber': '101'});
    expect(TopicLink.parse('https://v2ex.com/t/123?p=-1')?.parameters, isEmpty);
  });

  test('rejects unrelated hosts, paths and invalid IDs', () {
    for (final url in [
      'https://v2ex.com.evil.com/t/123',
      'https://fakev2ex.com/t/123',
      'https://v2ex.com@evil.com/t/123',
      'https://evil@v2ex.com/t/123',
      'javascript://v2ex.com/t/123',
      'https://v2ex.com/t/0',
      'https://v2ex.com/t/nope',
      'https://v2ex.com/member/123',
      'https://v2ex.com/t/123/extra',
    ]) {
      expect(TopicLink.parse(url), isNull, reason: url);
    }
  });

  test('extracts links from copied share text', () {
    expect(
        TopicLink.fromText('推荐帖子（https://www.v2ex.com/t/123?p=2）。')?.location,
        '/t/123?p=2');
    expect(
        TopicLink.fromText('链接: https://evil.com/t/1 https://v2ex.com/t/2')
            ?.route,
        '/t/2');
    expect(TopicLink.fromText(null), isNull);
    expect(TopicLink.fromText('无链接'), isNull);
  });
}
