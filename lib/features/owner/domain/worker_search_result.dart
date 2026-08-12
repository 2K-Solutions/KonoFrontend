class WorkerSearchResult {
  const WorkerSearchResult({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.secondName,
  });

  factory WorkerSearchResult.fromJson(Map<String, dynamic> json) {
    return WorkerSearchResult(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      secondName: json['secondName'] as String,
    );
  }

  final String id;
  final String email;
  final String username;
  final String firstName;
  final String secondName;
}
