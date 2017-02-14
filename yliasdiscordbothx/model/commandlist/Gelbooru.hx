package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;

class Gelbooru extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(tag 1)* *(tag 2)* *(tag n)*';
    }

    override public function process(args: Array<String>): Void {
        var searchEngine = new MangaPicture(context, {
            secured: false,
            host: 'gelbooru.com',
            limitKey: 'limit',
            tagsKey: 'tags',
            tagsKeySeparator: ',',
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
