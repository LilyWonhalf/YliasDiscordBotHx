package model.entity;

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
    public var idServer: String;
    public var command: String;
    public var granted: Bool;

    public static function check(idUser: String, idServer: String, command: String, callback: Bool->Void): Void {
        Db.instance.get(
            'SELECT IF(' +
            '    (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '    (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '    IF(' +
            '        (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = "' + command + '"),' +
            '        (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = "' + command + '"),' +
            '        IF(' +
            '            (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '            (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '            IF(' +
            '                (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "0" AND command = "' + command + '"),' +
            '                (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "0" AND command = "' + command + '"),' +
            '                1' +
            '            )' +
            '        )' +
            '    )' +
            ') AS granted',
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

    public static function getDeniedCommandList(idUser: String, idServer, callback: Dynamic->Array<String>->Void): Void {
        Db.instance.getAll(
            'SELECT DISTINCT command AS cmd, (' +
            '    SELECT IF(' +
            '        (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '        (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '        IF(' +
            '            (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = cmd),' +
            '            (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = cmd),' +
            '            IF(' +
            '                (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                IF(' +
            '                    (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "0" AND command = cmd),' +
            '                    (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "0" AND command = cmd),' +
            '                    1' +
            '                )' +
            '            )' +
            '        )' +
            '    )' +
            ') AS authorized ' +
            'FROM permission ' +
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
