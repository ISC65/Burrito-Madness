package modding
import lua "vendor:lua/5.4"
import en "../../../engine"
import rl "vendor:raylib"
import "core:fmt"
import "base:runtime"

bind_world :: proc(L: ^lua.State)

defRenderable : en.Renderable = {
  indx = 200,
  pos = {100, 100},
  tex = rl.LoadTexture("assets/sonity.png"),

  isAnimated = false,

  sourceRec = {x = 0, y = 0, width = 32, height = 32},
  frameDuration = 0,
}


spawn_enemy :: proc "c" (L: ^lua.State) -> i32 {
  context = runtime.default_context()
  index : u32
  if !lua.isnumber(L, 1) || !lua.isnumber(L, 2) || !lua.isboolean(L, 3) || !lua.isstring(L, 4) || !lua.istable(L, 5) {
    fmt.println("Invalid Argumants")
    return 0
  }

  index += 1

  hp := f32(lua.tonumber(L, 1))
  speed := f32(lua.tonumber(L, 2))
  isBoss := lua.toboolean(L, 3)
  enemyClass := u8(lua.tointeger(L, 4))
  
  switch c in enemyClass {
    case en.EnemyClass.Tank:
      enemyClass = en.EnemyClass.Tank
  
    case en.EnemyClass.Ranged:
      enemyClass = en.EnemyClass.Ranged
    
    case en.EnemyClass.Assasin:
      enemyClass = en.EnemyClass.Assasin
    
    case en.EnemyClass.Swarmer:
      enemyClass = en.EnemyClass.Swarmer
  }

  if lua.istable(L, 5) {

  }
  return 0
}

make_renderable :: proc(L: ^lua.State, r: ^en.Renderable, spawnIndx: u32, indx: i32, texPath: cstring) {
  if !lua.istable(L, indx) {
    fmt.println("ERR: Expecting table")
    return
  }

  r.indx = spawnIndx

  lua.getfield(L, indx, "position")
  if lua.istable(L, -1) {
    lua.getfield(L, -1, "x")
    if lua.isnumber(L, -1) {
      r.pos.x = f32(lua.tonumber(L, -1))
    }

    lua.getfield(L, -2, "y")
    if lua.isnumber(L, -1) {
      r.pos.y = f32(lua.tonumber(L, -1))
    }
  }
  lua.pop(L, 3)

  lua.getfield(L, indx, "texturePath")
  if lua.isstring(L, -1) {
    r.tex = rl.LoadTexture(lua.tostring(L, -1))
  }
  lua.pop(L, 1)

  lua.getfield(L, indx, "isAnimated")
  if lua.isboolean(L, -1) {
    r.isAnimated = lua.toboolean(L, -1)
  }
  lua.pop(L, 1)

  lua.getfield(L, indx, "frameDuration")
  if lua.isnumber(L, -1) {
    r.frameDuration = f32(lua.tonumber(L, -1))
  } 

  lua.pop(L, 1)

  lua.getfield(L, indx, "frameRec")
  if lua.istable(L, -1) {
    lua.getfield(L, -1, "x")
    if lua.isnumber(L, -1) {
      r.sourceRec.x = f32(lua.tonumber(L, -1)) 
    }

    lua.getfield(L, -2, "y")
    if lua.isnumber(L, -1) {
      r.sourceRec.y = f32(lua.tonumber(L, -1))
    }

    lua.getfield(L, -3, "width")
    if lua.isnumber(L, -1) {
      r.sourceRec.width = f32(lua.tonumber(L, -1))
    }
    
    lua.getfield(L, -4, "height")
    if lua.isnumber(L, -1) {
      r.sourceRec.height = f32(lua.tonumber(L, -1))
    }
  }
  lua.pop(L, 5)
    
  lua.getfield(L, indx, "animations")
  if lua.istable(L, -1) {

  }
}
