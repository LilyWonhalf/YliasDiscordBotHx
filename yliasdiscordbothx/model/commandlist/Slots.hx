package yliasdiscordbothx.model.commandlist;

import discordhx.Collection;
import Date;
import discordhx.user.User;
import discordhx.message.Message;
import yliasdiscordbothx.utils.ArrayUtils;
import discordbothx.core.CommunicationContext;

class Slots extends YliasBaseCommand {
    private static inline var MAX_ATTEMPS: Int = 5;

    private static var attempts: Collection<User, Int>;
    private static var lastAttemptTime: Collection<User, Date>;

    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var emojis: Array<String> = [
            ':dog:',
            ':cat:',
            ':mouse:',
            ':hamster:',
            ':rabbit:',
            ':bear:',
            ':panda_face:',
            ':koala:',
            ':tiger:',
            ':lion_face:',
            ':cow:',
            ':pig:',
            ':frog:',
            ':octopus:',
            ':monkey_face:',
            ':chicken:',
            ':penguin:',
            ':bird:',
            ':baby_chick:',
            ':wolf:',
            ':boar:',
            ':horse:',
            ':unicorn:',
            ':bee:',
            ':bug:',
            ':snail:',
            ':beetle:',
            ':ant:',
            ':spider:',
            ':scorpion:',
            ':crab:',
            ':snake:',
            ':turtle:',
            ':tropical_fish:',
            ':fish:',
            ':blowfish:',
            ':dolphin:',
            ':whale:',
            ':whale2:',
            ':crocodile:',
            ':water_buffalo:',
            ':ox:',
            ':dromedary_camel:',
            ':camel:',
            ':elephant:',
            ':goat:',
            ':ram:',
            ':sheep:',
            ':rat:',
            ':turkey:',
            ':dove:',
            ':dog2:',
            ':poodle:',
            ':dragon_face:',
            ':eagle:',
            ':duck:',
            ':bat:',
            ':shark:',
            ':owl:',
            ':fox:',
            ':butterfly:',
            ':deer:',
            ':gorilla:',
            ':lizard:',
            ':rhino:',
            ':shrimp:',
            ':squid:'
        ];

        var author: User = context.message.author;
        var first: String = ArrayUtils.random(emojis);
        var second: String = ArrayUtils.random(emojis);
        var third: String = ArrayUtils.random(emojis);
        var answer: String = '';

        if (attempts == null) {
            attempts = new Collection<User, Int>();
        }

        if (lastAttemptTime == null) {
            lastAttemptTime = new Collection<User, Date>();
        }

        if (!attempts.has(author)) {
            attempts.set(author, 0);
        }

        if (!lastAttemptTime.has(author)) {
            lastAttemptTime.set(author, Date.now());
        }

        if (isDateBeforeToday(lastAttemptTime.get(author))) {
            for (entry in attempts.keyArray()) {
                attempts.set(entry, 0);
            }
        }

        if (attempts.get(author) < MAX_ATTEMPS) {
            attempts.set(author, attempts.get(author) + 1);
            lastAttemptTime.set(author, Date.now());

            if (first == second && second == third) {
                answer += ':sparkles: **JACKPOT** :sparkles:';
            } else {
                answer += ':x: **' + l('try_again').toUpperCase() + '** :x:';
            }

            context.sendToChannel(first + second + third).then(function (message: Message): Void {
                context.sendToChannel(answer);
            });
        } else {
            context.sendToChannel(l('too_much_tries', cast [author]));
        }
    }

    private function isDateBeforeToday(date: Date): Bool {
        var beforeToday: Bool = false;
        var now: Date = Date.now();

        if (date.getFullYear() < now.getFullYear()) {
            beforeToday = true;
        } else if (date.getMonth() < now.getMonth()) {
            beforeToday = true;
        } else if (date.getDate() < now.getDate()) {
            beforeToday = true;
        }

        return beforeToday;
    }
}
