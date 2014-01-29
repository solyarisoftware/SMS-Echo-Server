SMS Echo Server (using Skebby)
==============================

Simple Ruby Sinatra SMS Echo Server, using [www.skebby.com](http://www.skebby.com) SMS Gateways services.
Skebby is an Italian SMS gateway service provider with cheap prices and high quality services! 

<img src="http://static.skebby.it/s/i/sms-gratis-business.png" alt="skebby logo">

This project is Yet Another Simple [Sinatra](http://www.sinatrarb.com/) Application, acting as "SMS echo server", using Skebby services/APis enablers behind the scenes. The core of Sinatra app is simple as:

```ruby
post "/echoserver/skebby" do
  # send an echo SMS with Skuby::Gateway.send_sms
  echo_sms request, params
end
```

## SMS Data Flow

1. *End User* send a "standard SMS" to a *Customer Application* that supply a Skebby *Receive SMS* service. Each *Receive SMS* service can be identified by an assigned (shared) mobile phone number (+  Customer *keyword*).

2. Skebby server forward that SMS through an HTTP POST (or GET) to a *Customer Application Server* URL to be set in a Skebby web site initial configuration.  

3. This project realize a simple Sinatra server example of that *Company Application Server*. The Echo Server just log the received SMS data (RX) and send back (TX) to the mobile phone sender number a SMS message with the same text payload (ECHO mode).

```

     An end user, with a mobile phone 
                             
       ^                | 1. send a Standard SMS with text: "TEST123 Hello World!"
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

- *your_skebby_username*
- *your_skebby_password*

### Send SMS with Skebby Services

After the free usage, you have to puchase a pack of some number of message to send SMS through the Skebby APIs. Please refer to Skebby website for detailed info about commercial offers about send SMS.

### Receive SMS with Skebby Services

After the free usage, to receive SMS Skebby propose to customers the purchase of: 

- Option 1: *DEDICATED NUMBER*

where receive SMS from end users, or in alternative the purchase of: 

- Option 2: *SHARED NUMBER + KEYWORD* 

Please refer to Skebby website for detailed info about commercial offers to receive SMS.

For both options, you have to configure the URL where you want to receive messages configuring a POST URL *callback* in your Skebby SMS receive configuration page. For this project please configure the endpoint `/echoserver/skebby` so the complete callback URL must have format: `your_callback_url/echoserver/skebby`. By example, if you use ngrok (see later): `https: // a1b2c3d4.ngrok.com/echoserver/skebby`

#### About message text content 
I done some tests using the *shared mobile phone number + KEYWORD* (Option 1). In this case end user send a SMS to the Server Application with a message text with the format:   

```
<KEYWORD><separator_char><free_message_text>
```

Where:

- `<KEYWORD>` is the Application ID assigned in initial configuration phase in Skebby website. KEYWORD is not case sensitive and possibly shortest possible (to avoid to waste charcters).

- `<separator_char>` a blank character to separate the keyword from the text payload.

- `<free_message_text>` is the free text payload, that is the message text the user want to send to the application (please note that max length of number of chars of text payload is: 160 - keyword length - lenght separator).

Example:

Let say your keyword is: "TEST123" and Skebby shared number is: "39 339 99 41 52 52", so to send a message "Hello World!" to the Application, you have to send from his mobile phone a *Standard SMS* to number "339 99 41 52 52" (please be careful to remove initial international prefix, e.g. for Italy: "39") with text: 

```
TEST123 Hello World!
```

## Step 2. Software installation

- Install this project source code: 

```bash
git https://github.com/solyaris/SMS-Echo-Server.git
```

- Install all required gems: 

```bash
cd SMS-Echo-Server; bundle install
```

## Step 3. run Sinatra server (in your localhost)


### Set your Skebby credentials as environment variables:

Open a terminal to run Sinatra Server, and before all set few ENV variables:

```bash
export SKEBBY_USERNAME=your_skebby_username
export SKEBBY_PASSWORD=your_skebby_password
```

### Run Sinatra server in Developement

To automatically reload [rack](http://rack.github.io/) server after changes in source code in development environment, I enjoyed useful [`shotgun`](https://github.com/rtomayko/shotgun). run shotgun, at port 9393 with command:

```bash
shotgun config.ru -o 127.0.0.1 -p 9393 -E development
```

### Or run Sinatra server in Production

You run a super fast Sinatra server on port 9393, with command:

```bash
ruby app.rb -o 127.0.0.1 -p 9393 -e production
```

## Step 4. Deploy the Application Server 

### Option 1: Publish your local server with ngrok!

Wow! I'm very happy with great [ngrok](https://ngrok.com/) tunneling, reverse proxy. 

ngrok is a really excellent tool allowing developers to quickly publish any localhost application on internet through HTTP/HTTPS (and also TCP IP net applications).  

ngrok is also FREE and allow to reserve you personal immutable subdomains paying though a [pay-what-you-want service](https://ngrok.com/features) !

Please visit ngrock home page, create your account in less than 30 seconds and download sw and run in a new terminal:

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

	POST /echoserver/skebby       200 OK
	POST /echoserver/skebby       200 OK


### Option 2: Deploy somewhere on internet

In alternative to the quick solution above, to really deploy on production stable environment, use your preferred cloud environment, pheraps Heroku, Amazon EC2, etc.

#### Deploying to Heroku

```bash
heroku create
git push heroku master
```

The app is now deployed to Heroku. 
Remember to set ENV vars for username, password with commands:

```bash
heroku config:set SKEBBY_USERNAME=your_skebby_username
heroku config:set SKEBBY_PASSWORD=your_skebby_password
```

Check if your Sinastra server is up & running on Heroku:

```bash
curl http://your_heroku_app_name.herokuapp.com
{
  "about": "SMS Echo Server (using Skebby)",
  "version": "0.3.2",
  "home page": "https://github.com/solyaris/SMS-Echo-Server",
  "e-mail": "giorgio.robino@gmail.com"
}
```

## Step 5. Locally test the echo server!

Now you can test locally calling a the service endpoint to receive SMS. Just to verify your echo server is up and running, open a terminal and enjoy:

```bash
curl -X GET http://a1b2c3d4.ngrok.com
```

To simulate an invocation by Skebby server after the rx of a SMS (note the sender number is set as fake example: `390000000000`):

```bash
curl -X POST https://a1b2c3d4.ngrok.com/echoserver/skebby \
-F 'sender=390000000000' \
-F 'receiver=3933999415252' \
-F 'text=TEST123 Hello World!' \
-F 'encoding=UTF-8' \
-F 'date=2014-01-25' \
-F 'time=12:02:28' \
-F 'timestamp=1390647748' \
-F 'smsType=standard'
```

Sinatra echo server feed back to client the JSON response:

```json
{
  "SMS RECEIVED": {
    "sender": "390000000000",
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
    "receiver": "390000000000",
    "remaining_sms": 145
  }
}

```

In cause of failure sending back the SMS (TX), JSON response show error_message and all info about failure (by example in case you didn't set ENV variables): 

```json
{
  "SMS RECEIVED": {
    "sender": "390000000000",
    "receiver": "3933999415252",
    "text": "TEST123 Ciao Mondo Intero!",
    "encoding": "UTF-8",
    "date": "2014-01-25",
    "time": "12:02:28",
    "timestamp": "1390647748",
    "smsType": "standard"
  },
  "SMS SENT": {
    "status": "failed",
    "error_code": 21,
    "error_message": "Username or password not valid, you cannot use your email or phone number, only username is allowed on gateway",
    "text": "ECHO Ciao Mondo Intero!",
    "receiver": "390000000000"
  }
}

```


## Step 6. End-to-end SMS echo test!

- Keep you mobile phone in your hand 
- send a SMS to you Skebby *application number* (let say the mobile number: "339 99 41 52 52", 
- write your test text message; assuming your *application keyword* is "TEST123", and you want to send  message "Hello World!", so please send the message text:

```
TEST123 Hello World!
```

- in few moments your Sinatra app will receive a HTTP POST request from Skebby server 
(after your Skebby web configuration page, where you set the forward URL as: http: //a1b2c3d4.ngrok.com/echoserver/skebby ).  
- The HTTP request contain in *params* all data of SMS message, transmitted by Skebby server. 
- This echo server log data and forwarded back to your mobile phone number the message:

```
ECHO Hello World!
```


## Notes

### Complex Bidirectional SMS Services

The scope of that simple echo server is just to quickly test and debug Skebby service features (SMS gateways Send APIs and Receive SMS through the HTTP proxy behaviours).

A further step could be to realize ANY sort of *Company Application Server* that elaborate SMS received by *end users*. 

The develop of a complex application is out of scope of this small open-source project; so feel free to contact me for your project as job proposal!


### Skebby Services Survey

* Performances with `send_sms_classic` SMS mode: I enjoyed the very fast and reliable end-to-end delivery time elapseds using this configuration: usually the end-to-end echo back take no more than few seconds. great! :-)
* Performances with `send_sms_basic` SMS: I verified some delayed elapsed with cheapest mode: elapsed times start from half a minute to 5/10 minutes and a bit more sometime. 
* Unfortunately Receive SMS services run only if end user send "Standard SMS". That mean end user can not send SMS to server using [free SMS message mobile apps](http://www.skebby.it/scarica-programma-sms-gratis/) also available by Skebby :-(  
* Website registration/configuration/etc. pages are pretty well done but there are some areas of improvements in organization of "navigation storyboards" (you can find really a lot of info but you lost yourself easely). 
* Last but not least, documentation for developers of some behaviours is not too clear (by example the format of message with KEYWORD (need of a separator) is not correctly explained in Skebby website).

All in all my final vote about Skebby services is positive.


## Release Notes

### v.0.3.2 (29 January 2014)
- Data flow better explained in this README
- To send SMS I substitute the Ruby example code supplied by Skebby website with [Skuby](https://github.com/welaika/skuby) gem.

### v.0.1.1 (25 January 2014)
- First release!


## Licence

Feel free to do what you want with my source code. It's free! 
BTW, a mention/feedback to me will be very welcome and STAR the project if you feel it useful!


## Special Thanks

- [Alan Shreve](https://github.com/inconshreveable/ngrok), for his great tunneling, reverse proxy open source project [ngrok](https://ngrok.com/)
- [Tommaso Visconti](https://github.com/tommyblue), for his code for send SMS Ruby code [code](http://www.skebby.it/business/index/code-examples/?example=sendRuby) and generally for his many useful posts about Ruby (on Rails), by example: [this one](http://www.tommyblue.it/2012/01/18/notifiche-sms-gratis-con-nagiosicinga-e-skebby).
- [Paolo Montrasio](https://github.com/pmontrasio), that long time ago suggested to me Skebby features.
- [Fabrizio Monti](https://github.com/welaika), for his smart Ruby gem [Skuby](https://github.com/welaika/skuby)


# Contacts

### Skebby people
To create your account for Skebby services, getting API credentials (username, password) and purchase your SMS credit, please visit: [www.skebby.com](http://www.skebby.com).

### About me
I develop using Ruby, when possible and also when is not possible. I'm also a music composer and a mountaineer. Home page: [http://about.me/solyaris](http://about.me/solyaris)

Please feel free to write an e-mail with your comments and jobs proposals are more than welcome.
E-mail: [giorgio.robino@gmail.com](mailto:giorgio.robino@gmail.com)
