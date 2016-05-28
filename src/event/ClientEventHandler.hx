package event;

import model.entity.User;
import model.entity.Server;
import config.Config;
import model.Command;
import model.Chat;
import translations.L;
import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import external.discord.channel.PMChannel;
import haxe.Timer;
import config.AuthDetails;
import nodejs.NodeJS;
import external.discord.message.Message;
import external.discord.client.Client;
import utils.Logger;

class ClientEventHandler extends EventHandler<Client> {
    private override function process(): Void {
        _eventEmitter.on(cast ClientEventType.READY, readyHandler);
        _eventEmitter.on(cast ClientEventType.MESSAGE, messageHandler);
        _eventEmitter.on(cast ClientEventType.SERVER_NEW_MEMBER, serverNewMemberHandler);
        _eventEmitter.on(cast ClientEventType.DISCONNECTED, disconnectedHandler);
    }

    private function readyHandler() {
        Logger.info('Connected! Serving in ' + _eventEmitter.channels.length + ' channels.');
        Server.registerServers();
        User.registerUsers();
        Chat.initialize();
    }

    private function messageHandler(msg: Message) {
        var client: Client = cast NodeJS.global.client;
        var messageIsCommand = msg.content.indexOf(Config.COMMAND_IDENTIFIER) == 0;
        var messageIsPrivate = msg.author != client.user && msg.channel.isPrivate && !messageIsCommand;
        var messageIsForMe = DiscordUtils.isMentionned(msg.mentions, client.user) && msg.author.id != client.user.id && !messageIsCommand;
        var info = 'from ' + msg.author.username;

        if (msg.channel.isPrivate) {
            info += ' in private';
        } else {
            var channel: TextChannel = cast msg.channel;
            info += ' on channel #' + channel.name + ' on server ' + channel.server.name;
        }

        if (messageIsCommand) {
            Logger.info('Received command ' + info + ': ' + msg.content);
            Command.instance.process(msg);
        } else if (messageIsPrivate || messageIsForMe) {
            Logger.info('Received message ' + info);
            Chat.instance.ask(msg);
        }
    }

    private function serverNewMemberHandler() {
        Logger.info('New member joined!');
        User.registerUsers();
    }

    private function disconnectedHandler() {
        Logger.info('Disconnected!');

        Timer.delay(function () {
            var client: Client = cast NodeJS.global.client;

            Logger.info('Trying to reconnect...');
            client.loginWithToken(AuthDetails.DISCORD_TOKEN);
        }, 1000);
    }
}
