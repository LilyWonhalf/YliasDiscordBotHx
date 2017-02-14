package yliasdiscordbothx.model;

import discordbothx.log.Logger;
import yliasdiscordbothx.model.Entity.EntityProperties;

class Entity {
    public static var properties: EntityProperties;

    private var localProperties(get,null): EntityProperties;
    private var isNew: Bool;

    public static function getAll<T>(entity: Class<T>, callback: Array<T>->Void): Void {
        var entityProperties: EntityProperties = cast Reflect.field(entity, 'properties');
        var tableColumns: Array<TableColumn> = entityProperties.tableColumns;
        var columnPropertyMap = new Map<String, String>();

        for (column in tableColumns) {
            columnPropertyMap.set(column.name, column.mappedBy);
        }

        Db.instance.query('SELECT * FROM ' + entityProperties.tableName, null, function(error: Dynamic, rows: Array<Dynamic>) {
            if (error != null) {
                Logger.exception(error);
            }

            var result = new Array<T>();

            for (row in rows) {
                var entity = Type.createInstance(entity, []);

                for (column in Reflect.fields(row)) {
                    Reflect.setProperty(entity, columnPropertyMap.get(column), Reflect.field(row, column));
                }

                result.push(entity);
            }

            callback(result);
        });
    }

    public function new() {
        isNew = true;
    }

    public function retrieve(primaryValues: Map<String, String>, ?callback: Bool->Void): Void {
        var primaryFields = primaryValues.keys();
        var queryWhere = '';

        for (key in primaryFields) {
            if (queryWhere.length > 0) {
                queryWhere += ' AND ';
            }

            queryWhere += getColumnNameFromMappedName(key) + ' = "' + primaryValues.get(key) + '"';
        }

        Db.instance.get('SELECT * FROM ' + localProperties.tableName + ' WHERE ' + queryWhere, [], function(error: Dynamic, row: Dynamic) {
            if (error != null || row == null) {
                isNew = true;
            } else {
                isNew = false;

                for (column in localProperties.tableColumns) {
                    Reflect.setProperty(this, column.mappedBy, Reflect.field(row, column.name));
                }
            }

            if (callback != null) {
                callback(!isNew);
            }
        });
    }

    public function get(primaryValues: Map<String, String>, ?callback: Bool->Void): Void {
        retrieve(primaryValues, callback);
    }

    public function save(?callback: Dynamic->Void): Void {
        var query: String;
        var columns = new Array<String>();
        var primaries = new Array<String>();
        var values = new Array<String>();
        var columnMap = getColumnMap();

        if (isNew) {
            query = 'INSERT INTO `' + localProperties.tableName + '` ';
        } else {
            query = 'UPDATE `' + localProperties.tableName + '` SET ';
        }

        for (column in localProperties.tableColumns) {
            if (isNew) {
                columns.push(column.name);
            } else {
                if (column.primary) {
                    primaries.push(column.name);
                } else {
                    columns.push(column.name);
                }
            }
        }

        if (isNew) {
            var valuesFiller = new Array<String>();

            for (i in 0...columns.length) {
                valuesFiller.push('?');
            }

            query += '(' + columns.join(', ') + ') VALUES(' + valuesFiller.join(', ') + ')';
        }

        for (i in 0...columns.length) {
            var column = columns[i];

            if (!isNew) {
                if (i > 0) {
                    query += ', ';
                }

                query += column + ' = ?';
            }

            values.push(
                getSqlValue(
                    Reflect.getProperty(
                        this,
                        columnMap.get(column)
                    )
                )
            );
        }

        if (!isNew) {
            query += ' WHERE ';

            for (i in 0...primaries.length) {
                var primary = primaries[i];

                if (i > 0) {
                    query += ' AND ';
                }

                query += primary + ' = ?';

                values.push(getSqlValue(Reflect.getProperty(this, primary)));
            }
        }

        Logger.notice('Saving entity:\n\n' + query + '\n\nwith values\n\n' + values.join('\n'));

        isNew = false;

        Db.instance.execute(query, values, cast callback);
    }

    public function remove(?callback: Dynamic->Void): Void {
        if (!isNew) {
            var primaries = new Array<String>();
            var values = new Array<String>();
            var query = 'DELETE FROM `' + localProperties.tableName + '` WHERE ';

            for (column in localProperties.tableColumns) {
                if (column.primary) {
                    primaries.push(column.mappedBy);
                }
            }

            for (i in 0...primaries.length) {
                var primary = primaries[i];
                var value: String = getSqlValue(Reflect.getProperty(this, primary));

                if (i > 0) {
                    query += ' AND ';
                }

                query += getColumnNameFromMappedName(primary) + ' = ?';
                values.push(value);
            }

            Logger.notice('Deleting entity:\n\n' + query + '\n\nwith values\n\n' + values.join('\n'));
            Db.instance.execute(query, values, cast callback);
        }
    }

    private function getSqlValue(value: Dynamic): Dynamic {
        var ret: Dynamic = value;

        if (Std.is(value, Bool)) {
            if (value) {
                ret = 1;
            } else {
                ret = 0;
            }
        }

        return ret;
    }

    private function getColumnNameFromMappedName(mappedName: String): String {
        var columnName: String = mappedName;

        for (column in localProperties.tableColumns) {
            if (column.mappedBy == mappedName) {
                columnName = column.name;
                break;
            }
        }

        return columnName;
    }

    private function get_localProperties(): EntityProperties {
        var childClass = Type.getClass(this);
        var properties: EntityProperties = cast Reflect.field(childClass, 'properties');

        return properties;
    }

    private function getColumnMap(): Map<String, String> {
        var tableColumns: Array<TableColumn> = localProperties.tableColumns;
        var columnPropertyMap = new Map<String, String>();

        for (column in tableColumns) {
            columnPropertyMap.set(column.name, column.mappedBy);
        }

        return columnPropertyMap;
    }
}

typedef EntityProperties = {
    tableName: String,
    tableColumns: Array<TableColumn>
}

typedef TableColumn = {
    name: String,
    mappedBy: String,
    primary: Bool
}
