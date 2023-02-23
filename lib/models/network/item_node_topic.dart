class TopicNodeItem {
  int? topics = 0;
  List? aliases =  [];
  String? name = "";
  String? title =  "";

  TopicNodeItem({
    this.topics,
    this.aliases,
    this.name,
    this.title,
  });

  TopicNodeItem.fromJson(Map<String, dynamic> json) {
    topics = json['topics'];
    aliases =  json['aliases'];
    name = json['name'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['topics'] = topics;
    data['aliases'] = aliases;
    data['name'] = name;
    data['title'] = title;

    return data;
  }

}
