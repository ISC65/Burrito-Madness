package engine
import rl "vendor:raylib"
import "core:fmt"

EnemyClass :: enum {
    Tank,
    Ranged,
    Assasin,
    Swarmer
}

// A Renderable holds Rendering Info for the Entity, allowing it to be rendered in a specific way
Renderable :: struct {
  indx:          u32,
  pos:            rl.Vector2,
  tex:            rl.Texture2D,

  isAnimated:     bool, // if the Renderable isnt animated, no need for the next fields

  sourceRec:      rl.Rectangle,
  frameDuration:  f32,
  frameTimer:     f32,
  currFrame:      i32,
}

Enemy :: struct {
    hp:         f32,
    speed:      f32,

    isBoss:     bool,

    class:      EnemyClass,
    renderable: Renderable
}

Bullet :: struct {
    vel:        rl.Vector2,
    lifespan:   f32,

    renderable: Renderable
}

Entity :: union {
    Bullet,
    Enemy,
}

World :: struct {
    maxEntities:    u32,
    enemies:        #soa[dynamic]Enemy,
    bullets:        #soa[dynamic]Bullet
}

initWorld :: proc(initialMax: u32 = 2000) -> World {
    w: World

    w.maxEntities = initialMax
    w.enemies = make(#soa[dynamic]Enemy, w.maxEntities)
    w.bullets = make(#soa[dynamic]Bullet, w.maxEntities)

    return w
}

despawnAllEntities :: proc(w: ^World) {
    for &e in w.enemies {
      e = {}
    }

    for &b in w.bullets {
      b = {}
    }
}

despawnEntity :: proc(e: Entity, w: ^World) {
  switch v in e {
    case Enemy:
      if w.enemies[v.renderable.indx] == {} {
        return
      }
      w.enemies[v.renderable.indx] = {}


    case Bullet:
      if w.bullets[v.renderable.indx] == {} {
        return
      }
      w.bullets[v.renderable.indx] = {}

  }
}

spawnEntity :: proc(e: Entity, w: ^World) {
    e := e

    switch v in e {
        case Enemy:
            append(&w.enemies, v)

        case Bullet:
            append(&w.bullets, v)
    }



    fmt.println("Spawned New Entity")
}

updateRenderables :: proc(dt: f32, w: ^World) {
    for &e in w.enemies {

        maxX := e.renderable.tex.width
        maxY := e.renderable.tex.height

        checkX := cast(f32)e.renderable.tex.width / e.renderable.sourceRec.width
        checkY := cast(f32)e.renderable.tex.height / e.renderable.sourceRec.height

        maxFrames : i32 = cast(i32)(checkX + checkY) - 2

        if !e.renderable.isAnimated || e == {} {
            continue
        }
        else {
            e.renderable.frameTimer += dt

            if checkX == 1 && checkY == 1 { continue }

            if cast(i32)e.renderable.sourceRec.x > maxX && checkY > 1{
                e.renderable.sourceRec.y += e.renderable.sourceRec.height
            }


            if cast(i32)e.renderable.sourceRec.y > maxY {
                e.renderable.sourceRec.x = 0
                e.renderable.sourceRec.y = 0
                e.renderable.currFrame = 0
            }


            if e.renderable.frameTimer >= e.renderable.frameDuration {
                e.renderable.frameTimer = 0
                e.renderable.sourceRec.x += e.renderable.sourceRec.width
                e.renderable.currFrame += 1
            }

            if e.renderable.currFrame > maxFrames {
                e.renderable.currFrame = 0
            }
        }
    }


    for &b in w.bullets {

        maxX := b.renderable.tex.width
        maxY := b.renderable.tex.height

        checkX := cast(f32)b.renderable.tex.width / b.renderable.sourceRec.width
        checkY := cast(f32)b.renderable.tex.height / b.renderable.sourceRec.height

        maxFrames : i32 = cast(i32)(checkX + checkY) - 2

        if !b.renderable.isAnimated || b == {} {
            continue
        }
        else {
            b.renderable.frameTimer += dt

            if checkX == 1 && checkY == 1 { continue }

            if cast(i32)b.renderable.sourceRec.x > maxX && checkY > 1{
                b.renderable.sourceRec.y += b.renderable.sourceRec.height
            }


            if cast(i32)b.renderable.sourceRec.y > maxY {
                b.renderable.sourceRec.x = 0
                b.renderable.sourceRec.y = 0
                b.renderable.currFrame = 0
            }


            if b.renderable.frameTimer >= b.renderable.frameDuration {
                b.renderable.frameTimer = 0
                b.renderable.sourceRec.x += b.renderable.sourceRec.width
                b.renderable.currFrame += 1
            }

            if b.renderable.currFrame > maxFrames {
                b.renderable.currFrame = 0
            }
        }
    }
}

drawRenderables :: proc(w: ^World) {
    for e in w.enemies {
        if !e.renderable.isAnimated {
            rl.DrawTextureV(e.renderable.tex, e.renderable.pos, rl.WHITE)
        }
        else {
            rl.DrawTextureRec(e.renderable.tex, e.renderable.sourceRec, e.renderable.pos, rl.WHITE)
        }

    }

    for b in w.bullets {
      if !b.renderable.isAnimated {
        rl.DrawTextureV(b.renderable.tex, b.renderable.pos, rl.WHITE)
      }
      else {
        rl.DrawTextureRec(b.renderable.tex, b.renderable.sourceRec, b.renderable.pos, rl.WHITE)
      }
    }
}
