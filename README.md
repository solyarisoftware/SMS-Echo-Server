SMS Echo Server (using Skebby)
==============================

Simple Ruby Sinatra SMS Echo Server, using [www.skebby.com](http://www.skebby.com) SMS Gateways services.

[www.skebby.com](http://www.skebby.com) is an Italian SMS gateway service provider with cheap prices and high quality services! 

<p align="center">
  <img src="http://static.skebby.it/s/i/sms-gratis-business.png" alt="skebby logo">
</p>


This project is Yet Another Simple [Sinatra](http://www.sinatrarb.com/) Application acting as "SMS echo server":

- An *end user* send a standard SMS to a *customer application* that supply a Skebby *Receive SMS* service (each "receive sms" service can be identified by a mobile phone number + application *keyword*)

- Skebby server forward that SMS through an HTTP POST/GET to a *Custom(er) Application Server* to be configured in Skebby through an initial web configuration.

- This project realize the *Company Application Server*, log the received SMS data (RX) and 

- send back (TX) to mobile phone sender number a SMS message with pretty the same text payload (ECHO mode).

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

## Step 0. Create your Skebby account

- Configure Username and Password

Register at Skebby to get your credentials:

&nbsp;&nbsp;&nbsp;&nbsp;<your_skebby_username>
&nbsp;&nbsp;&nbsp;&nbsp;<your_skebby_password>

### Send SMS Skebby Services

Yo have to puchase a pack of some number of SMS to send SMS through the Skebby APIs. 
Please refer to Skebby website for detailed info about commercial offers to send SMSs.

### Receive SMS Skebby Services

To receive SMSs skebby propose to companies the purchase of: 

1. *dedicated mobile phone number* where receive SMSs from end users

or in alternative the purchase of: 

2. *shared mobile phone number + KEYWORD* 

Please refer to Skebby website for detailed info about commercial offers to receive SMSs.

For both scenarios, you have to configure the URL where you want to receive messages configuring a POST URL Callback in your Skebby SMS receive configuration page:

&nbsp;&nbsp;&nbsp;&nbsp;<your_ngrok_url>/echoserver/skebby

The callback URL will be by example: 

&nbsp;&nbsp;&nbsp;&nbsp;`https://a1b2c3d4.ngrok.com/echoserver/skebby`


I done some tests here using the *shared mobile phone number + KEYWORD* approach.
In this case end user send a SMSs to the Company Application with a message text with the format:   

&nbsp;&nbsp;&nbsp;&nbsp;<KEYWORD><separator_char><free_message_text>

Where:

- <KEYWORD> is the Application ID assigned in initial configuration phase in Skebby website. KEYWORD is not case sensitive and possibly shortest possible (to avoid to waste charcters).
- <separator_char> a blank character to separate the keyword from the text payload.
- <free_message_text> is the free text payload, that is the message text the user want to send to the application (please note that max length of number of chars of text payload is: 160 - keyword length - lenght separator).

Let say your KEYWORD is "TEST69"; and shared number is "39 339 99 41 52 52", so to send a message "Hello World!" to the application, the end user have to send from his mobile phone a __Standard SMS__ to number "339 99 41 52 52" (please be careful to remove initial international prefix "39") with text: "TEST69 Hello World!".


## Step 1. Install stuff

- Install source code: 

```
$ git https://github.com/solyaris/SMS-Echo-Server.git
```

- Install all required gems: 

```
$ cd SMS-Echo-Server; bundle install
```


## Step 2. run Sinatra server (in your localhost)


### Set your Skebby credentials as environment variables:

	$ export SKEBBY_USERNAME=<your_skebby_username>
	$ export SKEBBY_PASSWORD=<your_skebby_password>


### Run sinatra server in Developement

To automatically reload rack development server, when developing/debugging, I enjoyed [`shotgun`](https://github.com/rtomayko/shotgun)

run shotgun, at port 9393 with command:

```
shotgun config.ru -o 127.0.0.1 -p 9393 -E development
```

### run server in "Production"

You run on port 9393, with command:

```
ruby app.rb -o 127.0.0.1 -p 9393 -e production
```

## Step 3. publish your local dev server!

I'm very happy with great [ngrok](https://ngrok.com/) tunneling, reverse proxy:
please visit ngrock home page, download sw and run in a new terminal:

```
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


## Step 4. Locally test your Skebby echo server!

Now you can test locally calling a the service endpoint to receive SMSs.

Just to verify your echo server is up and running, open a terminal and enjoy:

```
curl -i -X GET  http://a1b2c3d4.ngrok.com
```

To simulate an invocation by Skebby server after the rx of a SMS:

```
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
Date: Sat, 25 Jan 2014 15:50:26 GMT
Content-Type: application/json;charset=utf-8
Content-Length: 222
Connection: keep-alive
X-Content-Type-Options: nosniff

{
  "SMS RECEIVED": {
    "sender": "39xxxxxxxxxx",
    "receiver": "3933999415252",
    "encoding": "UTF-8",
    "date": "2014-01-25",
    "time": "12:02:28",
    "timestamp": "1390647748",
    "smsType": "standard"
  }
}

```

## Step 5. End-to-end test your echo server!

- Keep you mobile phone in your hand 
- send a SMS to you Skebby *application number* (let say the mobile number: "339 99 41 52 52", 
- write your test text message; assuming your *application keyword* is "TEST69", and you want to send  message "Hello World!", so please send the message text:

```
TEST69 Hello World!
```

- in few moments your Sinatra app will receive a HTTP POST request from Skebby server 
(after your Skebby web configuration page, where you set the forward URL as: http: //a1b2c3d4.ngrok.com/echoserver/skebby ).  
- The HTTP request contain in *params* all data of SMS message 

```
params[:sender]
params[:receiver]
params[:text]
params[:encoding]
params[:date]
params[:time]
params[:timestamp]
params[:smsType])
```	

- the echo server will log data with logger enabler and will forwarded back to your mobile phone number the message!

```
ECHO Hello World!
```


## Discussion

The simple scope of the echo server is just to quickly test and debug Skebby service features (SMS gateways Send and receive SMS APIs).

The further step could be to realize ANY sort of *Company Application Server* that elaborate SMSs received by *end users*. To develop a complex application example is out of scope of this small open-source project; feel free to CONTACT ME for your project as JOBS!


## Release Notes

### v.0.2.1
- Prerelease: 28 January 2014
- Send back message to mobile phone end user SMS sender (TX SMS via SMS gateway). 
- fixed curl call example
- Data flow better explained in this readme

### v.0.1.1
- First release: 25 January 2014


## To do
- remove any puts :-( and seriously log SMS TX Gateway API responses
- better logging
- manage GET requests
- rethink about the client side usage of SMS TX Gateway API call  

## Licence

Feel free to do what you want with my source code. It's free! 
BTW, a mention/feedback to me will be very welcome and star the project if you feel it useful!


## Special Thanks

- [Alan Shreve](https://github.com/inconshreveable/ngrok), for his great tunneling, reverse proxy open source project [ngrok](https://ngrok.com/)
- [Tommaso Visconti](https://github.com/tommyblue), for his code for send SMS Ruby code [send_sms.rb](https://github.com/solyaris/skebby_echo_server/blob/master/send_sms.rb) and generally for his many useful posts about sw programming (by example [this one](http://www.tommyblue.it/2012/01/18/notifiche-sms-gratis-con-nagiosicinga-e-skebby) ).
- [Paolo Montrasio](https://github.com/pmontrasio), that forst of all talked to me about Skebby features.

# Contacts

### Skebby
To create your account for Skebby services, getting API credentials (username, password) and buying a credit, please visit: [www.skebby.com](http://www.skebby.com).

### About me
I develop mainly using Ruby (on Rails) for server side programming. I'm also a music composer and a mountaineer. Home page: [http://about.me/solyaris](http://about.me/solyaris)

Please feel free to write an e-mail with your comments and jobs proposals are more than welcome.
E-mail: [giorgio.robino@gmail.com](mailto:giorgio.robino@gmail.com)
