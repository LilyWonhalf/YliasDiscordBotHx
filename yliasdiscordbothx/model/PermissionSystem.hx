package yliasdiscordbothx.model;

import yliasdiscordbothx.utils.DiscordUtils;
import discordhx.channel.Channel;
import yliasdiscordbothx.model.entity.Permission;
import discordbothx.core.CommunicationContext;
import discordbothx.core.IPermissionSystem;
import js.Promise;

class PermissionSystem implements IPermissionSystem {
    public function new() {}

    public function check(context: CommunicationContext, command: String): Promise<Bool> {
        return new Promise<Bool>(function (resolve: Bool->Void, reject: Dynamic->Void): Void {
            var channel: Channel = cast context.message.channel;
            var serverId: String = DiscordUtils.getServerIdFromMessage(context.message);

            Permission.check(context.message.author.id, channel.id, serverId, command, function (error: Dynamic, granted: Bool): Void {
                if (error == null) {
                    resolve(granted);
                } else {
                    reject(error);
                }
            });
        });
    }

    public function getDeniedCommandList(context: CommunicationContext): Promise<Array<String>> {
        return new Promise<Array<String>>(function (resolve: Array<String>->Void, reject: Dynamic->Void): Void {
            var channel: Channel = cast context.message.channel;
            var serverId: String = DiscordUtils.getServerIdFromMessage(context.message);

            Permission.getDeniedCommandList(context.message.author.id, channel.id, serverId, function (error: Dynamic, deniedCommandList: Array<String>): Void {
                if (error == null) {
                    resolve(deniedCommandList);
                } else {
                    reject(error);
                }
            });
        });
    }
}