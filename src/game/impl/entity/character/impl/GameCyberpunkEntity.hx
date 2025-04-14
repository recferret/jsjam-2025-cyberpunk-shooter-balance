package game.impl.entity.character.impl;

import engine.impl.entity.base.character.EngineCharacterEntity;

import game.impl.entity.character.base.GameCharacterEntity;

class GameCyberpunkEntity extends GameCharacterEntity {

    public function new(parent:h2d.Layers, characterEntity:EngineCharacterEntity) {
        super(parent, characterEntity);

        final idleTile = hxd.Res.idle.toTile().center();
        final runTile = hxd.Res.run.toTile().center();
        final deathTile = hxd.Res.death.toTile().center();

        final th = 256;
        final tw = 256;

        for(x in 0 ... Std.int(idleTile.width / tw)) {
            final tile = idleTile.sub(x * tw, 0, tw, th).center();
            idleTiles.push(tile);
        }
        for(x in 0 ... Std.int(runTile.width / tw)) {
            final tile = runTile.sub(x * tw, 0, tw, tw).center();
            runTiles.push(tile);
        }
        for(x in 0 ... Std.int(deathTile.width / tw)) {
            final tile = deathTile.sub(x * tw, 0, tw, tw).center();
            deathTiles.push(tile);
        }

        setIdleAnimationState(true);

        addGun();

        setScale(0.5);
    }
    
}