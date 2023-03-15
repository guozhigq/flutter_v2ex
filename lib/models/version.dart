class VersionModel {
  String tag_name; // 版本号
  List assets; // 资源
  String body; // 更新日志

  VersionModel(
      this.tag_name,
      this.assets,
      this.body,
  );

  VersionModel.fromJson(Map<String, dynamic> json)
      : tag_name = json['tag_name'],
        assets = json['assets'],
        body = json['body'];

  Map<String, dynamic> toJson() =>
      {'tag_name': tag_name, 'assets': assets, 'body': body};
}
