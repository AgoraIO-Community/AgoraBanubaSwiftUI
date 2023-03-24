//
//  AgoraBanubaExtensionView.swift
//  SwiftUICanvasView
//
//  Created by Max Cobb on 24/03/2023.
//

import SwiftUI
import AgoraRtcKit
import BanubaFiltersAgoraExtension
import AgoraVideoSwiftUI

struct AgoraBanubaExtensionView: View {
    @ObservedObject var agoraManager = AgoraManagerBanuba(appId: AppKeys.agoraAppKey, role: .broadcaster)
    @State private var channelId: String = ""
    @State private var isShowingChannelIdInput = true

    var body: some View {
        VStack {
            // Scrolling list of the local camera feed + remote ones
            ScrollView {
                VStack {
                    ForEach(Array(agoraManager.allUsers), id: \.self) { uid in
                        AgoraVideoCanvasView(agoraKit: agoraManager.engine, uid: uid)
                            .aspectRatio(contentMode: .fit).cornerRadius(10)
                            .shadow(color: uid == 0 ? .white : .clear, radius: 5)
                    }
                }.padding(20)
            }
            // Scrolling list for all the effects
            ScrollingSelectorView(effectNames: EffectsService.getEffectNames()) { effectName in
                agoraManager.engine.setExtensionPropertyWithVendor(
                    BNBKeyVendorName,
                    extension: BNBKeyExtensionName,
                    key: effectName == nil ? BNBKeyUnloadEffect : BNBKeyLoadEffect,
                    value: effectName ?? " "
                )
            }
        }.sheet(isPresented: $isShowingChannelIdInput, content: {
            // Sheet to enter the channel ID
            VStack {
                TextField("Enter channel id", text: $channelId)
                    .padding()

                Button("Submit") {
                    if channelId.isEmpty { return }
                    self.setupBanuba()
                    agoraManager.engine.joinChannel(
                        byToken: AppKeys.agoraToken, channelId: channelId, info: nil, uid: 0
                    )
                    isShowingChannelIdInput = false
                }
                .padding()
            }.interactiveDismissDisabled()
        }).onDisappear {
            agoraManager.engine.leaveChannel()
        }
    }
    /// Enable Banuba, set the effects path, and the token.
    func setupBanuba() {
        agoraManager.engine.enableExtension(
            withVendor: BNBKeyVendorName, extension: BNBKeyExtensionName, enabled: true
        )
        agoraManager.engine.setExtensionPropertyWithVendor(
            BNBKeyVendorName, extension: BNBKeyExtensionName,
            key: BNBKeySetEffectsPath, value: EffectsService.effectsURL.path()
        )
        agoraManager.engine.setExtensionPropertyWithVendor(
            BNBKeyVendorName, extension: BNBKeyExtensionName,
            key: BNBKeySetBanubaLicenseToken, value: AppKeys.banubaToken
        )
    }
}

/// This subclass adds and removes from a set for all the local and remote users.
class AgoraManagerBanuba: AgoraManager {
    @Published var allUsers: Set<UInt> = []
    override func leaveChannel(leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil) {
        self.allUsers.removeAll()
        super.leaveChannel(leaveChannelBlock: leaveChannelBlock)
    }
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

struct AgoraBanubaExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        AgoraBanubaExtensionView()
    }
}
