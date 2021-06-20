import 'package:flutter/services.dart';

import 'aws_s3_platform_interface.dart';

class MethodChannelAwsS3 extends AwsS3Platform {
  final MethodChannel channel = MethodChannel('aws_s3');

  @override
  Future<bool> putObject({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String key,
    required String path,
  }) async {
    return (await channel.invokeMethod<bool>('putObject'))!;
  }

  @override
  Future<bool> deleteObject({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String key,
  }) async {
    return (await channel.invokeMethod<bool>('deleteObject'))!;
  }

  @override
  Future<bool> deleteObjects({
    required Map<String, String> configs,
    required Map<String, String> credentials,
    required String prefix,
  }) async {
    return (await channel.invokeMethod<bool>('deleteObjects'))!;
  }
}
