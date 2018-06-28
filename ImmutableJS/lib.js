// game functions library

const GAME_SIZE = 500;
const TILE_SIZE = 50;

function draw_entity(context, entity) {
  const x = entity.get("x")*TILE_SIZE, y = entity.get("y")*TILE_SIZE;
  const src_x = entity.get("imageX"), src_y = entity.get("imageY");
  const src_h = entity.get("imageH"), src_w = entity.get("imageW");
  context.drawImage(entity.get("image"), src_x, src_y, src_w, src_h, x, y, TILE_SIZE, TILE_SIZE);
}

function update_game(entities, left, right, up, down) {
  const hero = entities.get(0); // our hero is always the first :)
  const x = hero.get("x"),
        y = hero.get("y");
  let new_x = x,
      new_y = y;
  
  if (left) {
    new_x = Math.max(x - 1, 0);
  } else if (right) {
    new_x = Math.min(x + 1, GAME_SIZE/TILE_SIZE - 1);
  }

  if (up) {
    new_y = Math.max(y - 1, 0);
  } else if (down) {
    new_y = Math.min(y + 1, GAME_SIZE/TILE_SIZE - 1);
  }

  const enemy = entities.rest() // skip the hero
    .find((entity) => entity.get("x") === new_x && entity.get("y") === new_y);
  
  let hero_updated = hero
      entities_updated = entities;

  if (enemy !== undefined) {
    // don't step over enemies
    new_x = x;
    new_y = y;

    const [hero_attacked, enemy_updated] = attack(hero, enemy);
    hero_updated = hero_attacked;
    if (enemy_updated.get("health") <= 0) {
      entities_updated = entities.delete(entities.indexOf(enemy));
    } else {
      entities_updated = entities.set(entities.indexOf(enemy), enemy_updated);
    }
  }

  hero_updated = hero_updated.set("x", new_x).set("y", new_y);

  return entities_updated.set(0, hero_updated);
}

function attack(hero, enemy) {
  const damage = hero.getIn(["weapon", "damage"], 20); // default damage is 20
  const enemy_updated = enemy.update("health", (health) => health - damage);
  const hero_updated = hero.update("health", (health) => {
    if (enemy_updated.get("health") > 0) {
      const enemy_damage = enemy.getIn(["weapon", "damage"], 20);
      return health - enemy_damage;
    }
    return health; // dead enemies don't fight back
  });
  return [hero_updated, enemy_updated];
}
