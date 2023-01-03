class ETree {
  String? _html;
  Element? rootElement;

  static ETree fromString(html) {
    var tree = ETree();
    tree._html = html;
    var bt = BuildTree(html);
    if (!bt.build()) {
      // ignore: avoid_print
      print('tree build failed');
    }
    tree.rootElement = bt.rootElement;
    return tree;
  }

  List<Element>? xpath(String xp) => rootElement!.xpath(xp);
}

enum ElementType { root, tag, declare, comment, text }

class Element {
  ElementType? type;
  String? name;
  Map<String, dynamic> attributes = {};
  Element? parent;
  List<Element> children = [];
  int? start, end;
  List<Element>? xpath(String xp) {
    var x = XPath(this, xp);
    return x.parse();
  }
}

var regName = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_-]*');
var regFormatting = RegExp(r'^[\s\t\r\n]+');
var regTag = RegExp(r'^<[a-zA-Z_][\s\S]*?>');
var regTagEnd = RegExp(r'^</[\s\S]*?>');
var regDeclare = RegExp(r'^<![^-][^-][\s\S]*?>');
var regComment = RegExp(r'^<!--[\s\S]*?-->');
var regText = RegExp(r'^[^<]*');
var regString = RegExp(r''''.*?'|".*?"''');

class BuildTree {
  String _html;
  int? _current;
  late int _max_idx;
  Element? _parent;
  int _depth = 0;

  Element rootElement = Element()..type = ElementType.root;

  BuildTree(this._html) {
    _max_idx = _html.length;
  }

  bool build() {
    _current = 0;
    _depth = 0;
    _parent = rootElement;

    while (_current! < _max_idx) {
      if (!_nextElement()) return false;
    }
    return true;
  }

  bool _nextElement() {
    var currentBak = _current;
    _skipFormatting();
    if (_current! >= _max_idx) return true;
    if (_html[_current!] == '<') {
      return _nextTag();
    } else {
      _current = currentBak;
      return _nextText();
    }
  }

  // skip space, \t, \n, \r
  void _skipFormatting() {
    if (_current! >= _max_idx) return;

    var m = regFormatting.firstMatch(_html.substring(_current!));
    if (m == null) return;
    _current = _current! + m.end;
  }

  // _current at <
  bool _nextTag() {
    if (_current! + 2 >= _max_idx) {
      return false;
    } // assume at lease one char in <>
    switch (_html[_current! + 1]) {
      case '!':
        return _nextComment() || _nextDeclare();
      case '/':
        return _nextEndTag();
      default:
        return _nextStartTag();
    }
  }

  // _current at <
  bool _nextComment() {
    var m = regComment.firstMatch(_html.substring(_current!));
    if (m == null) return false;
    Element e = Element();
    e.type = ElementType.comment;
    e.start = _current; // start from <!--
    _current = _current! + m.end;
    e.end = _current;
    e.parent = _parent;
    _parent!.children.add(e);
    return true;
  }

  bool _nextDeclare() {
    var m = regDeclare.firstMatch(_html.substring(_current!));
    if (m == null) return false;
    Element e = Element();
    e.type = ElementType.declare;
    e.start = _current; // start from <!-
    _current = _current! + m.end;
    e.end = _current;
    e.parent = _parent;
    _parent!.children.add(e);
    return true;
  }

  // _current at </
  bool _nextEndTag() {
    if (_parent == rootElement) return false;

    // TODO: change tag match

    var m = regTagEnd.firstMatch(_html.substring(_current!));
    if (m == null) return false;
    _current = _current! + m.end;
    _parent!.end = _current;
    _parent = _parent!.parent;
    _depth--;
    return true;
  }

  // _current at <xxx
  bool _nextStartTag() {
    var m = regTag.firstMatch(_html.substring(_current!));
    if (m == null) return false;

    Element e = Element();
    e.type = ElementType.tag;
    e.start = _current;
    _current = _current! + m.end;

    var s = _html.substring(e.start! + 1, _current);

    bool selfClosure = s[s.length - 2] == '/';
    if (selfClosure) e.end = _current;

    e.name = regName.stringMatch(s);
    if (e.name == null) return false;
    s = s.substring(e.name!.length);

    // parse attributes
    while (true) {
      m = regFormatting.firstMatch(s);
      if (m != null) s = s.substring(m.end);
      String? k = regName.stringMatch(s);
      if (k == null) break;
      s = s.substring(k.length);

      m = regFormatting.firstMatch(s);
      if (m != null) s = s.substring(m.end);
      if (s[0] != '=') break;
      s = s.substring(1);

      //TODO: add number values
      m = regFormatting.firstMatch(s);
      if (m != null) s = s.substring(m.end);
      String? v = regString.stringMatch(s);
      if (v == null) break;
      s = s.substring(v.length);
      v = v.substring(1, v.length - 1);
      e.attributes[k] = v;
    }

    e.parent = _parent;
    _parent!.children.add(e);
    if (!selfClosure) {
      _parent = e;
      _depth++;
    }

    return true;
  }

  // _current at first text charater
  bool _nextText() {
    var m = regText.firstMatch(_html.substring(_current!));
    if (m == null) return false;
    Element e = Element();
    e.type = ElementType.text;
    e.start = _current; // start from <!-
    _current = _current! + m.end;
    e.end = _current;
    e.name = _html.substring(e.start!, e.end);
    e.parent = _parent;
    _parent!.children.add(e);
    return true;
  }
}

