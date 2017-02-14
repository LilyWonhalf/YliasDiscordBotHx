package yliasdiscordbothx.model.entity;

import yliasdiscordbothx.translations.Lang;
import yliasdiscordbothx.model.Entity.EntityProperties;

class ServerLang extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'server_lang',
        tableColumns: [
            {
                name: 'id',
                mappedBy: 'id',
                primary: true
            },
            {
                name: 'id_server',
                mappedBy: 'idServer',
                primary: false
            },
            {
                name: 'lang',
                mappedBy: 'lang',
                primary: false
            }
        ]
    };

    public var id: Int;
    public var idServer: String;
    public var lang: Lang;
}
