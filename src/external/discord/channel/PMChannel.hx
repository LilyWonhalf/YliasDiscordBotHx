package external.discord.channel;

import external.discord.user.User;
import external.discord.message.Message;

extern class PMChannel extends Channel {
    public var messages: Cache<Message>;
    public var recipient: User;
    public var lastMessage: Message;
}
