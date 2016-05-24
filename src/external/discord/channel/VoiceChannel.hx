package external.discord.channel;

import external.discord.user.User;

extern class VoiceChannel extends ServerChannel {
    public var members: Cache<User>;
}
