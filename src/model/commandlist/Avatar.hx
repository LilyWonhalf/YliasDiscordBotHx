package model.commandlist;

import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import external.discord.channel.PMChannel;
import external.discord.user.User;
import translations.LangCenter;
import external.discord.message.Message;

class Avatar implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.avatar.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var userlist: Array<User> = null;

        if (_context.getMessage().channel.isPrivate) {
            var channel: PMChannel = cast _context.getMessage().channel;
            userlist = [Core.userInstance, channel.recipient];
        } else {
            var channel: TextChannel = cast _context.getMessage().channel;
            userlist = channel.server.members;
        }

        var user: User = DiscordUtils.getUserFromSearch(userlist, args.join(' '));

        if (user != null) {
            if (user.id == Core.userInstance.id) {
                _context.rawSendToChannel(author + ' => ' + user.avatarURL, function(err: Dynamic, sentMessage: Message) {
                    _context.sendToChannel('model.commandlist.avatar.process.client_avatar_author', cast ['https://commons.wikimedia.org/wiki/File:Anthro_vixen_colored.jpg']);
                });
            } else {
                _context.rawSendToChannel(author + ' => ' + user.avatarURL);
            }
        } else {
            _context.sendToChannel('model.commandlist.avatar.process.not_found', cast [author]);
        }
    }
}
