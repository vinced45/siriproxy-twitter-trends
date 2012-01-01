require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check Twitter Trends
# Example usage: "Twitter Trends"
#############

class SiriProxy::Plugin::TwitterTrends < SiriProxy::Plugin

	@i = 0 
	#@entry = Array.new
	
	def initialize(config)
    #if you have custom configuration options, process them here!
  end
  
  listen_for /twitter trends/i do |phrase|
	  trend = "today"
	  trends(trend) #in the function, request_completed will be called when the thread is finished
	end
	
	listen_for /twitter stories/i do |phrase|
	  story = "today"
	  stories(story) #in the function, request_completed will be called when the thread is finished
	end
	
	def trends(t)
	  
    say "Checking Twitter trends..."
	  
		doc = Nokogiri::HTML(open("http://twitter.com/#!/i/discover"))
    list = doc.css(".trends .flex-module")
    entry =  doc.css("li a")
    
    if entry.nil?
      say "I'm sorry, I didn't see any Twitter Trends. I failed you..."
	    request_completed
		end
		
		allTrends = ""
		
		entry.each do 
		|article|
		
			title = article.text
      		
      if title.nil?
        title = " "
      end
      	
      allTrends = "" + allTrends + "\n" + title + "" 
      		
    end
    
    say "Here are the trends on Twitter... \n" + allTrends + "", spoken: "Here are the trends from Twitter..."  	
      	
    request_completed
 
	end
	
	def stories(t)
	  
    say "Checking Twitter top stories..."
	  
		doc = Nokogiri::HTML(open("http://twitter.com/#!/i/discover"))
    entry = doc.css(".stream-item")
    
    if entry.nil?
      say "I'm sorry, I didn't see any Twitter Stories. I failed you..."
	    request_completed
		end
		
		entry.each do 
		|article|
		
			title = article.css("h3 a").first.content.strip
      		
      if title.nil?
        title = " "
      end
      	
      img = article.css("div img").first
      	
      if img.nil?
        img_url = "http://farm4.static.flickr.com/3342/3242600194_d01459d6de_o.jpg"
      else
      	img_url = img['src']
      end
      	
      descr1 = article.css("a h4").first.content.strip
      
      descr2 = article.css("p div").first.content.strip
      
      descr = " " + descr1 + "\n" + descr2 + ""
      		
      if descr.nil?
        descr = " "
      end
      
      showArticle(title, img_url, desc)
      		
      if @i == 1
        break
      end
      		
    end 	
      	
    request_completed
 
	end
		
	def showArticle(title1, img, desc)
		
		say "Here is the latest from Twitter...", spoken: "Here is the latest from Twitter. " + title1 + "."
		
		object = SiriAddViews.new
    object.make_root(last_ref_id)
    answer = SiriAnswer.new(title1, [
    SiriAnswerLine.new('logo',img), # this just makes things looks nice, but is obviously specific to my username
    SiriAnswerLine.new(desc)])
    object.views << SiriAnswerSnippet.new([answer])
    send_object object
    	
    #@searched = @searched + 1
    	
    response = ask "Would you like to hear more stories? You can \"Hear more\", go to the \"Next Story\" or \"Cancel\"" #ask the user for something
    
    if(response =~ /hear|here more/i) #process their response
      say "Detail from the story...", spoken: desc
    	response1 = ask "Would you like to hear more stories? You can go to the \"Next Story\" or \"Cancel\""
      #showEntry(@searched)
      if(response1 =~ /next|nick story|door/i)
        say "OK, looking for more stories..."
      	@i = 0
      else
      	say "OK, I'll stop with all the Twitter stories."
      	@i = 1
      	#break
      	#request_completed
      end
    elsif (response =~ /next|nick story|door/i)
      say "OK, looking for more stories..."
      @i = 0
    else
      say "OK, I'll stop with all the Twitter stories."
      @i = 1
      #break
      #request_completed
    end
	
	end
	
end
