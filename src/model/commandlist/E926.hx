package model.commandlist;

import utils.DiscordUtils;
import translations.LangCenter;
import discordhx.message.Message;

class E926 implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.e926.description');
    }

    public function process(args: Array<String>): Void {
        var searchEngine = new MangaPicture(_context, {
            secured: false,
            host: 'e926.net',
            limitKey: 'limit',
            tagsKey: 'tags',
            tagsKeySeparator: ',',
            pageKey: 'page',
            pathToPosts: '/post/index.xml',
            isJson: false,
            postDataInAttributes: false,
            nbPostsField: 'count',
            postsField: 'posts',
            postField: 'post',
            tagsField: 'tags',
            fileUrlField: 'file_url',
            ratingField: 'rating',
            tagsSeparator: ' '
        });

        searchEngine.searchPicture(args);
    }
}
