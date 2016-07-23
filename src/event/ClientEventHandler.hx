package event;

import config.AuthDetails;
import model.entity.Staff;
import config.Config;
import model.entity.WelcomeMessage;
import model.CommunicationContext;
import model.entity.Channel;
import discordhx.user.User;
import model.Core;
import model.entity.User as UserEntity;
import model.entity.Server;
import config.Config;
import model.Command;
import model.Chat;
import utils.DiscordUtils;
import discordhx.channel.TextChannel;
import haxe.Timer;
import discordhx.message.Message;
import discordhx.client.Client;
import utils.Logger;

class ClientEventHandler extends EventHandler<Client> {
    private override function process(): Void {
        _eventEmitter.on(cast ClientEventType.READY, readyHandler);
        _eventEmitter.on(cast ClientEventType.MESSAGE, messageHandler);
        _eventEmitter.on(cast ClientEventType.MESSAGE_UPDATED, messageUpdatedHandler);
        _eventEmitter.on(cast ClientEventType.SERVER_NEW_MEMBER, serverNewMemberHandler);
        _eventEmitter.on(cast ClientEventType.DISCONNECTED, disconnectedHandler);
    }

    private function readyHandler(): Void {
        Logger.info('Connected! Serving in ' + _eventEmitter.channels.length + ' channels.');
        Server.registerServers();
        Channel.registerChannels();
        UserEntity.registerUsers();
        Chat.initialize();
    }

    private function messageHandler(msg: Message): Void {
        handleMessage(msg);
    }

    private function messageUpdatedHandler(oldMsg: Message, newMsg: Message): Void {
        if (oldMsg.content != newMsg.content) {
            handleMessage(newMsg, true, oldMsg);
        }
    }

    private function handleMessage(msg: Message, edited = false, oldMsg: Message = null): Void {
        var context = Core.instance.createCommunicationContext(msg);
        var user: User = Core.userInstance;
        var messageIsCommand = msg.content.indexOf(Config.COMMAND_IDENTIFIER) == 0;
        var messageIsPrivate = msg.author != user && msg.channel.isPrivate && !messageIsCommand;
        var messageIsForMe = DiscordUtils.isMentionned(msg.mentions, user) && msg.author.id != user.id && !messageIsCommand;
        var info = 'from ' + msg.author.username;

        if (msg.channel.isPrivate) {
            info += ' in private';
        } else {
            var channel: TextChannel = cast msg.channel;
            info += ' on channel #' + channel.name + ' on server ' + channel.server.name;
        }

        if (messageIsCommand) {
            if (edited) {
                Logger.info('Handling edited message from ' + oldMsg.author.username + '. Was\n\n' + oldMsg.cleanContent + '\n\nIs now\n\n' + msg.cleanContent + '\n\n');
            }

            Logger.info('Received command ' + info + ': ' + msg.content);
            Command.instance.process(context);
        } else if (!msg.author.bot && (messageIsPrivate || messageIsForMe)) {
            if (edited) {
                Logger.info('Handling edited message from ' + oldMsg.author.username + '. Was\n\n' + oldMsg.cleanContent + '\n\nIs now\n\n' + msg.cleanContent + '\n\n');
            }

            Logger.info('Received message ' + info);

            if (messageIsPrivate && msg.author.id != AuthDetails.OWNER_ID) {
                context.rawSendToOwner('Message entrant de **' + msg.author.username + '** :\n' + msg.content);
            }

            if (!messageIsPrivate || Config.CHAT_IN_PRIVATE) {
                Chat.instance.ask(context);
            }
        }
    }

    private function serverNewMemberHandler(server: Server, user: User): Void {
        Logger.info('New member joined!');
        UserEntity.registerUsers();
        Server.registerServers();
        Channel.registerChannels();

        var context: CommunicationContext = Core.instance.createCommunicationContext();

        WelcomeMessage.getForServer(server.id, function(err: Dynamic, message: String) {
            if (err != null) {
                Logger.exception(err);
                context.sendToOwner('event.clickeventhandler.servernewmemberhandler.fail', cast [user.username, server.name]);
            } else {
                if (message != null) {
                    context.rawSendTo(user.id, message);
                }
            }
        });

        Staff.getStaffToNotifyAboutNewMember(server.id, function (staffToNotify: Array<Staff>): Void {
            if (staffToNotify != null && staffToNotify.length > 0) {
                for (staff in staffToNotify) {
                    context.sendTo(staff.idUser, 'event.clickeventhandler.servernewmemberhandler.notification_to_staff', cast [user.username, server.name]);
                }
            }
        });
    }

    private function disconnectedHandler(): Void {
        Logger.info('Disconnected!');

        Timer.delay(function () {
            Logger.info('Trying to reconnect...');
            Core.instance.connect();
        }, 1000);
    }
}
