{ readdirSync   } = require 'node:fs'
{ REST          } = require '@discordjs/rest'
{ Routes        } = require 'discord-api-types/v9'
{ Client        } = require 'discord.js'
{ config        } = require './config.json'

client = new Client
    allowedMentions:
        parse: ["users"]
        repliedUser: false
    intents: [
        "GUILDS",
        "GUILD_MESSAGES",
        "GUILD_MESSAGE_REACTIONS",
        "DIRECT_MESSAGES",
    ]
    partials: ["CHANNEL"]

cmd_json = new Array
files = readdirSync './cmd/'
    .filter (file) -> file.endsWith '.coffee'

do ->
    for file from files
        cmd = require "./cmd/#{file}"
        cmd_json.push cmd.data.toJSON

rest = new REST().setToken(config.token)
do -> #Global commands
    rest.put(
        Routes.applicationCommands config.clientid,
        { body: cmd_json }
    )
        .then () -> console.log 'INFO: Command registration successful'
        .catch console.error

client.on 'interactionCreate', (interaction) ->
    if !interaction.isCommand
        return
    require "./cmd/#{interaction.commandName}.js"
        .execute interaction

client.login config.token
    .then console.log 'INFO: Logged in'