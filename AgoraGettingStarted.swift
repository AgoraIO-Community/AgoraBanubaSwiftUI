import SwiftUI
import AgoraRtcKit

struct AgoraGettingStartedView: View {
    @ObservedObject var agoraManager = AgoraManager()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(Array(agoraManager.allUsers), id: \.self) { uid in
                    AgoraVideoCanvasView(agoraKit: agoraManager.engine, uid: uid)
                        .aspectRatio(contentMode: .fit).cornerRadius(10)
                }
            }.padding(20)
            .onAppear {
                agoraManager.engine.joinChannel(
                    byToken: nil, channelId: "test", info: nil, uid: 0
                )
            }
        }
    }
}

class AgoraManager: NSObject, ObservableObject {
    var role = AgoraClientRole.broadcaster
    var engine: AgoraRtcEngineKit {
        let eng = AgoraRtcEngineKit.sharedEngine(
            withAppId: "8352fcb6592c48c0bf0e7fc721e2bbbf", delegate: self
        )
        eng.enableVideo()
        eng.setClientRole(role)
        return eng
    }
    @Published var allUsers: Set<UInt> = []
}

extension AgoraManager: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        self.allUsers.insert(0)
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        self.allUsers.insert(uid)
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.allUsers.remove(uid)
    }
}

struct AgoraVideoCanvasView: UIViewRepresentable {
    @StateObject var canvas = AgoraRtcVideoCanvas()
    weak var agoraKit: AgoraRtcEngineKit?
    let uid: UInt
    func makeUIView(context: Context) -> UIView {
        // Create and return the remote video view
        let canvasView = UIView()
        canvas.view = canvasView
        canvas.uid = uid
        if self.uid == 0 {
            // Start the local video preview
            agoraKit?.startPreview()
            agoraKit?.setupLocalVideo(canvas)
        } else {
            agoraKit?.setupRemoteVideo(canvas)
        }
        return canvasView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
