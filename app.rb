require 'sinatra'
require 'json'
require 'skuby'

ABOUT = "SMS Echo Server (using Skebby) \
home page: https://github.com/solyaris/SMS-Echo-Server \
e-mail: giorgio.robino@gmail.com"


# set log level to debug
# logger.level = 0

# get username and password from Environment variables or as command line options
# usage example:
# ruby app.rb -o 127.0.0.1 -p 9393 -e production <your_skebby_username> <your_skebby_password>
username = ENV['SKEBBY_USERNAME'] || ARGV[0]
password = ENV['SKEBBY_PASSWORD'] || ARGV[1]

mime_type :json, "application/json"

before do
  content_type :json 

  #
  # Initialize Skuby
  #
  Skuby.setup do |config|
    config.method = 'send_sms_classic'
    config.username = username
    config.password = password
    config.sender_string = 'ECHO-SERVER'
    #config.sender_number = 'xxxxxxxxxxxx'
    config.charset = 'UTF-8'
  end
end  


helpers do

  #
  # echo_message
  #
  # If message is in format: <KEYWORD><separator_char><text> 
  # return a new message that substitute KEYWORD in the original message
  # with <ECHO> <text>
  #
  # By example with a message containing a <KEYWORD>:
  #
  #   echo_message "TEST123 Hello World!", :contain_keyword # => "ECHO Hello World!"
  #
  def echo_message (original_message, mode, echo_keyword="ECHO")
    if mode == :contain_keyword

      separator_index = original_message.index(/\s/)
      lenght = original_message.length
      text = original_message[separator_index+1, lenght-separator_index]

      "#{echo_keyword} #{text}"
     else
      "#{echo_keyword} #{original_message}"
     end  
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

  # Send back to the sender an SMS echo message!
  text = echo_message params[:text], :contain_keyword
  receiver = params[:sender]

  # Send SMS via Skuby
  sms = Skuby::Gateway.send_sms text, receiver

  # prepare log message text
  response_log = "SMS SENT: #{response.to_s}"

  if sms.success? 
    response = { status: sms.status, 
                 text: text, 
                 receiver: receiver, 
                 remaining_sms: sms.remaining_sms
               }
    response.merge! sms_id: sms.sms_id if sms.sms_id?

    logger.info response 

  else
    response = { status: sms.status, 
                 error_code: sms.error_code, 
                 error_message: sms.error_message, 
                 text: text, 
                 receiver: receiver
               }
    response.merge! sms_id: sms.sms_id if sms.sms_id?

    logger.error response_log  
  end
  
  # JSON response (for debug purposes)
  to_json ( { "SMS RECEIVED".to_sym => params, "SMS SENT".to_sym => response } ) 
end

not_found do
  to_json ( { :message => 'This is nowhere to be found.' } )
end

error do
  to_json ( { :message => 'Sorry there was a nasty error - ' + env['sinatra.error'].name } )
end
