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

## Installation
1 Clone this repository.

2 Create a text file in `./secrets/` called `credentials.txt`. This file is supposed to contain the query admin login data, the server ip address and the server port. The file is structured as the follows: 
```
query admin login name
query admin login password
server ip address
server port
```
Do not worry, this wile is ignored by git and thus cannot accidently commited onto this repository in case you plan to contribute. 

3 run bundler via `bundle`.

4 run the bot via `ruby pigeon`.
