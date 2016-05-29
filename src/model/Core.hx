package model;

import external.discord.channel.PMChannel;
import external.discord.Cache;
import external.discord.Server;
import utils.Logger;
import config.AuthDetails;
import external.discord.user.User;
import external.discord.message.Message;
import external.discord.client.Client;

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

    public function getPrivateChannels(): Cache<PMChannel> {
        return _client.privateChannels;
    }

    public function createCommunicationContext(msg: Message): CommunicationContext {
        return new CommunicationContext(_client, msg);
    }

    public function connect(): Void {
        _client.loginWithToken(AuthDetails.DISCORD_TOKEN, null, null, function (err: Dynamic, token: String): Void {
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
