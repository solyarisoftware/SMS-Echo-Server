require 'sinatra'
require 'json'

require_relative 'send_sms'


ABOUT = "SMS Echo Server (using Skebby) \
home page: https://github.com/solyaris/SMS-Echo-Server \
e-mail: giorgio.robino@gmail.com"


# set log level to debug
#logger.level = 0

# get username and password from Environment variables or as command line options
# usage example:
# ruby app.rb -o 127.0.0.1 -p 9393 -e production <your_skebby_username> <your_skebby_password>
username = ENV['SKEBBY_USERNAME'] || ARGV[0]
password = ENV['SKEBBY_PASSWORD'] || ARGV[1]
  
if username.nil? || password.nil?
  STDERR.puts "environment variables not set !?"
  exit
else
  puts "username: #{username}, password: #{password}"  
end  




mime_type :json, "application/json"

before do
  content_type :json 

  #
  # Initialize Skebby SMS Gateway
  #
  @gw = SkebbyGatewaySendSMS.new(username, password)
end  


helpers do

  #
  # supposing message is in format: <keyword><separator_char><text> 
  # return a new message that substitute KEYWORD in the original message
  # with ECHO KEYWORD <echo_keyword> <text>
  #
  # example:
  #   echo_message "TEST123 Hello World!" # => "ECHO Hello World!"
  #
  def echo_message (original_message, echo_keyword="ECHO")
    separator_index = original_message.index(/\s/)
    lenght = original_message.length
    text = original_message[separator_index+1, lenght-separator_index]

    "#{echo_keyword} #{text}"
  end

  def to_json( dataset, pretty_generate=true )
    if !dataset #.empty? 
      return no_data!
    end  

    if pretty_generate
      JSON.pretty_generate(JSON.parse(dataset.to_json)) + "\n"  
    else
      dataset.to_json
    end
  end

  def no_data!
    status 204
    #to_json ({ :message => "no data" })
  end

end


get "/" do
  to_json ( { :message => ABOUT } )
end


get "/echoserver/skebby" do
  to_json ( { :message => 'sorry, to be done, use POST.' } )
end

post "/echoserver/skebby" do

  # debug info
  logger.debug "request header:"
  logger.debug request.inspect
  logger.debug "request body:"
  logger.debug request.body.read.inspect

  # log received SMS message
  sms_params = "SMS RECEIVED: #{params.to_s}"

  logger.info sms_params  

  #
  # From Skebby website:
  #
  # sender      Numero del mittente dell'SMS in forma internazionale senza + o 00, ad esempio: 393334455666
  # receiver    Il numero su cui e' arrivato l'SMS in forma internazionale senza + o 00, ad esempio: 393334455666
  # text        Testo dell'SMS
  # encoding    Il set di caratteri usati per il testo (ISO-8859-1)
  # date        La data di arrivo dell'SMS
  # time        L'orario di arrivo dell'SMS
  # timestamp   Il timestamp di arrivo dell'SMS per comodita' del programmatore passiamo tre formati differenti di data / ora
  # smsType     Il tipo di SMS ricevuto (standard o skebby)  

  # logger.info params[:sender]
  # logger.info params[:receiver]
  # logger.info params[:text]
  # logger.info params[:encoding]
  # logger.info params[:date]
  # logger.info params[:time]
  # logger.info params[:timestamp]
  # logger.info params[:smsType]

  #
  # Send back to the sender an SMS echo message!
  # 
  message = echo_message params[:text]
  recipient = [ params[:sender] ]

  options = { charset: 'UTF-8', senderString: 'ECHO-SERVER' }
  smstype = 'send_sms_classic' # 'send_sms_basic'


  #
  # call Skebby Gateway Send SMS API
  # 
  result = @gw.sendSMS(smstype, message, recipient, options)

  if result
    @gw.printResponse
  else
    puts "Error in the HTTP request"
  end

  to_json ( { "SMS RECEIVED".to_sym => params } ) # , "SMS SENT".to_sym => params
end


not_found do
  to_json ( { :message => 'This is nowhere to be found.' } )
end

error do
  to_json ( { :message => 'Sorry there was a nasty error - ' + env['sinatra.error'].name } )
end
