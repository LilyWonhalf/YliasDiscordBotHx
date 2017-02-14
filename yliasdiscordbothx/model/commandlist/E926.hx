package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;

class E926 extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    }

    override public function process(args: Array<String>): Void {
        var searchEngine = new MangaPicture(context, {
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
