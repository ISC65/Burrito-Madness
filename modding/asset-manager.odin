package modding
import "core:encoding/json"

AnimationClip :: struct {
    animationAngle: string,
    startFrame: u32,
    endFrame: u32
}

AssetDef :: struct {
    id: string,
    name: string,

    spriteSheetPath: string,
    frameWidth: f32,
    frameHeight: f32,
    frameDuration: f32,

    clips: [dynamic]AnimationClip
}

Registries :: struct {

}

// initRegistries :: proc
AssetRegistry := make(#soa[dynamic]AssetDef)

registerAssetJson :: proc(jsonPath: string) {



}
