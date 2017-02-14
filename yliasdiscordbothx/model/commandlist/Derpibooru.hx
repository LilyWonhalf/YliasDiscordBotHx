package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;

class Derpibooru extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    }

    override public function process(args: Array<String>): Void {
        var searchEngine = new MangaPicture(context, {
            secured: true,
            host: 'derpibooru.org',
            limitKey: null,
            tagsKey: 'q',
            tagsKeySeparator: '+',
            pageKey: 'page',
            pathToPosts: '/search.json?key=' + Bot.instance.authDetails.DERPIBOORU_KEY,
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
