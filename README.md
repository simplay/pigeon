# pigeon

Implementing a jruby TS3 Bot using [TeamSpeak-3-Java-API](https://github.com/TheHolyWaffle/TeamSpeak-3-Java-API).

This project makes use of the [chatter-bot-api](https://github.com/pierredavidbelanger/chatter-bot-api) and uses a compiled version of its java implementations. 

This project is licensed under the [MIT License](https://github.com/simplay/pigeon/blob/master/LICENSE).

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

3. Install dependencies with `bundle`

## Running

```bash
./pigeon start
```
