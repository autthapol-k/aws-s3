import 'package:aws_s3_platform_interface/aws_s3_platform_interface.dart';

class AwsS3Services {
  static Future<bool> putObject({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String key,
    required String path,
  }) {
    return AwsS3Platform.instance.putObject(
      configs: configs,
      credentials: credentials,
      key: key,
      path: path,
    );
  }

  static Future<bool> deleteObject({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String key,
  }) {
    return AwsS3Platform.instance.deleteObject(
      configs: configs,
      credentials: credentials,
      key: key,
    );
  }

  static Future<bool> deleteObjects({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String prefix,
  }) {
    return AwsS3Platform.instance.deleteObjects(
      configs: configs,
      credentials: credentials,
      prefix: prefix,
    );
  }
}
