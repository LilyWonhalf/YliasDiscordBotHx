package model.commandlist;

import translations.L;
import external.discord.message.Message;

class Derpibooru implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description = L.a.n.g('model.commandlist.derpibooru.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var searchEngine = new MangaPicture(msg, {
            secured: true,
            host: 'derpibooru.org',
            limitKey: null,
            tagsKey: 'q',
            pageKey: 'page',
            pathToPosts: '/search.json',
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
