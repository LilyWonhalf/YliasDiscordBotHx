package yliasdiscordbothx.model.entity;

import yliasdiscordbothx.model.Entity.EntityProperties;

class Meme extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'meme',
        tableColumns: [
            {
                name: 'id',
                mappedBy: 'id',
                primary: true
            },
            {
                name: 'name',
                mappedBy: 'name',
                primary: false
            },
            {
                name: 'description',
                mappedBy: 'description',
                primary: false
            }
        ]
    };

    public var id: Int;
    public var name: String;
    public var description: String;
}
