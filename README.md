Skebby echo server
==================

Simple Ruby Sinatra HTTP echo server for www.skebby.com RX/TX SMS services.



[skebby](http://www.skebby.com) is an Italian SMS gateway service provider with cheap prices and high quality service! 

<p align="center">
  <img src="http://static.skebby.it/s/i/sms-gratis-business.png" alt="skebby logo">
</p>


this project is a very simple Sinatra echo server:

1. An end user send a standard SMS to a "customer application" that supply a Skebby "receive sms" service (each "receive sms" service can be identified by a mobile phone number + application "keyword")

2. Skebby server forward that SMS through an HTTP POST/GET to a "customer application server" to be configured in Skebby through a preventive web configuration.

3. this project realize the "customer application server", logging the received SMS data and 

4. sending back to mobile phone senderthe same SMS message (echo).


The main scope of project is just to quickly test and debug Skebby service features! 



## Release Notes


### v.0.0.1
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
I develop mainly using Ruby (on Rails) when I do server side programming. I'm also a mountaineer (loving white mountains) and a musician/composer: I realize sort of ambient music you can listen and download at [http://solyaris.altervista.org](http://solyaris.altervista.org).

Please let me know, criticize, contribute with ideas or code, feel free to write an e-mail with your thoughts! and of you like the project, a github STAR is always welcome :-) To get in touch about this github project and JOBs, e-mail me: [giorgio.robino@gmail.com](mailto:giorgio.robino@gmail.com)
