# pigeon

Implementing a jruby TS3 Bot using [TeamSpeak-3-Java-API](https://github.com/TheHolyWaffle/TeamSpeak-3-Java-API).

This project is licensed under the [MIT License](https://github.com/simplay/pigeon/blob/master/LICENSE).

## Requirements
+ JRuby 9.0.0.1
+ Java 7
+ The Bundler gem
+ A Teamspeak 3 server with query admin access. Please note that the following **Guest Server Goup** permissions have to be set like specified below in order to let the bot run properly:

 + `b_virtualserver_info_view 1`
 + `b_virtualserver_channel_list 1`
 + `b_virtualserver_client_list 1`
 + `b_virtualserver_servergroup_list 1`
 + `b_virtualserver_channelgroup 1`
