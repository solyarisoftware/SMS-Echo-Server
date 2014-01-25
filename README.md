Skebby echo server
==================

Simple Ruby Sinatra HTTP/SMS echo server for [www.skebby.com](http://www.skebby.com) RX/TX SMS services.


[www.skebby.com](http://www.skebby.com) is an Italian SMS gateway service provider with cheap prices and high quality services! 

<p align="center">
  <img src="http://static.skebby.it/s/i/sms-gratis-business.png" alt="skebby logo">
</p>


This project is Yet Another Simple [Sinatra](http://www.sinatrarb.com/) Application acting as "SMS echo server":

1. An *end user send* a standard SMS to a *customer application* that supply a Skebby *receive SMS* service (each "receive sms" service can be identified by a mobile phone number + application *keyword*)

2. Skebby server forward that SMS through an HTTP POST/GET to a *customer application server* to be configured in Skebby through a preventive web configuration.

3. this project realize the *customer application server*, logging the received SMS data and 

4. sending back to mobile phone sender the same SMS message (echo).


The main scope of project is just to quickly test and debug Skebby service features! 


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


### run server in production

specifying production environment, localhost and port 9393:

```
ruby app.rb -o 127.0.0.1 -p 9393 -e production
```

## Step 3. publish your local server on internet!

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
curl -i -X GET  http://localhost/
```

To simulate an invocation by Skebby server after the rx of a SMS:
```
curl -i -X POST  http://6f7fef5c.ngrok.com/skebby/receivesms -F text='orsù, questa città è bella!'
```

## Step 5. End-to-end test your echo server!

- Keep you mobile phone in your hand 
- send a SMS to you Skebby *application number* (let say the mobile number: "339 99 41 52 52", 
- write your test text message; assuming your *application keyword* is "TEST69", and you want to send  message "Hello World!", so please digit text:

	TEST69 Hello World!

- in few moments your Sinatra app will receive a HTTP POST (as you configured in your Skebby web configuration page), and 
- a SMS message with text:
	
	ECHO Hello World!

will be forwarded back to your mobile phone number! 


## Release Notes


### v.0.1.0
- First release: 25 January 2014


## To do

- Send back message to mobile phone end user SMS sender (TX SMS via SMS gateway). 


## Licence

Feel free to do what you want with that source code. It's free! BTW, a mention/feedback to me will be welcome!


## Special Thanks
- [Alan Shreve](https://github.com/inconshreveable/ngrok), for his great tunneling, reverse proxy open source project [ngrok](https://ngrok.com/)


# Contacts

### API Credentials request
To get Skebby API credentials, please visit : [skebby website](http://www.skebby.com)

### About me
I develop mainly using Ruby (on Rails) when I do server side programming. I'm also a mountaineer (loving white mountains) and a musician/composer: I realize sort of ambient music you can listen and download at [http://about.me/solyaris](http://about.me/solyaris).

Please let me know, criticize, contribute with ideas or code, feel free to write an e-mail with your thoughts! and of you like the project, a github STAR is always welcome :-) To get in touch about this github project and JOBs, e-mail me: [giorgio.robino@gmail.com](mailto:giorgio.robino@gmail.com)
