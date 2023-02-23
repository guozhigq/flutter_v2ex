class NodeItem {
  int? id = 0;
  int? stars = 0;
  int? topics = 0; // 主题数
  String? url = '';
  String? name = ''; // 节点名
  String? title = ''; // 展示使用
  bool? root = false; // 是否父节点
  String? header = ''; // 节点
  String? footer = '';
  String? avatarMini = '';
  String? avatarLarge = '';
  String? avatarNormal = '';
  String? parentNodeName = ''; // 父节点名
  String? titleAlternative = ''; // 好像没什么用

  NodeItem({
    this.id,
    this.stars,
    this.topics,
    this.url,
    this.name,
    this.title,
    this.root,
    this.header,
    this.footer,
    this.avatarMini,
    this.avatarLarge,
    this.avatarNormal,
    this.parentNodeName,
    this.titleAlternative,
  });

  NodeItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stars = json['stars'];
    topics = json['topics'];
    url = json['url'];
    name = json['name'];
    title = json['title'];
    root = json['root'];
    header = json['header'];
    footer = json['footer'];
    avatarMini = json['avatar_mini'];
    avatarLarge = json['avatar_large'];
    avatarNormal = json['avatar_normal'];
    parentNodeName = json['parent_node_name'];
    titleAlternative = json['title_alternative'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['stars'] = stars;
    data['topics'] = topics;
    data['url'] = url;
    data['name'] = name;
    data['title'] = title;
    data['root'] = root;
    data['header'] = header;
    data['footer'] = footer;
    data['avatar_mini'] = avatarMini;
    data['avatar_large'] = avatarLarge;
    data['avatar_normal'] = avatarNormal;
    data['parent_node_name'] = parentNodeName;
    data['title_alternative'] = titleAlternative;
    return data;
  }

}
