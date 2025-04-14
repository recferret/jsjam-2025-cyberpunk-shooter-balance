package game.base.input;

import hxd.Key;

import engine.base.types.InputTypes.InputCommand;
import engine.base.types.InputTypes.PlayerInputCommand;
import engine.base.MathUtils;

import game.impl.Game;


class Input {

    private final inputCallback:PlayerInputCommand->Void;

    public function new(inputCallback:PlayerInputCommand->Void) {
        this.inputCallback = inputCallback;
    }

    public function updateKeyboardInput() {
        if (inputCallback != null) {
            final playerInputCommand = new PlayerInputCommand();
            playerInputCommand.setPlayerId(Game.PlayerId);

            // TODO Exact implementation should be moved to FSW package
            if (Key.isDown(Key.W)) {
                playerInputCommand.setInputCommand(InputCommand.Move);

                if (Key.isDown(Key.D)) {
                    playerInputCommand.setAngle(MathUtils.degreeToRads(-45));
                } else if (Key.isDown(Key.A)) {
                    playerInputCommand.setAngle(MathUtils.degreeToRads(-135));
                } else {
                    playerInputCommand.setAngle(MathUtils.degreeToRads(-90));
                }
            } else
            if (Key.isDown(Key.S)) {
                playerInputCommand.setInputCommand(InputCommand.Move);

                if (Key.isDown(Key.D)) {
                    playerInputCommand.setAngle(MathUtils.degreeToRads(45));
                } else if (Key.isDown(Key.A)) {
                    playerInputCommand.setAngle(MathUtils.degreeToRads(135));
                } else {
                    playerInputCommand.setAngle(MathUtils.degreeToRads(90));
                }
            } else
            if (Key.isDown(Key.A)) {
                playerInputCommand.setInputCommand(InputCommand.Move);
                playerInputCommand.setAngle(MathUtils.degreeToRads(180));
            } else
            if (Key.isDown(Key.D)) {
                playerInputCommand.setInputCommand(InputCommand.Move);
                playerInputCommand.setAngle(0);
            }

            if (Key.isDown(Key.CTRL)) {
                playerInputCommand.setInputCommand(InputCommand.Shoot);
            }

            if (Key.isDown(Key.SPACE)) {
                playerInputCommand.setInputCommand(InputCommand.Skill);
            }

            if (playerInputCommand.inputCommand != null) {
                inputCallback(playerInputCommand);
            }
        }
    }

}