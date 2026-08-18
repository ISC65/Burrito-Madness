package main

import "core:fmt"
import rl "vendor:raylib"
import en "engine"

scrW :: 640
scrH :: 480

setup :: proc(world: ^en.World) {
    fmt.println("Doing")
    for i : u32 = 0; i < 2000; i += 1 {
        fmt.println("Spawning")

        en.spawnEntity(en.Enemy{hp = 100, speed = 20, class = en.EnemyClass.Tank, renderable = en.Renderable{
            i,
            rl.Vector2{cast(f32)rl.GetRandomValue(0, 300), cast(f32)rl.GetRandomValue(0, 300)},
            rl.LoadTexture("assets/spritesheet Prototype.png"),
            true,
            rl.Rectangle{0, 0, 32, 32},
            0.3,
            0,
            0
        }}, world)
    }
}


main :: proc() {
    rl.InitWindow(scrW, scrH, "Entity Demo")
    rl.SetTargetFPS(60)

    w: en.World = en.initWorld()

    setup(&w)

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        en.updateRenderables(dt, &w)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLANK)
        en.drawRenderables(&w)
        rl.EndDrawing()
    }

}



