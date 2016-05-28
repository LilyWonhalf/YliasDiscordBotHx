package model.commandlist;

import config.AuthDetails;
import translations.L;
import external.discord.message.Message;

class E621 implements ICommandDefinition {
    public var paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    public var description = L.a.n.g('model.commandlist.e621.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var searchEngine = new MangaPicture(msg, {
            secured: true,
            host: 'e621.net',
            limitKey: 'limit',
            tagsKey: 'tags',
            tagsKeySeparator: ',',
            pageKey: 'page',
            pathToPosts: '/post/index.xml?login=' + AuthDetails.E621_LOGIN + '&password_hash=' + AuthDetails.E621_PASSWORD_HASH,
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
