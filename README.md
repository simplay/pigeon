# pigeon

Pigeon is a TS3 administration bot written in Jruby. Technically, this bot establishes a Server Admin Query (SAQ) connection to a target TS3 Server. 
The motivation for implementing this bot is manyfold: Define a basic client moderation system (move idle clients to an afk channel, have some notion of authentication), 
connect teamspeak with other applications (such as displaying server stats from other linked gameservers) 
and entertain bored users and make them happy (crawler- and chatbots-functionalities).

The implementing is relying on the [TeamSpeak-3-Java-API](https://github.com/TheHolyWaffle/TeamSpeak-3-Java-API).
In addition, this project makes use of the [chatter-bot-api](https://github.com/pierredavidbelanger/chatter-bot-api) and uses a compiled version of its java implementations. 

This project is licensed under the [MIT License](https://github.com/simplay/pigeon/blob/master/LICENSE).

## Features

+ A fancy command system that uses TS3 authentication system
+ Stores posted links and allow to retrieve them.
+ Allows to move clients by their name (fuzzy).
+ Integration of Cleverbot and Pandorabot.
+ Various Reddit crawlers.
+ Show server stats of a linked minecraft server in real time.
+ Moves (automatically) idle players to an AFK channel

## Requirements
+ JRuby 9.0.1.0
+ Java 7
+ The Bundler gem
+ A Teamspeak 3 server with query admin access. Please note that the following **Guest Server Goup** permissions have to be set like specified below in order to let the bot run properly:

 + `b_virtualserver_info_view 1`
 + `b_virtualserver_channel_list 1`
 + `b_virtualserver_client_list 1`
 + `b_virtualserver_servergroup_list 1`
 + `b_virtualserver_channelgroup 1`

## Installation

1. Clone this repository.

2. Define the following environment variables (e.g. in your `.bash_profile` file):

  ```bash
  export P_USER="YOUR_TS3_ADMIN_QUERY_USER_NAME"
  export P_PASSWORD="YOUR_TS3_ADMIN_QUERY_PW"
  export P_IP_ADDRESS="YOUR_TS3_IP_ADDRESS"
  export P_PORT="YOUR_TS3_QUERY_SERVER_PORT"
  export P_SECRET="YOUR_SOCKET_PASSPHRASE"
  ```
3. Install the bundler gem via `gem install bundler`.

4. Install all relevant dependencies by running `bundle`.

## Running

```bash
./pigeon start
```
