require 'sinatra'
require 'json'

ABOUT = "SKEBBY ECHO SERVER by giorgio.robino@gmail.com, \
home page: https://github.com/solyaris/skebby_echo_server"

mime_type :json, "application/json"

before do
  content_type :json 

  # set log level to debug
  #logger.level = 0
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

end


#-------------------------------------------------

get "/" do
  to_json ( { :message => ABOUT } )
end


post "/skebby/receivesms" do

  # debug info
  logger.debug "request header:"
  logger.debug request.inspect
  logger.debug "request body:"
  logger.debug request.body.read.inspect

  # log received SMS message
  sms_params = "SMS RECEIVED: #{params.to_s}"

  logger.info sms_params  

  # sender      Numero del mittente dell'SMS in forma internazionale senza + o 00, ad esempio: 393334455666
  # receiver    Il numero su cui e' arrivato l'SMS in forma internazionale senza + o 00, ad esempio: 393334455666
  # text        Testo dell'SMS
  # encoding    Il set di caratteri usati per il testo (ISO-8859-1)
  # date        La data di arrivo dell'SMS
  # time        L'orario di arrivo dell'SMS
  # timestamp   Il timestamp di arrivo dell'SMS per comodita' del programmatore passiamo tre formati differenti di data / ora
  # smsType     Il tipo di SMS ricevuto (standard o skebby)  

=begin
  logger.info params[:sender]
  logger.info params[:receiver]
  logger.info params[:text]
  logger.info params[:encoding]
  logger.info params[:date]
  logger.info params[:time]
  logger.info params[:timestamp]
  logger.info params[:smsType]
=end

  to_json ( { "SMS RECEIVED".to_sym => params } )
end


not_found do
  to_json ( { :message => 'This is nowhere to be found.' } )
end

error do
  to_json ( { :message => 'Sorry there was a nasty error - ' + env['sinatra.error'].name } )
end