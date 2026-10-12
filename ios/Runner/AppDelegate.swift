import Flutter
import UIKit
import PushKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, FlutterImplicitEngineDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    registerForVoIPPushNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // PushKit Registration
  private func registerForVoIPPushNotifications() {
    let mainQueue = DispatchQueue.main
    let pushRegistry = PKPushRegistry(queue: mainQueue)
    pushRegistry.delegate = self
    pushRegistry.desiredPushTypes = [.voIP]
  }

  // PKPushRegistryDelegate callback for credentials/token update
  func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
    print("[debug_pushkit] VoIP Push Token: \(token)")
  }

  // PKPushRegistryDelegate callback for incoming VoIP push
  func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
    let dict = payload.dictionaryPayload
    
    let callerName = dict["caller_name"] as? String ?? "Someone"
    let callId = dict["call_id"] as? String ?? "0"
    let callType = dict["call_type"] as? String ?? "voice"
    let channelName = dict["channel_name"] as? String ?? ""
    let token = dict["agora_token"] as? String ?? ""
    let avatar = dict["caller_avatar"] as? String ?? ""
    
    let callKitData: [String: Any] = [
      "id": callId,
      "nameCaller": callerName,
      "appName": "Heartmate",
      "avatar": avatar,
      "type": callType == "video" ? 1 : 0, // 0 = audio, 1 = video
      "duration": 30000,
      "extra": [
        "channel_name": channelName,
        "agora_token": token,
        "call_id": callId
      ]
    ]
    
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(callKitData, fromPushKit: true)
    completion()
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    print("[debug_pushkit] VoIP Push Token invalidated")
  }
}
