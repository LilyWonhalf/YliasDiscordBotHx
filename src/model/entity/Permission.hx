package model.entity;

import config.Config;
import model.Entity.EntityProperties;
import utils.Logger;

class Permission extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'permission',
        tableColumns: [
            {
                name: 'id_user',
                mappedBy: 'idUser',
                primary: true
            },
            {
                name: 'id_channel',
                mappedBy: 'idChannel',
                primary: true
            },
            {
                name: 'id_server',
                mappedBy: 'idServer',
                primary: true
            },
            {
                name: 'command',
                mappedBy: 'command',
                primary: true
            },
            {
                name: 'granted',
                mappedBy: 'granted',
                primary: false
            }
        ]
    };

    public var idUser: String;
    public var idChannel: String;
    public var idServer: String;
    public var command: String;
    public var granted: Bool;

    public static function check(idUser: String, idChannel, idServer: String, command: String, callback: Bool->Void): Void {
        Db.instance.get(
            'SELECT IF(' +
            '    (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '    (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '    IF(' +
            '        (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '        (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '        IF(' +
            '            (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = "' + command + '"),' +
            '            (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = "' + command + '"),' +
            '            IF(' +
            '                (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '                (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '                IF(' +
            '                    (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '                    (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '                    IF(' +
            '                        (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = "' + command + '"),' +
            '                        (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = "' + command + '"),' +
            '                        1' +
            '                    )' +
            '                )' +
            '            )' +
            '        )' +
            '    )' +
            ') AS granted',
            [],
            function (err: Dynamic, result: Dynamic) {
                if (err) {
                    Logger.exception(err);
                    callback(false);
                } else {
                    callback(result.granted);
                }
            }
        );
    }

    public static function getDeniedCommandList(idUser: String, idChannel, idServer, callback: Dynamic->Array<String>->Void): Void {
        Db.instance.getAll(
            'SELECT DISTINCT command AS cmd, (' +
            '    SELECT IF(' +
            '        (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '        (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '        IF(' +
            '            (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '            (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '            IF(' +
            '                (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = cmd),' +
            '                (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + idUser + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = cmd),' +
            '                IF(' +
            '                    (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                    (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + idChannel + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                    IF(' +
            '                        (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                        (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                        IF(' +
            '                            (SELECT COUNT(*) FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = cmd),' +
            '                            (SELECT granted FROM ' + properties.tableName + ' WHERE id_user = "' + Config.KEY_ALL + '" AND id_channel = "' + Config.KEY_ALL + '" AND id_server = "' + Config.KEY_ALL + '" AND command = cmd),' +
            '                            1' +
            '                        )' +
            '                    )' +
            '                )' +
            '            )' +
            '        )' +
            '    )' +
            ') AS authorized ' +
            'FROM ' + properties.tableName + ' ' +
            'HAVING authorized = 0',
            [],
            function (err: Dynamic, results: Array<Dynamic>) {
                if (err) {
                    Logger.exception(err);
                    callback(err, null);
                } else {
                    var parsedResults = new Array<String>();

                    for (i in 0...results.length) {
                        parsedResults.push(results[i].cmd);
                    }

                    callback(err, parsedResults);
                }
            }
        );
    }
}
