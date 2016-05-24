package model.commandlist;

import config.AuthDetails;
import translations.L;
import external.discord.message.Message;

class E926 implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description = L.a.n.g('model.commandlist.e926.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var searchEngine = new MangaPicture(msg, {
            secured: false,
            host: 'e926.net',
            limitKey: 'limit',
            tagsKey: 'tags',
            pageKey: 'page',
            pathToPosts: '/post/index.xml',
            postDataInAttributes: false
        });

        searchEngine.searchPicture(args);
    }
}
