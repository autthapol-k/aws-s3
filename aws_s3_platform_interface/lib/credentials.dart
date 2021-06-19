abstract class Credentials {
  final String accessKey;
  final String secretKey;
  final String sessionToken;

  Credentials({
    required this.accessKey,
    required this.secretKey,
    required this.sessionToken,
  });
}
