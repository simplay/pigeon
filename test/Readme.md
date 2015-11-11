# Test Suite Setup

TODO: Make the following steps less complicated.

1. Get a Teamspeak server

  Download a ts3 server [here](https://www.teamspeak.com/downloads) and extract
  the downloaded zip to a folder named `server` in this test directory.

2. Remember the credentials the server shows you the first time you run it

  Run the ts server with:

  ```
  ./ts3server_mac
  ```

  Remember `loginname`, `password` and `token`.

3. Create a credentials file from the example template and fill in the
   credentials you acquired from step 2.

  ```
  cp test_server_credentials.example.yml test_server_credentials.yml
  ```

  Then edit `test_server_credentials.yml`.
