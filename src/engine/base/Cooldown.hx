package engine.base;

typedef CooldownJob = {
    name:String,
    durationSeconds:Float,
    onCompleteDelete:Bool,
    ?onCompleteCallback:Dynamic,
    ?secondsLeft:Float,
    ?completionRatio:Float,
    ?started: Bool,
    ?finished: Bool,
};

class Cooldown {
    
    public static final instance:Cooldown = new Cooldown();

    private var nextCooldownId = 0;
    private final cooldowns = new Map<String, CooldownJob>();

	private function new() {}

    public function update(dt:Float) {
        final cooldownsToDelete = new Array<String>();

        for (value in cooldowns) {
            if (!value.finished) {
                value.secondsLeft -= dt;
                value.completionRatio = value.secondsLeft / value.durationSeconds;

                if (value.secondsLeft <= 0) {
                    value.finished = true;
                    if (value.onCompleteCallback != null) {
                        value.onCompleteCallback();
                    }
                    if (value.onCompleteDelete) {
                        cooldownsToDelete.push(value.name);
                    }
                }
            }
        }

        for (cooldownToDelete in cooldownsToDelete) {
            cooldowns.remove(cooldownToDelete);
        }
    }

    public function add(cooldownJob:CooldownJob) {
        cooldownJob.started = true; 
        cooldownJob.finished = false; 
        cooldownJob.completionRatio = 1; 
        cooldownJob.secondsLeft = cooldownJob.durationSeconds; 

        cooldowns.set(cooldownJob.name, cooldownJob);
    }

    public function deleteByName(cooldownName:String) {
        cooldowns.remove(cooldownName);
    }

    public function has(cooldownName:String) {
        return cooldowns.exists(cooldownName);
    }

    public function isFinished(cooldownName:String) {
        return cooldowns.get(cooldownName).finished;
    }

    public function get(cooldownName:String) {
        return cooldowns.get(cooldownName);
    }
}