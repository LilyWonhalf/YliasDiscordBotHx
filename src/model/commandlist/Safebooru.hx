package model.commandlist;

import translations.L;
import external.discord.message.Message;

class Safebooru implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description = L.a.n.g('model.commandlist.safebooru.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var searchEngine = new MangaPicture(msg, {
            secured: false,
            host: 'safebooru.org',
            limitKey: 'limit',
            tagsKey: 'tags',
            pageKey: 'pid',
            pathToPosts: '/index.php?page=dapi&s=post&q=index',
            postDataInAttributes: true
        });

        searchEngine.searchPicture(args);
    }
}
