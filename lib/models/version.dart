class VersionModel {
  String tagName; // 版本号
  List assets; // 资源
  String body; // 更新日志

  VersionModel(
    this.tagName,
    this.assets,
    this.body,
  );

  VersionModel.fromJson(Map<String, dynamic> json)
      : tagName = json['tag_name'],
        assets = json['assets'],
        body = json['body'];

  Map<String, dynamic> toJson() =>
      {'tag_name': tagName, 'assets': assets, 'body': body};
}
