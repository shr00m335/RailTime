class DatabaseUtils {
  /// A function to generate ? placeholder for query
  ///
  /// Return ?,?,? if [params] provided has 3 elements
  static String generateInParameters(List<dynamic> params) {
    return params.map((_) => '?').join(',');
  }
}
