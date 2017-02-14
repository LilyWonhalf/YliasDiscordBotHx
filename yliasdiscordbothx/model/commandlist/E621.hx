package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.Bot;

class E621 extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    }

    override public function process(args: Array<String>): Void {
        var searchEngine = new MangaPicture(context, {
            secured: true,
            host: 'e621.net',
            limitKey: 'limit',
            tagsKey: 'tags',
            tagsKeySeparator: ',',
            pageKey: 'page',
            pathToPosts: '/post/index.xml?login=' + Bot.instance.authDetails.E621_LOGIN + '&password_hash=' + Bot.instance.authDetails.E621_PASSWORD_HASH,
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
