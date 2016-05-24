package external.discord.channel;

import external.discord.client.Client;
import external.discord.Object;

extern class Channel extends Equality implements Object {
    public var client: Client;
    public var isPrivate: Bool;

    public function delete(): Void;
}
