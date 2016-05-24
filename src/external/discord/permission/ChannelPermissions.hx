package external.discord.permission;

import external.discord.permission.Role.Permission;

extern class ChannelPermissions {
    public function serialise(): SerializedPermissions;
    public function serialize(): SerializedPermissions;
    public function hasPermission(permission: Permission): Bool;
}

