package yliasdiscordbothx.event;

import yliasdiscordbothx.model.Db;
import discordbothx.core.DiscordBot;
import yliasdiscordbothx.model.entity.Staff;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.model.entity.WelcomeMessage;
import discordbothx.core.CommunicationContext;
import discordhx.user.User;
import yliasdiscordbothx.model.entity.User as UserEntity;
import yliasdiscordbothx.model.entity.Channel;
import yliasdiscordbothx.model.entity.Server;
import discordbothx.log.Logger;
import discordhx.client.Client;

class ClientEventHandler extends EventHandler<Client> {
    private override function process(): Void {
        eventEmitter.on(cast ClientEvent.READY, readyHandler);
        eventEmitter.on(cast ClientEvent.GUILD_CREATE, registerEntities);
        eventEmitter.on(cast ClientEvent.CHANNEL_CREATE, registerEntities);
        eventEmitter.on(cast ClientEvent.GUILD_MEMBER_ADD, serverNewMemberHandler);
        eventEmitter.on(cast ClientEvent.GUILD_MEMBER_REMOVE, serverMemberRemovedHandler);
    }

    private function readyHandler(): Void {
        Db.instance;
        LangCenter.instance;

        registerEntities();
    }

    private function registerEntities(): Void {
        Server.registerServers();
        Channel.registerChannels();
        UserEntity.registerUsers();
    }

    private function serverNewMemberHandler(server: Server, user: User): Void {
        Logger.info('New member joined!');
        registerEntities();

        var context: CommunicationContext = new CommunicationContext();

        WelcomeMessage.getForServer(server.id, function(err: Dynamic, message: String) {
            if (err != null) {
                Logger.exception(err);
                context.sendToOwner(LangCenter.instance.translate(server.id, 'fail', cast [user.username, server.name]));
            } else {
                if (message != null) {
                    context.sendTo(user, message);
                }
            }
        });

        Staff.getStaffToNotifyAboutNewMember(server.id, function (staffToNotify: Array<Staff>): Void {
            if (staffToNotify != null && staffToNotify.length > 0) {
                for (staff in staffToNotify) {
                    context.sendTo(
                        DiscordBot.instance.client.users.get(staff.idUser),
                        LangCenter.instance.translate(server.id, 'notification_to_staff', cast [user.username, server.name])
                    );
                }
            }
        });
    }

    private function serverMemberRemovedHandler(server: Server, user: User): Void {
        Logger.info('Member removed!');

        var context: CommunicationContext = new CommunicationContext();

        Staff.getStaffToNotifyAboutNewMember(server.id, function (staffToNotify: Array<Staff>): Void {
            if (staffToNotify != null && staffToNotify.length > 0) {
                for (staff in staffToNotify) {
                    context.sendTo(
                        DiscordBot.instance.client.users.get(staff.idUser),
                        LangCenter.instance.translate(server.id, 'notification_to_staff', cast [user.username, server.name])
                    );
                }
            }
        });
    }
}
