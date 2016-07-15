package model.commandlist;

import utils.Logger;
import model.entity.Staff;
import utils.DiscordUtils;
import discordhx.user.User;
import translations.LangCenter;
import discordhx.message.Message;

class UnregisterStaff implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.unregisterstaff.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var userlist: Array<User> = null;

        if (!_context.getMessage().channel.isPrivate) {
            if (_context.getMessage().mentions.length > 0) {
                var staff = new Staff();
                var staffMember = _context.getMessage().mentions[0];
                var serverId = DiscordUtils.getServerIdFromMessage(_context.getMessage());
                var uniqueValues = new Map<String, String>();

                uniqueValues.set('idUser', staffMember.id);
                uniqueValues.set('idServer', serverId);

                staff.retrieve(uniqueValues, function (found: Bool): Void {
                    if (!found) {
                        _context.sendToChannel('model.commandlist.unregisterstaff.process.not_found', cast [author]);
                    } else {
                        staff.remove(function (err: Dynamic): Void {
                            if (err == null) {
                                _context.sendToChannel('model.commandlist.unregisterstaff.process.success', cast [author]);
                            } else {
                                Logger.exception(err);
                                _context.sendToChannel('model.commandlist.unregisterstaff.process.fail', cast [author]);
                            }
                        });
                    }
                });
            } else {
                _context.sendToChannel('model.commandlist.unregisterstaff.process.no_mention', cast [author]);
            }
        } else {
            _context.sendToChannel('model.commandlist.unregisterstaff.process.private_channel_error', cast [author]);
        }
    }
}
