package model.commandlist;

import translations.L;
import external.discord.message.Message;

class Gelbooru implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description = L.a.n.g('model.commandlist.gelbooru.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var searchEngine = new MangaPicture(msg, {
            secured: false,
            host: 'gelbooru.com',
            limitKey: 'limit',
            tagsKey: 'tags',
            pageKey: 'pid',
            pathToPosts: '/index.php?page=dapi&s=post&q=index',
            isJson: false,
            postDataInAttributes: true,
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
