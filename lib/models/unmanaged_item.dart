class UnmanagedItem {
  int id;
  String name;
  DateTime dateCreated;

  UnmanagedItem();

  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.dateCreated = DateTime.parse(map['date_created']);
  }

  setName(String newName) {
    this.name = newName;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name':this.name
    };
    if (id != null) {
      map['id'] = this.id;
    }
    if (this.dateCreated != null) {
      map['date_created'] = this.dateCreated;
    } else {
      map['date_created'] = DateTime.now().toIso8601String();
    }
    return map;
  }
}