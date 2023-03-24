//
//  EffectsService.swift
//  SwiftUICanvasView
//
//  Created by Max Cobb on 24/03/2023.
//

import UIKit
import SwiftUI

class EffectsService {
    static var effectsURL: URL {
        Bundle.main.bundleURL.appendingPathComponent("\(AppKeys.effectsPath)/", isDirectory: true)
    }

    static func getEffectNames() -> [String] {
        do {
            let path = effectsURL.path()
            let directoryContents = try FileManager.default.contentsOfDirectory(at: effectsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            return directoryContents.compactMap { $0.hasDirectoryPath ? $0.lastPathComponent : nil }
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    static func getEffectPreview(_ effectName: String) -> Image? {
        let path = effectsURL.path()
        let previewPath = "\(path)/\(effectName)/preview.png"
        guard let uiimg = UIImage(contentsOfFile: previewPath) else {
            return nil
        }
        return Image(uiImage: uiimg)
    }
}
