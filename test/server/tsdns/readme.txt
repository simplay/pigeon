#############################################
                    TSDNS
#############################################


TS DNS is a system that allows TeamSpeak users to connect to servers that are
running on arbitrary ports without having to specify the port. The "TSDNS name"
is used by the system to determine IP and Port. It can be compared to some
extent to the "Virtual Host" system of Apache in its purpose, though the
technical aspects are very much different.

Motivation
----------
Say you own a server running on the IP 1.2.3.4 and Port 4321. Telling people
you want to join your server to join "1.2.3.4:4321" or (using regular DNS)
"myclanrocks.net:4321" works, but the port there is an extra source of
confusion to inexperienced users. It would be nice if you could just tell
people to join "myclanrocks.net" (as if your TS server were running on the
default port).

How it works
------------
A TSDNS server is a very simple network service that uses TCP/IP to listen on
port 41144 (default) and knows a list of (query,result) pairs. Upon connecting
to the TSDNS server you must submit your query and the TSDNS server will answer
you with the result, if it has this query in his list, or with "404" if no such
query is known to it. The result is supposed to be either an IP (which assumes
a port of 9987) or an IP:Port pair. Instead of a number as port the special
string "$PORT" is also allowed, which results in any port specified on the
client side to be used.

Whenever a TeamSpeak Client tries to connect to a server using a hostname,
it will try to connect to up to four possible TSDNS servers to try and
retrieve a (IP, Port) pair using the hostname as string that the TSDNS server
is queried with.

Illustration:
hostname=voice.teamspeak.com
TSDNS Server asked queried are:
- voice.teamspeak.com  (with query = voice.teamspeak.com)
- teamspeak.com        (with query = voice.teamspeak.com)
- com                  (with query = voice.teamspeak.com)

Second Example (with longer hostname)
hostname=i.will.roxx.your.soxs.myclan.com
- your.soxs.myclan.com (with query = i.will.roxx.your.soxs.myclan.com)
- soxs.myclan.com      (with query = i.will.roxx.your.soxs.myclan.com)
- myclan.com           (with query = i.will.roxx.your.soxs.myclan.com)
- com                  (with query = i.will.roxx.your.soxs.myclan.com)

Third Example (with short hostname)
hostname=myclanrocks.net
- myclanrocks.net     (with query = myclanrocks.net)
- net                 (with query = myclanrocks.net)

If any of these succeed to retrieve an answer from a TSDNS server the one to
answer first is used to connect. If all of the above TSDNS server queries fail
(usually due to no TSDNS servers running on the (up to) four hosts), the
TeamSpeak Client will fall back to a regular DNS resolve of the hostname.

SRV Records
-----------
With Client 3.0.8 and higher, the TS3 Client supports looking up so called SRV
records in addition to the regular hostname resolves that it continues to do
just as before. Adding SRV records directly in your name server configuration
can act as a replacement for the TSDNS service, you could add a SRV record like
this: "_ts3._udp.myclanrocks.net. 86400 IN SRV 10 5 4321 myclanrocks.net."

This would also solve the scenario presented above, it would allow people to
join your TS3 server running on the non-standard port of "4321" to connect by
simply entering "myclanrocks.net" as server address.

SRV Records are not only supported to direct you to a TS3 server, but also to
direct you to a TSDNS server, creating a double redirect situation. This
allows you to run the TSDNS server on arbitrary machines and hosts, while
still "servicing" the domain you wish. To add a SRV record that directs to your
TSDNS server, use the following format:
"_tsdns._tcp.teamspeak.com. 86400 IN SRV 0 0 41144 voice.teamspeak.com."

The question arises what the order of precedence is with these various resolve
methods:
#1 _ts3 SRV record
#2 _tsdns SRV record
#3 TSDNS
#4 DNS
