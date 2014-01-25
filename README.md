Skebby echo server
==================

Simple Ruby Sinatra HTTP/SMS echo server for [www.skebby.com](http://www.skebby.com) RX/TX SMS services.


[www.skebby.com](http://www.skebby.com) is an Italian SMS gateway service provider with cheap prices and high quality services! 

<p align="center">
  <img src="http://static.skebby.it/s/i/sms-gratis-business.png" alt="skebby logo">
</p>


This project is Yet Another Simple [Sinatra](http://www.sinatrarb.com/) Application acting as "SMS echo server":

- An *end user* send a standard SMS to a *customer application* that supply a Skebby *receive SMS* service (each "receive sms" service can be identified by a mobile phone number + application *keyword*)

- Skebby server forward that SMS through an HTTP POST/GET to a *customer application server* to be configured in Skebby through an initial web configuration.

- this project realize the *Company Application Server*, logging the received SMS data and 

- sending back to mobile phone sender a SMS message with pretty the same content (ECHO mode).


```
 An end user, with a mobile phone

        ^               | 1. send SMS message with text: "TEST69 Hello World!"
        |               | 
        |               |
        |               v
   .-----------------------------------------.
   |                  SKEBBY                 |
   |   SMS TX GATEWAY   -   SMS RX GATEWAY   |
   |                                         |
   .-----------------------------------------.
        ^               |
        |               | 2. HTTP POST http://a1b2c3d4.ngrok.com/skebby/receivesms
        |               v
        |  .----------------------------.
        |  | Company Application Server | 
        |  |   == this echo server      | 
        |  |                            |
        |  .------------+-----+---------.
        |               |     |
        |               |     +-----------> 3. log/store (on a database) received SMS data
        |               |
        +---------------+
        4. echo back the SMS with text: "TEST69 Hello World!" 

```


BTW, The simple scope of project is just to quickly test and debug Skebby service features! 


## Step 1. Install stuff

- Install source code: 

```
$ git clone https://github.com/solyaris/skebby_echo_server.git
```

- Verify you already have alle required gems: 

```
$ cd skebby_echo_server, bundle install
```


## Step 2. run sinatra server (in your localhost)


### Run sinatra server in developement

To automatically reload rack development server I enjoyed [`shotgun`](https://github.com/rtomayko/shotgun)

run shotgun, at port 9393:

```
shotgun config.ru -o 127.0.0.1 -p 9393 -E development
```


### run server in "production mode"

specifying production environment, localhost and port 9393:

```
ruby app.rb -o 127.0.0.1 -p 9393 -e production
```

## Step 3. publish your local dev server!

I successfully used [ngrok](https://ngrok.com/) tunneling, reverse proxy:
please visit ngrock home page, download sw and run in a new terminal:

```
cd /your/path2/ngrok; ./ngrok 9393
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


## Step 4. Locally test your Skebby echo server!

Now you can test locally calling a the service endpoint to receive SMSs.

Just oo verify your echo server is up and running, open a terminal and enjoy:

```
curl -i -X GET  http://a1b2c3d4.ngrok.com
```

To simulate an invocation by Skebby server after the rx of a SMS:
```
curl -i -X POST  http://a1b2c3d4.ngrok.com/skebby/receivesms -F text='orsù, questa città è bella!'
```

## Step 5. End-to-end test your echo server!

- Keep you mobile phone in your hand 
- send a SMS to you Skebby *application number* (let say the mobile number: "339 99 41 52 52", 
- write your test text message; assuming your *application keyword* is "TEST69", and you want to send  message "Hello World!", so please send the message text:

```
TEST69 Hello World!
```

- in few moments your Sinatra app will receive a HTTP POST request from Skebby server 
(after your Skebby web configuration page, where you set the forward URL as: http://a1b2c3d4.ngrok.com/skebby/receivesms );  
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


## Release Notes


### v.0.1.0
- First release: 25 January 2014


## To do

- Send back message to mobile phone end user SMS sender (TX SMS via SMS gateway). 


## Licence

Feel free to do what you want with that source code. It's free! 
BTW, a mention/feedback to me will be very welcome and star the project if you feel it useful!


## Special Thanks
- [Alan Shreve](https://github.com/inconshreveable/ngrok), for his great tunneling, reverse proxy open source project [ngrok](https://ngrok.com/)


# Contacts

### Skebby
To register for your Skebby service, getting API credentials, please visit: [www.skebby.com](http://www.skebby.com).

### About me
I develop mainly using Ruby (on Rails) for server side programming. I'm also a music composer [http://about.me/solyaris](http://about.me/solyaris), and a mountaineer.

Please feel free to write an e-mail with your comments and jobs proposals are more than welcome: 
e-mail: [giorgio.robino@gmail.com](mailto:giorgio.robino@gmail.com)
