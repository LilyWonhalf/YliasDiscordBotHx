package model.commandlist;

import utils.DiscordUtils;
import translations.LangCenter;
import external.discord.message.Message;

class Derpibooru implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.derpibooru.description');
    }

    public function process(args: Array<String>): Void {
        var searchEngine = new MangaPicture(_context, {
            secured: true,
            host: 'derpibooru.org',
            limitKey: null,
            tagsKey: 'q',
            tagsKeySeparator: '+',
            pageKey: 'page',
            pathToPosts: '/search.json?key=vRkyGYwyHXZkFxkbeC6M',
            isJson: true,
            postDataInAttributes: null,
            nbPostsField: 'total',
            postsField: 'search',
            postField: null,
            tagsField: 'tags',
            fileUrlField: 'image',
            ratingField: null,
            tagsSeparator: ', '
        });

        searchEngine.searchPicture(args);
    }
}
