SMS Echo Server (using Skebby)
==============================

Simple Ruby Sinatra SMS Echo Server, using [www.skebby.com](http://www.skebby.com) SMS Gateways services.
Skebby is an Italian SMS gateway service provider with cheap prices and high quality services! 

<p align="center"><img src="http://static.skebby.it/s/i/sms-gratis-business.png" alt="skebby logo"></p>

This project is Yet Another Simple [Sinatra](http://www.sinatrarb.com/) Application, acting as "SMS echo server", using Skebby services/APis enablers behind the scenes:

## SMS Data Flow

1. An *end User* send a "standard SMS" to a *Customer Application* that supply a Skebby *Receive SMS* service (each *Receive SMS* service can be identified by an assigned mobile phone number + Customer *keyword*)

2. Skebby server forward that SMS through an HTTP POST ( or GET) to a *Customer Application Server* to be configured in Skebby through an initial web configuration. This project realize a simple example of that *Company Application Server*. The Echo Server simply log the received SMS data and 

3. send back (TX) to mobile phone sender number a SMS message with pretty the same text payload (ECHO mode).

```

     An end user, with a mobile phone 
                             
       ^                | 1. send a Standard SMS with text: "TEST69 Hello World!"
       |                | 
       | 6. receive back an echo SMS with text: "ECHO Hello World!"
       |                | 
       |                v
   .-------------------------------------------.
   |                                           |
   |         SKEBBY SMS GATEWAY SERVER         |
   |                                           |
   .-------------------------------------------.
       ^                |
       |                | 2. HTTP POST http://a1b2c3d4.ngrok.com/echoserver/skebby
       |                v
       |   .----------------------------.   ^
       |   | Company Application Server |   |  
       |   |   == this echo server      |   |
       |   |                            |   |
       |   .----+-------------+----+----.   |
       |        |             |    |        |  4.JSON response (for test/debug purposes)
       |        |             |    +--------+
       |        |             +-------> 3. log/store (on a database) received SMS data
       +--------+
     5. echo back a SMS ( via HTTP POST http://gateway.skebby.it/api/send/... )

```

## Step 1. Create your Skebby account

Create your account registering at Skebby website to get your credentials:

* \<your_skebby_username\>
* \<your_skebby_password\>

### Send SMS Skebby Services

Yo have to puchase a pack of some number of SMS to send SMS through the Skebby APIs. 
Please refer to Skebby website for detailed info about commercial offers to send SMSs.

### Receive SMS Skebby Services

To receive SMSs skebby propose to companies the purchase of: 

- *DEDICATED NUMBER*

where receive SMSs from end users, or in alternative the purchase of: 

- *SHARED NUMBER + KEYWORD* 

Please refer to Skebby website for detailed info about commercial offers to receive SMSs.

For both scenarios, you have to configure the URL where you want to receive messages configuring a POST URL callback in your Skebby SMS receive configuration page:

```
\<your_ngrok_url\>/echoserver/skebby
```

The callback URL will be by example: https: // a1b2c3d4.ngrok.com/echoserver/skebby

I done some tests here using the *shared mobile phone number + KEYWORD* approach.
In this case end user send a SMSs to the Company Application with a message text with the format:   

```
<KEYWORD><separator_char><free_message_text>
```

Where:

- `<KEYWORD>` is the Application ID assigned in initial configuration phase in Skebby website. KEYWORD is not case sensitive and possibly shortest possible (to avoid to waste charcters).

- `<separator_char>` a blank character to separate the keyword from the text payload.

- `<free_message_text>` is the free text payload, that is the message text the user want to send to the application (please note that max length of number of chars of text payload is: 160 - keyword length - lenght separator).

Example:

Let say your keyword> is: "TEST69" and shared number is: "39 339 99 41 52 52", so to send a message "Hello World!" to the Application, the end user have to send from his mobile phone a *Standard SMS* to number "339 99 41 52 52" (please be careful to remove initial international prefix, e.g. for Italy: "39") with text: 

```
TEST69 Hello World!
```

## Step 2. Install stuff

- Install source code: 

```
$ git https://github.com/solyaris/SMS-Echo-Server.git
```

- Install all required gems: 

```
$ cd SMS-Echo-Server; bundle install
```

## Step 3. run Sinatra server (in your localhost)


### Set your Skebby credentials as environment variables:

```bash
	$ export SKEBBY_USERNAME=<your_skebby_username>
	$ export SKEBBY_PASSWORD=<your_skebby_password>
```

### Run sinatra server in Developement

To automatically reload rack development server, when developing/debugging, I enjoyed [`shotgun`](https://github.com/rtomayko/shotgun)

run shotgun, at port 9393 with command:

```bash
shotgun config.ru -o 127.0.0.1 -p 9393 -E development
```

### run server in "Production"

You run on port 9393, with command:

```bash
ruby app.rb -o 127.0.0.1 -p 9393 -e production
```

## Step 4. publish your local dev server with ngrok!

I'm very happy with great [ngrok](https://ngrok.com/) tunneling, reverse proxy:
please visit ngrock home page, download sw and run in a new terminal:

```bash
cd /your/path/to/ngrok; ./ngrok 9393
```

ngrok will so give a public forward URL and display realtime http requests status:

	Tunnel Status                 online
	Version                       1.6/1.5
	Forwarding                    http://a1b2c3d4.ngrok.com -> 127.0.0.1:9393
	Forwarding                    https://a1b2c3d4.ngrok.com -> 127.0.0.1:9393
	Web Interface                 127.0.0.1:4040
	# Conn                        27
	Avg Conn Time                 443.47ms


	HTTP Requests
	-------------

	POST /skebby/receivesms       200 OK
	POST /skebby/receivesms       200 OK

[ngrok](https://ngrok.com/) it's a really excellent tool allowing developers to quickly publish any localhost application on internet through HTTP/HTTPS (and also TCP IP net applications!).  

ngrok is also FREE and allow to reserve you personal immutable subdomains paying though a [pay-what-you-want service](https://ngrok.com/features) !


## Step 5. Locally test the echo server!

Now you can test locally calling a the service endpoint to receive SMSs.

Just to verify your echo server is up and running, open a terminal and enjoy:

```bash
curl -i -X GET  http://a1b2c3d4.ngrok.com
```

To simulate an invocation by Skebby server after the rx of a SMS:

```bash
curl -i -X POST  https://a1b2c3d4.ngrok.com/echoserver/skebby \
-F 'sender=39xxxxxxxxxx' \
-F 'receiver=3933999415252' \
-F 'text=TEST123 Hello World!' \
-F 'encoding=UTF-8' \
-F 'date=2014-01-25' \
-F 'time=12:02:28' \
-F 'timestamp=1390647748' \
-F 'smsType=standard'
```

BTW, echo server feed back a JSON response:

```
HTTP/1.1 200 OK
Server: nginx/1.4.3
Date: Tue, 28 Jan 2014 17:34:51 GMT
Content-Type: application/json;charset=utf-8
Content-Length: 395
Connection: keep-alive
X-Content-Type-Options: nosniff

{
  "SMS RECEIVED": {
    "sender": "39XXXXXXXXXXX",
    "receiver": "3933999415252",
    "text": "TEST123 Hello World!",
    "encoding": "UTF-8",
    "date": "2014-01-25",
    "time": "12:02:28",
    "timestamp": "1390647748",
    "smsType": "standard"
  },
  "SMS SENT": {
    "status": "success",
    "text": "ECHO Hello World!",
    "receiver": "39XXXXXXXXXXX",
    "remaining_sms": 145
  }
}

```

## Step 6. End-to-end test: SMS TX -> ECHO SMS RX!

- Keep you mobile phone in your hand 
- send a SMS to you Skebby *application number* (let say the mobile number: "339 99 41 52 52", 
- write your test text message; assuming your *application keyword* is "TEST69", and you want to send  message "Hello World!", so please send the message text:

```
TEST69 Hello World!
```

- in few moments your Sinatra app will receive a HTTP POST request from Skebby server 
(after your Skebby web configuration page, where you set the forward URL as: http: //a1b2c3d4.ngrok.com/echoserver/skebby ).  
- The HTTP request contain in *params* all data of SMS message, transmitted by Skebby server. 
- This echo server log data and forwarded back to your mobile phone number the message:

```
ECHO Hello World!
```


## Notes

### Bidirectional SMS Services (end users <-> application server)

The scope of that simple echo server is just to quickly test and debug Skebby service features (SMS gateways Send APIs and Receive SMS through the HTTP proxy behaviours).

A further step could be to realize ANY sort of *Company Application Server* that elaborate SMSs received by *end users*. 

The develop of a complex application is out of scope of this small open-source project; so feel free to contact me for your project as job proposal!


### About Skebby Services

Pros: 
I enjoyed the very fast and reliable end-to-end delivery time elapseds using `send_sms_classic` SMSs: usually the end-to-end echo back take no more than few seconds. great!
I got worst performances sending cheapest `send_sms_basic` SMSs (elapsed times start from half a minute to 5/15 minutes).

Minus:
Website (registration/configuration/etc.) is pretty well done but there are some areas of improvements in organization of "storyboards" (you can find a lot of info but you lost yourself easely). Last but not least, documentation of some behaviours is not too clear (by example the format of message with KEYWORD (the need of a separator) is not correctly explained in Skebby website). Not a big problem after some debug :-)

All in all my feedback about Skebby services are positive!


## Release Notes

### v.0.3.0
- Prerelease: 28 January 2014
- I enjoy using [Skuby](https://github.com/welaika/skuby) gem to send SMS! 
- Data flow better explained in this README
- fixed curl call example

### v.0.1.1
- First release: 25 January 2014


## To do
- better logging
- manage GET requests
- more clean Sinatra code (initializations)

## Licence

Feel free to do what you want with my source code. It's free! 
BTW, a mention/feedback to me will be very welcome and STAR the project if you feel it useful!


## Special Thanks

- [Alan Shreve](https://github.com/inconshreveable/ngrok), for his great tunneling, reverse proxy open source project [ngrok](https://ngrok.com/)

- [Tommaso Visconti](https://github.com/tommyblue), for his code for send SMS Ruby code [code](http://www.skebby.it/business/index/code-examples/?example=sendRuby) and generally for his many useful posts about sw programming (by example [this one](http://www.tommyblue.it/2012/01/18/notifiche-sms-gratis-con-nagiosicinga-e-skebby) ).

- [Paolo Montrasio](https://github.com/pmontrasio), that long time ago suggested to me Skebby features.

- [Fabrizio Monti](https://github.com/welaika), for his smart Ruby interface for Skebby [Skuby](https://github.com/welaika/skuby)


# Contacts

### Skebby people
To create your account for Skebby services, getting API credentials (username, password) and purchase your SMS credit, please visit: [www.skebby.com](http://www.skebby.com).

### About me
I develop using Ruby, when possible and also when is not possible. I'm also a music composer and a mountaineer. Home page: [http://about.me/solyaris](http://about.me/solyaris)

Please feel free to write an e-mail with your comments and jobs proposals are more than welcome.
E-mail: [giorgio.robino@gmail.com](mailto:giorgio.robino@gmail.com)
