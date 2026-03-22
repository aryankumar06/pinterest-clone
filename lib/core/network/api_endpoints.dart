/// Pexels API endpoint paths.
class ApiEndpoints {
  ApiEndpoints._();

  static const String curated = '/curated';
  static const String search = '/search';
  static String photo(int id) => '/photos/$id';
}
