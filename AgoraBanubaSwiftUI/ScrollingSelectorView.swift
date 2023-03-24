//
//  ScrollingSelectorView.swift
//  SwiftUICanvasView
//
//  Created by Max Cobb on 24/03/2023.
//

import SwiftUI

/// View to display all the available effects.
struct ScrollingSelectorView: View {
    let effectNames: [String]
    var selectButtons: (String?) -> Void
    @State private var selectedEffect: String?
    var body: some View {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    if !effectNames.isEmpty {
                        Button {
                            selectButtons(nil)
                            selectedEffect = nil
                        } label: {
                            Image(systemName: "square.3.layers.3d.slash")
                                .resizable().frame(width: 50, height: 50).padding(8)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(selectedEffect == nil ? .orange : .secondary)
                                    .shadow(radius: 2))
                        }
                        ForEach(effectNames, id: \.self) { effectName in
                            Button {
                                selectButtons(effectName)
                                selectedEffect = effectName
                            } label: {
                                (EffectsService.getEffectPreview(effectName)
                                 ?? Image(systemName: "questionmark.square.dashed")
                                ).resizable().frame(width: 50, height: 50).padding(8)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(selectedEffect == effectName ? .orange : .secondary)
                                        .shadow(radius: 2))
                            }

                        }
                    }
                }.padding(4)
            }
    }
}

struct ScrollingSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollingSelectorView(effectNames: ["ActionunitsGrout", "test_Glasses"]) { effectName in
            if let effectName {
                print(effectName)
            }
        }
    }
}
