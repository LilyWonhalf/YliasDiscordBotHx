package model.commandlist;

import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import external.discord.user.User;
import external.discord.channel.PMChannel;
import translations.LangCenter;

class GetUserId implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.getuserid.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length < 1) {
            _context.sendToChannel('model.commandlist.getuserid.process.no_args', cast [author]);
        } else {
            var userlist: Array<User>;

            if (_context.getMessage().channel.isPrivate) {
                var channel: PMChannel = cast _context.getMessage().channel;
                userlist = [Core.userInstance, channel.recipient];
            } else {
                var channel: TextChannel = cast _context.getMessage().channel;
                userlist = channel.server.members;
            }

            var user = DiscordUtils.getUserFromSearch(userlist, args.join(' '));

            if (user != null) {
                if (user.id == Core.userInstance.id) {
                    _context.sendToChannel('model.commandlist.getuserid.process.answer_panic', cast [user.username, cast author, user.id]);
                } else {
                    _context.sendToChannel('model.commandlist.getuserid.process.answer', cast [cast author, user.username, user.id]);
                }
            } else {
                _context.sendToChannel('model.commandlist.getuserid.process.not_found', cast [author]);
            }
        }
    }
}
