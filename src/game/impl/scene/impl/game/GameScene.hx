package game.impl.scene.impl.game;

import engine.base.geom.Rectangle;
import game.base.graphics.BitmapUtils;
import h3d.Engine;
import haxe.Timer;
import hxd.Event;
import hxd.Key;
import slide.TweenManager;
import uuid.Uuid;

import engine.base.geom.Point;
import engine.base.geom.Line;
import engine.base.types.InputTypes.InputCommand;
import engine.base.types.InputTypes.PlayerInputCommand;
import engine.base.Cooldown;
import engine.base.MathUtils;

import engine.impl.entity.base.character.EngineCharacterEntity;
import engine.impl.entity.base.projectile.EngineProjectileEntity;
import engine.impl.events.character.CreateCharacterEventListener;
import engine.impl.events.character.DeleteCharacterEventListener;
import engine.impl.events.projectile.CreateProjectileEventListener;
import engine.impl.events.projectile.DeleteProjectileEventListener;
import engine.impl.Borders;
import engine.impl.GameEngine;

import game.base.camera.CameraController;
import game.base.fx.FxManager;
import game.base.graphics.GraphicsUtils;
import game.base.scene.AbstractScene;

import game.impl.entity.character.GameCharacterFactory;
import game.impl.entity.character.base.GameCharacterEntity;
import game.impl.entity.projectile.GameProjectileFactory;
import game.impl.entity.projectile.base.GameProjectileEntity;

import network.protocol.character.ProtoCharacterCreateMessage.ProtoCharacterCreateBody;
import network.protocol.character.ProtoCharacterDeleteMessage.ProtoCharacterDeleteBody;
import network.protocol.game.enter.ProtoGameEnterResponse.ProtoGameEnterResponseBody;
import network.protocol.game.state.ProtoGameStateMessage.ProtoGameStateBody;
import network.protocol.input.ProtoInputMessage.ProtoInputMessageBody;
import network.client.LocalNetworking;
import network.client.RemoteNetworking;
import network.client.AbstractNetworking;
import network.client.WsClientEvents;



