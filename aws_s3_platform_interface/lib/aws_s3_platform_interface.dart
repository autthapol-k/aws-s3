import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_aws_s3_platform.dart';

abstract class AwsS3Platform extends PlatformInterface {
  AwsS3Platform() : super(token: _token);

  static final Object _token = Object();

  static AwsS3Platform _instance = MethodChannelAwsS3();

  static AwsS3Platform get instance => _instance;

  static set instance(AwsS3Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> putObject({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String key,
    required String path,
  }) {
    throw UnimplementedError('putObject() has not been implemented.');
  }

  Future<bool> deleteObject({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String key,
  }) {
    throw UnimplementedError('deleteObject() has not been implemented.');
  }

  Future<bool> deleteObjects({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String prefix,
  }) {
    throw UnimplementedError('deleteObjects() has not been implemented.');
  }
}
