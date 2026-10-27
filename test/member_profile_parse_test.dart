import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v2ex/http/user.dart';

// Minimal structural fixture from the failing desktop member page. Keeping the
// server's English membership text reproduces the original separator failure.
String profileHtml(String metadata, {bool includeMetadata = true}) => '''
<html><body>
<div id="Top"><div><div class="site-nav"><div class="tools">
  <a href="/signin">Sign in</a>
</div></div></div></div>
<div id="Main">
  <div class="box"><div class="cell"><table><tr>
    <td><img src="https://cdn.v2ex.com/avatar/example.png"></td>
    <td><h1>reader</h1>
      ${includeMetadata ? '<span class="gray">$metadata</span>' : ''}
    </td>
  </tr></table></div></div>
  <div class="box"><div class="cell_tabs">reader</div>
    <div class="cell"><span class="gray">Per reader's settings, the topics list is hidden</span></div>
  </div>
  <div class="box"><div class="cell">reader's recent replies</div>
    <div class="dock_area"><span class="fade">7h ago</span>
      <span class="gray">Replied to a topic by <a href="/member/author">author</a>
        <a href="/go/create">分享创造</a><a href="/t/1250253#reply168">测试主题</a>
      </span>
    </div><div class="reply_content">一条真实结构的回复</div>
  </div>
</div>
</body></html>
''';

void main() {
  for (final prefix in [
    'V2EX member #631769, joined on',
    'V2EX 第 631769 号会员，加入于'
  ]) {
    test('parses translated member metadata: $prefix', () {
      final result = UserWebApi.parseMemberProfile(
          profileHtml(
            '$prefix 2023-05-30 17:55:14 +08:00<div class="sep5"></div>Today\'s activity rank <a href="/top/dau">18</a>',
          ),
          'reader');
      expect(result.memberId, 'reader');
      expect(
          result.mbSort,
          prefix.startsWith('V2EX member')
              ? 'V2EX member #631769'
              : 'V2EX 第 631769 号会员');
      expect(
          result.mbCreatedTime,
          prefix.startsWith('V2EX member')
              ? 'joined on 2023-05-30 17:55:14'
              : '加入于 2023-05-30 17:55:14');
      expect(result.isShowTopic, isFalse);
      expect(result.replyList.single.topicId, '1250253');
      expect(result.replyList.single.replyContent, '一条真实结构的回复');
    });
  }

  test('missing optional membership date does not fail the profile', () {
    final result = UserWebApi.parseMemberProfile(
        profileHtml('', includeMetadata: false), 'reader');
    expect(result.memberId, 'reader');
    expect(result.mbCreatedTime, isEmpty);
    expect(result.replyList, hasLength(1));
  });

  test('an error page is rejected rather than treated as a member', () {
    expect(
        () =>
            UserWebApi.parseMemberProfile('<html>Unavailable</html>', 'reader'),
        throwsFormatException);
  });
}
