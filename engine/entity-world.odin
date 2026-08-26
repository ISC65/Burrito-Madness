package engine
import rl "vendor:raylib"
import "core:fmt"

EnemyClass :: enum u8 {
    Tank,
    Ranged,
    Assasin,
    Swarmer
}

AnimationClip :: struct {
  firstFrame: u32,
  finalFrame:  u32
}

//A Renderable holds Rendering Info for the Entity, allowing it to be rendered in a specific way
Renderable :: struct {
  uniqueID:       f64,
  indx:           u32,
  pos:            rl.Vector2,
  tex:            rl.Texture2D,

  isAnimated:     b32, // if the Renderable isnt animated, no need for the next fields

  sourceRec:      rl.Rectangle,
  frameDuration:  f32,
  
  animationClips: [7]AnimationClip
}

Enemy :: struct {
    hp:         f32,
    speed:      f32,

    isBoss:     b32,

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

isEntityEqual :: proc(a: Entity, b: Entity) -> bool {
  
  result: bool
  switch v in a {
    case Enemy:
      compB, ok := b.(Enemy)
      if ok {
        result = v.renderable.uniqueID == compB.renderable.uniqueID
      }
    
    case Bullet:
      compB, ok := b.(Bullet)
      if ok {
        result = v.renderable.uniqueID == compB.renderable.uniqueID
      } 
  }

  return result
}

despawnEntity :: proc(e: Entity, w: ^World) {
  switch v in e {
    case Enemy:
      if isEntityEqual(w.enemies[v.renderable.indx], {}) {
        return
      }
      w.enemies[v.renderable.indx] = {}


    case Bullet:
      if isEntityEqual(w.bullets[v.renderable.indx], {}) {
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

        maxFrames : u32 = cast(u32)(checkX + checkY) - 2

        frameTimer : f32
        currFrame : u32

        if !e.renderable.isAnimated || isEntityEqual(e, Enemy{}) {
            continue
        }
        else {
            frameTimer += dt

            if checkX == 1 && checkY == 1 { continue }

            if cast(i32)e.renderable.sourceRec.x > maxX && checkY > 1{
                e.renderable.sourceRec.y += e.renderable.sourceRec.height
            }


            if cast(i32)e.renderable.sourceRec.y > maxY {
                e.renderable.sourceRec.x = 0
                e.renderable.sourceRec.y = 0
                currFrame = 0
            }


            if frameTimer >= e.renderable.frameDuration {
                frameTimer = 0
                currFrame += 1
                e.renderable.sourceRec.x = e.renderable.sourceRec.width * cast(f32)currFrame
            }

            if currFrame > maxFrames {
                currFrame = 0
            }
        }
    }


    for &b in w.bullets {

        maxX := b.renderable.tex.width
        maxY := b.renderable.tex.height

        checkX := cast(f32)b.renderable.tex.width / b.renderable.sourceRec.width
        checkY := cast(f32)b.renderable.tex.height / b.renderable.sourceRec.height

        maxFrames : u32 = cast(u32)(checkX + checkY) - 2

        frameTimer : f32
        currFrame : u32
        
        if !b.renderable.isAnimated || isEntityEqual(b, Bullet{}) {
            continue
        }
        else {
            frameTimer += dt

            if checkX == 1 && checkY == 1 { continue }

            if cast(i32)b.renderable.sourceRec.x > maxX && checkY > 1{
                b.renderable.sourceRec.y += b.renderable.sourceRec.height
            }


            if cast(i32)b.renderable.sourceRec.y > maxY {
                b.renderable.sourceRec.x = 0
                b.renderable.sourceRec.y = 0
                currFrame = 0
            }


            if frameTimer >= b.renderable.frameDuration {
                frameTimer = 0
                currFrame += 1
                b.renderable.sourceRec.x = b.renderable.sourceRec.width * cast(f32)currFrame
            }

            if currFrame > maxFrames {
                currFrame = 0
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