class ScopeItem {
  Element element;
  int idx;
  ScopeItem(this.element, this.idx);
}

class XPath {
  static Iterable<ScopeItem> elementAllChildren(
      Match m, Element root, String? name, List<int> i) sync* {
    for (var e in root.children) {
      if (name != null && e.name != name) continue;
      yield ScopeItem(e, i[0]++);
      yield* elementAllChildren(m, e, name, i);
    }
  }

  var scope = {
    // //*
    RegExp(r'^\/\/\*'): (Match m, Element root) =>
        elementAllChildren(m, root, null, [1]),
    // //xxxx
    RegExp(r'^\/\/([a-zA-Z0-9-_]+)'): (Match m, Element root) =>
        elementAllChildren(m, root, m.group(1), [1]),
    // /*
    RegExp(r'^\/\*'): (Match m, Element root) sync* {
      int i = 1;
      for (var e in root.children) {
        yield ScopeItem(e, i++);
      }
    },
    // /text()
    RegExp(r'^\/text\(\)'): (Match m, Element root) sync* {
      int i = 1; // xpath idx starts with 1
      for (var e in root.children) {
        if (e.type != ElementType.text) continue;
        yield ScopeItem(e, i++);
      }
    },
    // /xxx
    RegExp(r'^\/([a-zA-Z0-9-_]+)'): (Match m, Element root) sync* {
      int i = 1; // xpath idx starts with 1
      String? name = m.group(1);
      for (var e in root.children) {
        if (name != e.name) continue;
        yield ScopeItem(e, i++);
      }
    },
  };

  // ignore: constant_identifier_names
  static const int _MISS = 0;
  // ignore: constant_identifier_names
  static const int _SELECT = 1;
  // ignore: constant_identifier_names
  static const int _HIT = 2;

  var selectors = {
    // [@attr="xxx"]
    RegExp(r'''^\[@([a-zA-Z0-9-_]+)=['"](.+?)['"]\]'''):
        (Match m, Element e, int i) {
      if (m.groupCount < 2) return _MISS;
      var k = m.group(1);
      var v = m.group(2);
      if (e.attributes[k!] == v) {
        return _SELECT;
      } else {
        return _MISS;
      }
    },
    // [$attr]
    RegExp(r'''^\[@([a-zA-Z0-9-_]+)\]'''): (Match m, Element e, int i) {
      if (m.groupCount < 1) return _MISS;
      var k = m.group(1);
      if (e.attributes.containsKey(k)) {
        return _SELECT;
      } else {
        return _MISS;
      }
    },
    // [2]
    RegExp(r'^\[([0-9]+)\]'): (Match m, Element e, int i) {
      if (m.groupCount < 1) return _MISS;
      int idx = int.parse(m.group(1)!);
      if (idx == i) {
        return _HIT;
      } else {
        return _MISS;
      }
    },
    // [position()>2]
    RegExp(r'^\[position\(\)>([0-9]+)\]'): (Match m, Element e, int i) {
      if (i > int.parse(m.group(1)!)) return _SELECT;
      return _MISS;
    },
    // [position()<2]
    RegExp(r'^\[position\(\)<([0-9]+)\]'): (Match m, Element e, int i) {
      if (i < int.parse(m.group(1)!)) return _SELECT;
      return _MISS;
    },
  };

  final Element _element;
  final String _xpath;

  XPath(this._element, this._xpath);

  List<Element>? parse() {
    if (_xpath[0] != '/' || _xpath[_xpath.length - 1] == '/') return null;

    var selected = <Element>{};
    selected.add(_element);
    String xpath = _xpath;

    while (xpath != '') {
      Match? scopeMatch;
      RegExp? scopeK;
      for (var k in scope.keys) {
        scopeMatch = k.firstMatch(xpath);
        if (scopeMatch != null) {
          scopeK = k;
          break;
        }
      }
      if (scopeMatch == null) {
        print("Unrecognized xpath $xpath");
        return null;
      }
      xpath = xpath.substring(scopeMatch.end);

      List<Match> selMatch = [];
      List<RegExp> selK = [];
      while (xpath != '') {
        if (xpath[0] != '[') break;
        bool hit = false;
        for (var k in selectors.keys) {
          var m = k.firstMatch(xpath);
          if (m == null) continue;
          selMatch.add(m);
          selK.add(k);
          xpath = xpath.substring(m.end);
          hit = true;
          break;
        }
        if (!hit) {
          print("unrecognized $xpath");
          return null;
        }
      }

      var curSelected = <Element>{};
      for (var root in selected) {
        for (var si in scope[scopeK!]!(scopeMatch, root)) {
          bool allPass = true;
          bool hit = false;
          for (int i = 0; i < selMatch.length; i++) {
            int r = selectors[selK[i]]!(selMatch[i], si.element, si.idx);
            if (r == _MISS) {
              allPass = false;
              break;
            }
            if (r == _HIT) {
              hit = true;
              break;
            }
          }
          if (allPass) {
            curSelected.add(si.element);
            if (hit) break;
          }
        }
      }
      selected = curSelected;
      if (selected.isEmpty) return null;
    }

    return selected.toList();
  }
}
