package model;

import external.discord.message.Message;

interface ICommandDefinition {
    public var paramsUsage: String;
    public var description: String;
    public var hidden: Bool;

    public function process(msg: Message, args: Array<String>): Void;
}
