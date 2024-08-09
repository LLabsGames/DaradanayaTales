import Foundation
import SwiftGodot
import SwiftGodotKit
import DaradanayaDriver

guard let packPath = Bundle.module.path(forResource: "DaradanayaDriver", ofType: "pck") else {
    fatalError("Could not load Pack")
}

func loadScene (scene: SceneTree) {
    scene.root?.addChild(node: TempIcon2D())
}

func registerTypes (level: GDExtension.InitializationLevel) {
    switch level {
    case .scene:
        DaradanayaDriver.godotTypes.forEach { register(type: $0) }
    default:
        break
    }
}

runGodot(
    args: [
        "--main-pack", packPath,
        "--rendering-method", "mobile"
    ],
    initHook: registerTypes,
    loadScene: loadScene,
    loadProjectSettings: { settings in }
)
