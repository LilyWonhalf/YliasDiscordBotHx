package external.discord;

import nodejs.Buffer;
import external.discord.channel.ServerChannel;
import external.discord.channel.PMChannel;
import external.discord.channel.TextChannel;
import external.discord.channel.VoiceChannel;
import external.discord.permission.Role;
import external.discord.user.User;
import external.discord.message.Message;
import external.discord.channel.Channel;
import haxe.extern.EitherType;

class Resolvables {}

typedef ChannelResolvable = EitherType<Channel, EitherType<Server, EitherType<Message, EitherType<User, String>>>>
typedef FileResolvable = String
typedef RoleResolvable = EitherType<String, Role>
typedef VoiceChannelResolvable = EitherType<String, VoiceChannel>
typedef MessageResolvable = EitherType<Message, EitherType<TextChannel, PMChannel>>
typedef UserResolvable = EitherType<User, EitherType<Message, EitherType<TextChannel, EitherType<PMChannel, EitherType<Server, String>>>>>
typedef StringResolvable = EitherType<Array<EitherType<String, EitherType<Float, Int>>>, String>
typedef ServerResolvable = EitherType<Server, EitherType<ServerChannel, EitherType<Message, String>>>
typedef InviteResolvable = EitherType<Invite, String>
typedef Base64Resolvable = EitherType<Buffer, String>