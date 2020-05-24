import 'project_interface.dart';
class Project implements ProjectInterface {
  String _name;
  Project(String name) {
    this._name = name;
  }
  String getName() {
    return _name;
  }
}