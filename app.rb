require 'sinatra'
require 'json'
require 'skuby'

ABOUT = "SMS Echo Server (using Skebby). \
home page: https://github.com/solyaris/SMS-Echo-Server \
e-mail: giorgio.robino@gmail.com"

configure do

  enable :logging

  # get username and password from Environment variables
  username = ENV['SKEBBY_USERNAME']
  password = ENV['SKEBBY_PASSWORD'] 

  # Initialize Skuby
  Skuby.setup do |config|
    config.method = 'send_sms_classic'
    config.username = username
    config.password = password
    config.sender_string = 'ECHO-SERVER'
    #config.sender_number = 'xxxxxxxxxxxx'
    config.charset = 'UTF-8'
  end

  # in case you are testing with scenario: *SHARED NUMBER + KEYWORD*
  enable :contain_keyword
  set echo_keyword: "ECHO"
end

before do
  content_type :json 
  logger.level = Logger::INFO
  # logger.level = 0 # set log level to debug
  # logger.datetime_format = "%Y/%m/%d @ %H:%M:%S "
end  


helpers do

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

  #
  # echo_text
  #
  # If message is in format: <KEYWORD><separator_char><text> 
  # return a new message that substitute KEYWORD in the original message
  # with <ECHO> <text>
  #
  # By example with a message containing a <KEYWORD>:
  #
  #   echo_message "TEST123 Hello World! I'm poor!" 
  #   # => "ECHO Hello World! I'm poor!"
  #
  # By example with a message without keyword:
  #
  #   echo_message "Hello World! I'm rich!" 
  #   # => "ECHO Hello World! I'm rich!"
  #
  def echo_text (text)
    if settings.contain_keyword
      # substitute <KEYWORD> with <ECHO>
      separator_index = text.index(/\s/)
      lenght = text.length
      cut_text = text[separator_index+1, lenght-separator_index]

      "#{settings.echo_keyword} #{cut_text}"
     else
      "#{settings.echo_keyword} #{text}"
     end  
  end

  def echo_sms (request, params)
    # debug info
    logger.debug "request header:"
    logger.debug request.inspect
    logger.debug "request body:"
    logger.debug request.body.read.inspect

    # log received SMS message
    sms_params = "SMS RECEIVED: #{params.to_s}"
    logger.info sms_params  

    # Send back to the sender an SMS echo message!
    text = echo_text params[:text]
    receiver = params[:sender]

    # Send SMS via Skuby
    sms = Skuby::Gateway.send_sms text, receiver

    if sms.success? 
      response = { status: sms.status, 
                   text: text, 
                   receiver: receiver, 
                   remaining_sms: sms.remaining_sms
                 }
      response.merge! sms_id: sms.sms_id if sms.sms_id?

      logger.info "SMS SENT: #{response.to_s}"

    else
      response = { status: sms.status, 
                   error_code: sms.error_code, 
                   error_message: sms.error_message, 
                   text: text, 
                   receiver: receiver
                 }
      response.merge! sms_id: sms.sms_id if sms.sms_id?

      logger.error "SMS SENT: #{response.to_s}"  
    end
  
    # JSON response (for debug purposes)
    to_json ( { "SMS RECEIVED".to_sym => params, "SMS SENT".to_sym => response } ) 
  end
end


get "/" do
  to_json ( { :message => ABOUT } )
end

get "/echoserver/skebby" do
  to_json ( { :message => 'sorry, to be done, use POST.' } )
end

post "/echoserver/skebby" do
  # received SMS: elaborate ECHO logic
  # send an echo SMS with Skuby::Gateway.send_sms
  echo_sms request, params
end

not_found do
  to_json ( { :message => 'This is nowhere to be found.' } )
end

error do
  to_json ( { :message => 'Sorry there was a nasty error - ' + env['sinatra.error'].name } )
end
