//
//  AgoraBanubaExtensionView.swift
//  SwiftUICanvasView
//
//  Created by Max Cobb on 24/03/2023.
//

import SwiftUI
import AgoraRtcKit
import BanubaFiltersAgoraExtension
import SwiftUIRtc

struct AgoraBanubaExtensionView: View {
    @ObservedObject var agoraManager = AgoraManager(appId: AppKeys.agoraAppKey, role: .broadcaster)
    @State private var channelId: String = ""
    @State private var isShowingChannelIdInput = true

    var body: some View {
        VStack {
            // Scrolling list of the local camera feed + remote ones
            ScrollView {
                VStack {
                    ForEach(Array(agoraManager.allUsers), id: \.self) { uid in
                        AgoraVideoCanvasView(
                            manager: self.agoraManager, uid: uid
                        ).aspectRatio(contentMode: .fit).cornerRadius(10)
                            .shadow(color: uid == 0 ? .white : .clear, radius: 5)
                    }
                }.padding(20)
            }
            // Scrolling list for all the effects
            ScrollingSelectorView(effectNames: EffectsService.getEffectNames()) { effectName in
                agoraManager.agoraEngine.setExtensionPropertyWithVendor(
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
                    agoraManager.agoraEngine.joinChannel(
                        byToken: AppKeys.agoraToken, channelId: channelId, info: nil, uid: 0
                    )
                    isShowingChannelIdInput = false
                }
                .padding()
            }.interactiveDismissDisabled()
        }).onDisappear {
            agoraManager.agoraEngine.leaveChannel()
        }
    }
    /// Enable Banuba, set the effects path, and the token.
    func setupBanuba() {
        agoraManager.agoraEngine.enableExtension(
            withVendor: BNBKeyVendorName, extension: BNBKeyExtensionName, enabled: true
        )
        agoraManager.agoraEngine.setExtensionPropertyWithVendor(
            BNBKeyVendorName, extension: BNBKeyExtensionName,
            key: BNBKeySetEffectsPath, value: EffectsService.effectsURL.path()
        )
        agoraManager.agoraEngine.setExtensionPropertyWithVendor(
            BNBKeyVendorName, extension: BNBKeyExtensionName,
            key: BNBKeySetBanubaLicenseToken, value: AppKeys.banubaToken
        )
    }
}

struct AgoraBanubaExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        AgoraBanubaExtensionView()
    }
}
