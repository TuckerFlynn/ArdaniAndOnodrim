require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/scripts/util.lua"

-- param entity
function evolveFluffalo()
  local evolveTime = config.getParameter("evolveTime")
  if storage.spawnTime + evolveTime < world.time() then
    local evolveType = config.getParameter("evolveType")
    local spawnPosition = vec2.add(mcontroller.position(), vec2.mul(config.getParameter("spawnOffset"), {mcontroller.facingDirection(), 1}))
    if not world.polyCollision(poly.translate(config.getParameter("spawnPoly"), spawnPosition)) then
      world.spawnMonster(evolveType, spawnPosition, {level = 1, aggressive = false})

      monster.setDropPool(nil)
      monster.setDeathParticleBurst(nil)
      monster.setDeathSound(nil)
      status.setResource("health", 0)
      return true
    end
  end
  return false
end

function resetMonsterHarvest()
  storage.lastHarvest = world.time()
  storage.harvestTime = util.randomInRange(config.getParameter("harvestTime"))
end

function hasMonsterHarvest(args, board)
  if not storage.lastHarvest then
    resetMonsterHarvest()
  end

  if world.time() - storage.lastHarvest >= storage.harvestTime then
    return true
  else
    return false
  end
end

function dropMonsterHarvest(args, board)
  local treasurePool = config.getParameter("harvestPool")
  local treasure = root.createTreasure(treasurePool, monster.level())
  local spawnPosition = vec2.add(mcontroller.position(), config.getParameter("harvestSpawnOffset", {0, 0}))
  local placeLoot = config.getParameter("placeLoot", false)

  if placeLoot then
    if treasure[1].name == "sapling" then
      local worldtype = world.type()
      local outputConfig = config.getParameter("biome")
      local outputParam = outputConfig[worldtype] or outputConfig["default"]

      world.placeObject( treasure[1].name, spawnPosition, 0, {stemName = outputParam["stemName"], foliageName = outputParam["foliageName"]} )
    end
  else
    for _,item in pairs(treasure) do
      world.spawnItem(item, spawnPosition)
    end
  end
  resetMonsterHarvest()
  return true
end
