#!/bin/env ruby
# encoding: utf-8

#
# class SkebbyGatewaySendSMS
#
# code here below is mentioned as "example" in Skebby website API doc page:
# http://www.skebby.it/business/index/code-examples/?example=sendRuby
#
# Tommaso Visconti, as he state here:
# http://www.tommyblue.it/2012/01/18/notifiche-sms-gratis-con-nagiosicinga-e-skebby
# 
# is the person developed originally the code that
# released the code under GNU General Public License.
#
# BTW, I modified just a bit the code (avoiding direct stdout puts).

# I want to thank you Tommaso (tommyblue) for his work!
# =====================================================
#

require 'net/http'
require 'uri'
require 'cgi'

class SkebbyGatewaySendSMS
  
	def initialize(username = '', password = '')
		@url = 'http://gateway.skebby.it/api/send/smseasy/advanced/http.php'

		@parameters = {
			'username'		=> username,
			'password'		=> password,
		}
	end

	def sendSMS(method, text, recipients, options = {})
	  unless recipients.kind_of?(Array)
	    raise("recipients must be an array")
	  end
	
	  @parameters['method'] = method
	  @parameters['text'] = text

	  
	  @parameters["recipients[]"] = recipients
  
    unless options[:senderNumber].nil?
     @parameters['sender_number'] = options[:senderNumber]
    end

    unless options[:senderString].nil?
     @parameters['sender_string'] = options[:senderString]
    end

    unless options[:charset].nil?
     @parameters['charset'] = options[:charset]
    end
        
    #@parameters.each {|key, value| puts "#{key} is #{value}" }    
        
		@response = Net::HTTP.post_form(URI(@url), @parameters)
		if @response.message == "OK"
			true
		else
			false
		end
		
	end
	
	def getCredit()
	  
    @parameters['method']	= 'get_credit'
    
		@response = Net::HTTP.post_form(URI(@url), @parameters)
		if @response.message == "OK"
			true
		else
			false
		end
	end
	
	def getResponse
		result = {}
		@response.body.split('&').each do |res|
			if res != ''
				temp = res.split('=')
				if temp.size > 1
					result[temp[0]] = temp[1]
				end
			end
		end
		return result
	end

	def printResponse
		result = self.getResponse
		if result.has_key?('status') and result['status'] == 'success'
			puts "Success, response contains:"
			result.each do |key,value|
				puts "\t#{key} => #{CGI::unescape(value)}"
			end
			true
		else
			# ------------------------------------------------------------------
			# Controlla la documentazione completa all'indirizzo http:#www.skebby.it/business/index/send-docs/ 
			# ------------------------------------------------------------------
			# Per i possibili errori si veda http:#www.skebby.it/business/index/send-docs/#errorCodesSection
			# ATTENZIONE: in caso di errore Non si deve riprovare l'invio, trattandosi di errori bloccanti
			# ------------------------------------------------------------------		
			puts "Error, trace is:"
			result.each do |key,value|
				puts "\t#{key} => #{CGI::unescape(value)}"
			end
			false
		end
	end

end
