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
+ Prevent a user from being moved by assigning him to a special group.
+ Compiles to an executable jar that can be run on any platform which has java installed.

## Requirements
+ JRuby 9.0.1.0
+ Java 7
+ The Bundler gem
+ A Teamspeak 3 server with query admin access.

## Installation

1 . Clone this repository.

2 . Define the following environment variables (e.g. in your `.bash_profile` file):

  ```bash
  export P_USER="YOUR_TS3_ADMIN_QUERY_USER_NAME"
  export P_PASSWORD="YOUR_TS3_ADMIN_QUERY_PW"
  export P_IP_ADDRESS="YOUR_TS3_IP_ADDRESS"
  export P_PORT="YOUR_TS3_QUERY_SERVER_PORT"
  export P_SECRET="YOUR_SOCKET_PASSPHRASE"
  export P_SERVER_PATH="PATH_TO_YOUR_LOCAL_SERVER"
  ```

or by setting up a pigeon config file. For doing so perform `cp data/pigeon_config.example.yml data/pigeon_config.yml` and specify the corresponding runtime parameters.

3 . Install the bundler gem via `gem install bundler`.

4 . Install all relevant dependencies by running `bundle`.

## Running

### From source
```bash
./pigeon start
```

### Via compiled jar

#### Windows

1. Run `java -jar pigeon.jar`. When running the executable jar for the first time, a config file called `pigeon_config.yml`
2. Got to `data/` and edit `pigeon_config.yml` with your editor of choice.

#### Mac Os X and Linux

Either define the corresponding the ENV vars defined above or run `java -jar pigeon.jar`. Running the jar for the first time will then generate a config file (if no ENV vars are specified).