class GameScene 
    extends AbstractScene
    // Engine events
    implements CreateCharacterEventHandler
    implements DeleteCharacterEventHandler
    implements CreateProjectileEventHandler
    implements DeleteProjectileEventHandler
    // Networking events
    implements GameEnterResponseHandler
    implements CharacterCreateHandler
    implements CharacterDeleteHandler
    implements GameStateHandler
    implements InputHandler {

    public static final SlideTweenManager = new TweenManager();

    public static var gameEngine:GameEngine;

    private var playerCharacter:GameCharacterEntity;

    private final characterFactory:GameCharacterFactory;
    private final characters = new Map<String, GameCharacterEntity>();

    private final projectileFactory:GameProjectileFactory;
    private final projectiles = new Map<String, GameProjectileEntity>();

    private final cameraController:CameraController;        

    // LocalNetworking
    private var networking:AbstractNetworking;
    private var lastMousePos:h2d.col.Point;
    private var allowToSpawnRect = false;

    private final gameBorders:GameBorders;

    private var debugMode = false;
    private var allowToChangeDebugMode = true;

	public function new() {
		super();

        scaleMode = ScaleMode.LetterBox(1280, 720);
        camera.setScale(2, 2);

        // BG
        final map1 = new h2d.Bitmap(hxd.Res.map1.toTile());
        final map2 = new h2d.Bitmap(hxd.Res.map2.toTile());
        final map3 = new h2d.Bitmap(hxd.Res.map3.toTile());
        final map4 = new h2d.Bitmap(hxd.Res.map4.toTile());

        map1.setPosition(0, 512);
        map2.setPosition(512, 512);
        map3.setPosition(512, 0);

        add(map1, AbstractScene.BG_LAYER);
        add(map2, AbstractScene.BG_LAYER);
        add(map3, AbstractScene.BG_LAYER);
        add(map4, AbstractScene.BG_LAYER);

        gameBorders = new GameBorders(this);

        // camera.setViewport(400, 300, 800, 600);

        // BG
        // add(new h2d.Bitmap(h2d.Tile.fromColor(0xFFEFEF, FswGameEngine.WorldWidth, FswGameEngine.WorldHeight)), AbstractScene.BG_LAYER);

        gameEngine = new GameEngine();
        gameEngine.inputsProcessedCallback = function callback(commands:Array<PlayerInputCommand>) {
            for (command in commands) {
                networking.input(command);
            }
        };
        gameEngine.setProjectileHitCallback(function callback(hits:Array<ProjectileHit>) {
            for (hit in hits) {
                final projectile = projectiles.get(hit.projectile.getId());

                final projectileFuturePosition = projectile.getEngineEntity().getPastPosition(0.8);

                FxManager.instance.light(projectileFuturePosition.x, projectileFuturePosition.y);
                
                final character = characters.get(hit.character.getId());
                character.squashFx();
                character.blinkFx();

                FxManager.instance.damageText(this, character.x, character.y, '-5');
            }
        });

        networking = Game.Network == NetworkMode.Local ? new LocalNetworking() : new RemoteNetworking();

        characterFactory = new GameCharacterFactory();
        projectileFactory = new GameProjectileFactory();

        cameraController = new CameraController(this);

        FxManager.instance.setScene(this);

        CreateCharacterEventListener.instance.subscribe(this);
        DeleteCharacterEventListener.instance.subscribe(this);
        CreateProjectileEventListener.instance.subscribe(this);
        DeleteProjectileEventListener.instance.subscribe(this);

        // final background = new h2d.Bitmap(hxd.Res.bg.toTile());
        // background.setScale(3);

        Game.PlayerId = Uuid.v4();

        setInputCallback(function callback(input:PlayerInputCommand) {
            if (!debugMode) {
                gameEngine.addInputCommand(input);

                if (input.inputCommand == InputCommand.Skill) {
                    for (value in characters) {
                        if (value.getEngineEntity().getOwnerId() != Game.PlayerId) {
                            value.phantomFx();
                        }
                    }
                }
            }
        });

        setUiScene(new GameUiScene());

        // Networking
        WsClientEventListener.instance.subscribeForGameEnterResponseEvent(this);
        WsClientEventListener.instance.subscribeForCharacterCreateEvent(this);
        WsClientEventListener.instance.subscribeForCharacterDeleteEvent(this);
        WsClientEventListener.instance.subscribeForGameStateEvent(this);
        WsClientEventListener.instance.subscribeForInputEvent(this);

        Timer.delay(function callback() {
            networking.gameEnter();
        }, 500);
	}

    // --------------------------------------
	// Abstraction
	// --------------------------------------


    // TODO move to the input class
    public function absOnEvent(event:hxd.Event) {
        final cursor = new h2d.col.Point(event.relX, event.relY);
        camera.screenToCamera(cursor);
        lastMousePos = cursor;

        if (!debugMode) {
            if (event.kind == EventKind.EMove && playerCharacter != null) {
                final lookAtAngle = MathUtils.angleBetweenPoints(
                    new Point(playerCharacter.x, playerCharacter.y),
                    new Point(cursor.x, cursor.y),
                );

                // DRY
                final playerInputCommand = new PlayerInputCommand();
                playerInputCommand.setPlayerId(Game.PlayerId);
                playerInputCommand.setInputCommand(InputCommand.LookAt);
                playerInputCommand.setAngle(lookAtAngle);

                gameEngine.addInputCommand(playerInputCommand);
            }
        }
    }

    public function absOnResize(w:Int, h:Int) {
    }

	public function absStart() {
    }

	public function absUpdate(dt:Float, fps:Float) {
        SlideTweenManager.update(dt);

        for (value in characters) {
            value.update(dt);
        }
        for (value in projectiles) {
            value.update(dt);
        }
        cameraController.update();

		if (uiScene != null) {
			cast(uiScene, GameUiScene).update(debugMode);
		}

        if (Key.isDown(Key.Z) && allowToChangeDebugMode) {
            debugMode = !debugMode;
            allowToChangeDebugMode = false;
            haxe.Timer.delay(function callback() {
                allowToChangeDebugMode = true;
            }, 1000);
        }

        if (debugMode) {
            cameraController.setTarget(null);

            if (Key.isDown(Key.W)) {
                camera.y -= 5;
            }
            if (Key.isDown(Key.A)) {
                camera.x -= 5;
            }
            if (Key.isDown(Key.S)) {
                camera.y += 5;
            }
            if (Key.isDown(Key.D)) {
                camera.x += 5;
            }

            if (Key.isDown(Key.SHIFT)) {
                var rectsString = '';
                for (value in gameBorders.rectWrappers) {
                    rectsString += value.rect.toString() + ',\n';
                }
                trace(rectsString);
            }

            if (Key.isDown(Key.SPACE) && allowToSpawnRect) {
                allowToSpawnRect = false;
                haxe.Timer.delay(function callback() {
                    allowToSpawnRect = true;
                }, 1000);
            }

            if (gameBorders.rectToReplace != null) {
                gameBorders.rectToReplace.bmp.setPosition(lastMousePos.x, lastMousePos.y);
                gameBorders.rectToReplace.rect.setPosition(lastMousePos.x, lastMousePos.y);
                Borders.instance.rectangles.get(gameBorders.rectToReplace.id).setPosition(lastMousePos.x, lastMousePos.y);
            }
        } else {
            cameraController.setTarget(playerCharacter);
        }

        gameBorders.show(debugMode);
	}

    public function absRender(e:Engine) {
        for (value in characters) {
            value.debugDraw(debugGraphics);
            value.drawSight(debugGraphics);
        }

        if (debugMode) {
            for (rect in Borders.instance.rectangles) {
                GraphicsUtils.DrawRect(debugGraphics, rect, Colors.GreenColor);
            }
        }
    }
    
    public function absDestroy() {
    }

    // ------------------------------------
	// Engine events
	// ------------------------------------

    private var initiated = false;

    public function createCharacterEventHandler(characters:Array<EngineCharacterEntity>) {
        if (initiated) {
            trace('createCharacterEventHandler');
            for (character in characters) {
                this.characters.set(character.getId(), characterFactory.createCharacter(this, character));
                if (character.getOwnerId() == Game.PlayerId) {
                    playerCharacter = this.characters.get(character.getId());
                    cameraController.setTarget(playerCharacter);
                } else {
                    final c = this.characters.get(character.getId());
                    // c.alpha = 0;
                }
            }
        }
    }

    public function deleteCharacterEventHandler(charactersIds:Array<String>) {
        trace('deleteCharacterEventHandler');
        for (id in charactersIds) {
            this.characters.get(id).remove();
            this.characters.remove(id);
        }
    }

    public function createProjectileEventHandler(projectiles:Array<EngineProjectileEntity>) {
        for (projectile in projectiles) {
            this.projectiles.set(projectile.getId(), projectileFactory.createProjectile(this, projectile));

            final engineCharacter = gameEngine.getCharacterByOnwerId(projectile.getOwnerId());
            final gameCharacter = characters.get(engineCharacter.getId());
            gameCharacter.gunRecoil();

            final lightPos = gameCharacter.getEngineEntity().getGunBarrelPos();
            FxManager.instance.light(lightPos.x, lightPos.y);
            FxManager.instance.muzzleFlash(lightPos.x, lightPos.y, engineCharacter.getLookAtAngle(), gameCharacter.getEngineEntity().direction);

            Cooldown.instance.add({
                name: 'gun_recoil_' + engineCharacter.getId(),
                durationSeconds: 0.5,
                onCompleteDelete: true,
            });
        }

        cameraController.bump(3,0);
        cameraController.shakeS(0.2, 0.2);
        FxManager.instance.flash(uiScene, 0xffcc00, 0.04, 0.1);
    }

    public function deleteProjectileEventHandler(ids:Array<String>) {
        for (id in ids) {
            projectiles.get(id).remove();
            projectiles.remove(id);
        }
    }

    // ------------------------------------
	// Network events
	// ------------------------------------

    public function gameEnterResponse(body:ProtoGameEnterResponseBody) {
        trace('gameEnterResponse');

        initiated = true;

        for (character in body.characters) {
            gameEngine.createCharacter({
                id: character.id,
                ownerId: character.ownerId,
                x: character.x,
                y: character.y,
                entityType: character.entityType,
                aiControlled: false,
            });
        }

        if (networking.networkMode == NetworkMode.Local) {
            for (character in gameEngine.getCharacterEntities()) {

            }
        } else {
            // for (character in body.characters) {
            //     fswGameEngine.createCharacter({
            //         id: character.id,
            //         ownerId: character.ownerId,
            //         x: character.x,
            //         y: character.y,
            //         entityType: character.entityType,
            //     });
            // }
        }
    }

    public function characterCreate(body:ProtoCharacterCreateBody) {
        trace('characterCreate');

        for (character in body.characters) {
            gameEngine.createCharacter({
                id: character.id,
                ownerId: character.ownerId,
                x: character.x,
                y: character.y,
                entityType: character.entityType,
                aiControlled: character.aiControlled,
            });
        }
    }

    public function characterDelete(body:ProtoCharacterDeleteBody) {
        trace('characterDelete');

        for (id in body.characterIds) {
            gameEngine.deleteCharacterById(id);
        }
    }

    public function gameState(body:ProtoGameStateBody) {
        initiated = true;
    }

    var inputsReceived = 0;

    public function input(body:ProtoInputMessageBody) {
        
        if (body.playerId != Game.PlayerId) {
            final playerInputCommand = new PlayerInputCommand();
            playerInputCommand.setPlayerId(body.playerId);
            playerInputCommand.setInputCommand(body.command);

            playerInputCommand.setAngle(body.angle); 
            gameEngine.addInputCommand(playerInputCommand, false);
        }
    }

}