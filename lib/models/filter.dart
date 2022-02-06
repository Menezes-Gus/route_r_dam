class Filter {
  final String columnName;
  final List<dynamic> filterArgs;
  final bool _useLike;
  String conector = ' LIKE ';

  Filter(this.columnName, this.filterArgs, this._useLike) {
    if (_useLike) {
      conector = ' LIKE ';
    } else {
      conector = ' = ';
    }
  }
}
