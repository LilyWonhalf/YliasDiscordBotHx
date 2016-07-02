package model;

import discordhx.Resolvables.Base64Resolvable;
import discordhx.channel.ServerChannel;
import discordhx.channel.Channel;
import discordhx.channel.PMChannel;
import discordhx.Cache;
import discordhx.Server;
import utils.Logger;
import config.AuthDetails;
import discordhx.user.User;
import discordhx.message.Message;
import discordhx.client.Client;

class Core {
    public static var instance(get, null): Core;
    public static var userInstance(get, null): User;

    private static var _instance: Core;

    private var _client: Client;

    public static function get_instance(): Core {
        return _instance;
    }

    public static function get_userInstance(): User {
        return instance._client.user;
    }

    public static function initialize(client: Client): Void {
        _instance = new Core(client);
    }

    public function getServers(): Cache<Server> {
        return _client.servers;
    }

    public function getChannels(): Cache<ServerChannel> {
        return _client.channels;
    }

    public function getPrivateChannels(): Cache<PMChannel> {
        return _client.privateChannels;
    }

    public function setClientAvatar(data: Base64Resolvable, ?callback: Dynamic->Void): Void {
        _client.setAvatar(data, callback);
    }

    public function createCommunicationContext(?msg: Message): CommunicationContext {
        return new CommunicationContext(_client, msg);
    }

    public function connect(): Void {
        _client.loginWithToken(AuthDetails.DISCORD_TOKEN, AuthDetails.DISCORD_EMAIL, AuthDetails.DISCORD_PASSWORD, function (err: Dynamic, token: String): Void {
            if (err != null) {
                Logger.exception(err);
            }
        });
    }

    public function disconnect(): Void {
        _client.logout();
    }

    private function new(client: Client) {
        _client = client;
    }
}
