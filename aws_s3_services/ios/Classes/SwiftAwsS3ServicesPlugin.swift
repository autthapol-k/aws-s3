import Flutter
import UIKit
import AWSS3

public class SwiftAwsS3ServicesPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "aws_s3", binaryMessenger: registrar.messenger())
        let instance = SwiftAwsS3ServicesPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method{
        case "putObject":
            self.putObject(call: call, result: result)
        case "deleteObject":
            self.deleteObject(call: call, result: result)
        case "deleteObjects":
            self.deleteObjects(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func putObject(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        
        let configs = args?["configs"] as? Dictionary<String, String>
        let credentials = args?["credentials"] as? Dictionary<String, String>
        let key = args?["key"] as? String
        let path = args?["path"] as? String
    
        let region = AWSRegionType.regionType(regionString: configs?["Region"] ?? "")
        let bucket = configs?["Bucket"]
        
        if let accessKey = credentials?["AccessKey"], let secretKey = credentials?["SecretKey"]{
            let credentialsProvider = AWSStaticCredentialsProvider.init(accessKey: accessKey, secretKey: secretKey)
            let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
        }
        
        let request = AWSS3PutObjectRequest()
        request?.bucket = bucket
        request?.key = key
        if let path = path {
            let url = URL(fileURLWithPath: path)
            request?.body = url
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                let size = attributes[FileAttributeKey.size] as! UInt64
                request?.contentLength = NSNumber(value: size)
            } catch _ as NSError {
                result(false)
            }
        }
        
        DispatchQueue.main.async {
            if let request = request {
                AWSS3.default().putObject(request).continueWith { (task: AWSTask<AWSS3PutObjectOutput>) -> Any? in
                    result(task.isCompleted)
                }.waitUntilFinished()
            } else {
                result(false)
            }
        }
    }
        
    private func deleteObject(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        
        let configs = args?["configs"] as? Dictionary<String, String>
        let credentials = args?["credentials"] as? Dictionary<String, String>
        let key = args?["key"] as? String
    
        let region = AWSRegionType.regionType(regionString: configs?["Region"] ?? "")
        let bucket = configs?["Bucket"]
        
        if let accessKey = credentials?["AccessKey"], let secretKey = credentials?["SecretKey"]{
            let credentialsProvider = AWSStaticCredentialsProvider.init(accessKey: accessKey, secretKey: secretKey)
            let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
        }
        
        let request = AWSS3DeleteObjectRequest()
        request?.bucket = bucket
        request?.key = key
        
        DispatchQueue.main.async {
            if let request = request {
                AWSS3.default().deleteObject(request).continueWith { (task: AWSTask<AWSS3DeleteObjectOutput>) -> Any? in
                    result(task.isCompleted)
                }.waitUntilFinished()
            } else {
                result(false)
            }
        }
    }
    
    private func deleteObjects(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        
        let configs = args?["configs"] as? Dictionary<String, String>
        let credentials = args?["credentials"] as? Dictionary<String, String>
        let prefix = args?["prefix"] as? String
    
        let region = AWSRegionType.regionType(regionString: configs?["Region"] ?? "")
        let bucket = configs?["Bucket"]
        
        if let accessKey = credentials?["AccessKey"], let secretKey = credentials?["SecretKey"]{
            let credentialsProvider = AWSStaticCredentialsProvider.init(accessKey: accessKey, secretKey: secretKey)
            let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
        }
        
        let client = AWSS3.default()
        let request = AWSS3ListObjectsRequest()
        request?.bucket = bucket
        request?.prefix = prefix
        
        DispatchQueue.main.async {
            if let request = request {
                client.listObjects(request).continueOnSuccessWith { (task: AWSTask<AWSS3ListObjectsOutput>) -> Any? in
                    let objects = task.result?.contents?.compactMap({ (object: AWSS3Object) -> AWSS3ObjectIdentifier? in
                        let identifier = AWSS3ObjectIdentifier()
                        identifier?.key = object.key
                        return identifier
                    })
                    
                    if let objects = objects {
                        let request = AWSS3DeleteObjectsRequest()
                        request?.bucket = bucket
                        let remove = AWSS3Remove()
                        remove?.objects = objects
                        request?.remove = remove
                        
                        if let request = request {
                            client.deleteObjects(request).continueWith { (task: AWSTask<AWSS3DeleteObjectsOutput>) -> Any? in
                                result(task.isCompleted)
                            }.waitUntilFinished()
                        } else {
                            result(false)
                        }
                    } else {
                        result(false)
                    }
                    
                    return objects
                }
            } else {
                result(false)
            }
        }
    }
}

extension AWSRegionType {
    static func regionType(regionString: String) -> AWSRegionType {
        switch regionString {
            case "us-east-1": return .USEast1
            case "us-west-1": return .USWest1
            case "us-west-2": return .USWest2
            case "eu-west-1": return .EUWest1
            case "eu-central-1": return .EUCentral1
            case "ap-northeast-1": return .APNortheast1
            case "ap-northeast-2": return .APNortheast2
            case "ap-southeast-1": return .APSoutheast1
            case "ap-southeast-2": return .APSoutheast2
            case "sa-east-1": return .SAEast1
            case "cn-north-1": return .CNNorth1
            case "us-gov-west-1": return .USGovWest1
            default: return .Unknown
        }
    }
}
