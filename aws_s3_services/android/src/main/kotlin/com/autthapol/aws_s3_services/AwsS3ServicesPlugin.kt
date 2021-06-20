package com.autthapol.aws_s3_services

import android.content.Context
import androidx.annotation.NonNull
import com.amazonaws.auth.BasicAWSCredentials
import com.amazonaws.event.ProgressEvent
import com.amazonaws.regions.Region
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.services.s3.model.DeleteObjectRequest
import com.amazonaws.services.s3.model.DeleteObjectsRequest
import com.amazonaws.services.s3.model.PutObjectRequest

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** AwsS3ServicesPlugin */
class AwsS3ServicesPlugin : FlutterPlugin, MethodCallHandler {
    private val CHANNEL_NAME = "aws_s3"

    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
          "putObject" -> putObject(call, result)
          "deleteObject" -> deleteObject(call, result)
          "deleteObjects" -> deleteObjects(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun putObject(call: MethodCall, result: Result) {
        val configs = call.argument<Map<String, String>>("configs")
        val credentials = call.argument<Map<String, String>>("credentials")
        val key = call.argument<String>("key")
        val path = call.argument<String>("path")

        val region = configs?.get("Region")
        val bucket = configs?.get("Bucket")

        val accessKey = credentials?.get("AccessKey")
        val secretKey = credentials?.get("SecretKey")

        try {
            if (path != null) {
                val s3Client = AmazonS3Client(BasicAWSCredentials(accessKey, secretKey), Region.getRegion(region))
                val request = PutObjectRequest(bucket, key, File(path))
                        .withGeneralProgressListener { event ->
                            if (event.eventCode == ProgressEvent.COMPLETED_EVENT_CODE) {
                                result.success(true)
                            }
                        }
                s3Client.putObject(request)
            }
        } catch (ex: Exception) {
            result.error("PUT_OBJECT_ERROR", ex.message, ex)
        }
    }

    private fun deleteObject(call: MethodCall, result: Result) {
        val configs = call.argument<Map<String, String>>("configs")
        val credentials = call.argument<Map<String, String>>("credentials")
        val key = call.argument<String>("key")

        val region = configs?.get("Region")
        val bucket = configs?.get("Bucket")

        val accessKey = credentials?.get("AccessKey")
        val secretKey = credentials?.get("SecretKey")

        try {
            val s3Client = AmazonS3Client(BasicAWSCredentials(accessKey, secretKey), Region.getRegion(region))
            val request = DeleteObjectRequest(bucket, key)
            s3Client.deleteObject(request)
            result.success(true)
        } catch (ex: Exception) {
            result.error("DELETE_OBJECT_ERROR", ex.message, ex)
        }
    }

    private fun deleteObjects(call: MethodCall, result: Result) {
        val configs = call.argument<Map<String, String>>("configs")
        val credentials = call.argument<Map<String, String>>("credentials")
        val prefix = call.argument<String>("prefix")

        val region = configs?.get("Region")
        val bucket = configs?.get("Bucket")

        val accessKey = credentials?.get("AccessKey")
        val secretKey = credentials?.get("SecretKey")

        try {
            val s3Client = AmazonS3Client(BasicAWSCredentials(accessKey, secretKey), Region.getRegion(region))
            val objectListing = s3Client.listObjects(bucket, prefix)
            val keys = objectListing.objectSummaries.map { objectSummary ->
                DeleteObjectsRequest.KeyVersion(objectSummary.key)
            }
            val request = DeleteObjectsRequest(bucket)
                    .withKeys(keys)
            s3Client.deleteObjects(request)
            result.success(true)
        } catch (ex: Exception) {
            result.error("DELETE_OBJECTS_ERROR", ex.message, ex)
        }
    }
}
