package model.entity;

import utils.Logger;
import model.Entity.EntityProperties;

class Staff extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'staff',
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
                name: 'notify_new_member',
                mappedBy: 'notifyNewMember',
                primary: false
            }
        ]
    };

    public var idUser: String;
    public var idServer: String;
    public var notifyNewMember: Bool;

    public static function getStaffToNotifyAboutNewMember(idServer: String, callback: Array<Staff>->Void): Void {
        Db.instance.getAll('SELECT * FROM ' + properties.tableName + ' WHERE id_server = ? AND notify_new_member = ?', [idServer, true], function (err: Dynamic, rows: Array<Dynamic>): Void {
            if (err == null) {
                var ret: Array<Staff> = new Array<Staff>();

                for (row in rows) {
                    var staff = new Staff();

                    staff.idUser = row.id_user;
                    staff.idServer = row.id_server;
                    staff.notifyNewMember = row.notify_new_member;

                    ret.push(staff);
                }

                callback(ret);
            } else {
                Logger.exception(err);
                callback(null);
            }
        });
    }
}
