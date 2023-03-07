class TabModel {
  String name;
  String id;
  String type;
  bool checked;

  TabModel(this.name, this.id, this.type, this.checked);

  TabModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        type = json['type'],
        checked = json['checked'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'id': id, 'type': type, 'checked': checked};
}
