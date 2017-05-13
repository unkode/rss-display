#!/usr/bin/env ruby
require 'rubygems'
require 'simple-rss'
require 'open-uri'
require 'nokogiri'
require 'date'
require 'asciiart'
require 'terminfo'

## Parameters

$TYPING_RATE_SECONDS=0.06
$DELAY_BETWEEN_FEEDS_MIN=5
$REFRESH_TIME_MIN=45
$REFRESH_FLAG=true

## GLOBAL VARIABLES

$ver = "1.1.0"
$item_struct = Struct.new(:provider, :pubdate, :title, :description)
$item_array = Array.new

## FUNCIONS

class String
	def console_red;          colorize(self, "\e[1m\e[31m");  end
	def console_dark_red;     colorize(self, "\e[31m");       end
	def console_green;        colorize(self, "\e[1m\e[32m");  end
	def console_dark_green;   colorize(self, "\e[32m");       end
	def console_yellow;       colorize(self, "\e[1m\e[33m");  end
	def console_dark_yellow;  colorize(self, "\e[33m");       end
	def console_blue;         colorize(self, "\e[1m\e[34m");  end
	def console_dark_blue;    colorize(self, "\e[34m");       end
	def console_purple;       colorize(self, "\e[1m\e[35m");  end
	def console_dark_purple;   colorize(self, "\e[35m");  end

	def console_def;          colorize(self, "\e[1m");  end
	def console_bold;         colorize(self, "\e[1m");  end
	def console_blink;        colorize(self, "\e[5m");  end

	def html2text;		  html2text_conv(self); end

	def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end    	
    
	def html2text_conv(text)
		text = Nokogiri::HTML(text).text
	end
    
end

def type(string, color)

        string.each_char do |c|
		
		case color
		when "red"
                	print c.console_red
		when "darkred"
                	print c.console_dark_red
		when "green"
			print c.console_green
		when "darkblue"
			print c.console_dark_blue
		when "blue"
			print c.console_blue
		when "yellow"
			print c.console_yellow
                when "purple"
                        print c.console_purple
                when "darkpurple"
                        print c.console_dark_purple
		else
			print c
		end
		sleep $TYPING_RATE_SECONDS
        end

end

def refresh_timer(minutes)

	sleep minutes * 60
	$REFRESH_FLAG = true

end

def refresh_rss_feeds()

	type("Refreshing RSS providers content...\r\n", "blue")

	$item_array.clear
	items_nbr = 0

	File.open(File.expand_path("~/display/rss-feeds/rss.feeds")).each do |line|
		
		items_nbr = 0
		
		line.chop!
		
		if line.length == 0 or line == nil or line =~ /^#/
			next
		end


		puts "Fetching: #{line}".console_green
begin		

		rss = SimpleRSS.parse(open(line).read)

rescue Exception => e
        puts "ERROR Fetching: #{e.message}".console_dark_red
	nextc
end

begin

                # Show channel image if available 
                if (defined?(rss.channel.image)) != nil
                        image_xml = Nokogiri::XML(rss.feed.image)
			image_url = Array.new

                        if image_xml != nil
                                image_url = image_xml.xpath('//url[1]').map(&:content)
                        end

			image_width = TermInfo.screen_size[1]-((TermInfo.screen_size[1]/5)*2)

                        if image_url != nil and (image_url.empty? != true)   
                                a = AsciiArt.new(image_url.first.to_s())
                                print a.to_ascii_art(width: image_width, color: true, invert: true)
                        end
                end

rescue Exception => e
        puts "ERROR Fetching IMAGE: #{e.message}".console_dark_red
	puts "#{e.backtrace}"
        next
end

	

		for news in rss.items

			if news.pubDate != nil
				if news.pubDate < (Time.now - (60*60*24*3))
					next
				end
			end

			#ATOM feed
                        if news.dc_date != nil
                                if news.dc_date < (Time.now - (60*60*24*3))
                                        next
                                end

				#Handle NIST fucking monster truck load of items
				if news.title =~ /cve-/i
	                                if news.dc_date < (Time.now - (60*60*8))
        	                                next
                	                end
				end
				#news.pubDate = news.dc_date
                        end


			items_nbr += 1
			item = $item_struct.new

begin			
			item.provider = rss.channel.title.to_s().html2text.gsub(/<\/?[^>]*>/, "")
			item.pubdate = news.pubDate.to_s().html2text.gsub(/<\/?[^>]*>/, "")
			item.title = news.title.to_s().html2text.gsub(/<\/?[^>]*>/, "")
			item.description = news.description.to_s().html2text.gsub(/<\/?[^>]*>/, "")
			
			$item_array << item
rescue Exception => e
        puts "ERROR Fetching (gsub): #{e.message}".console_dark_red
        next
end
			
		end


		feed = nil
		puts "Found #{items_nbr} items.".console_dark_green

	end
		
	$item_array.shuffle!
	
	type("Found #{$item_array.length} news items.\r\n", "red")

	$REFRESH_FLAG = false
end

def check_if_refresh()
	if $REFRESH_FLAG == true

		refresh_rss_feeds()
		
		while $item_array.count <= 0
			puts
			puts "Network error. Unable to fetch RSS feeds.".console_dark_red
			puts "Retry in 10 seconds".console_dark_red
			puts
			sleep 10
			refresh_rss_feeds()
		end

		timer_thread = Thread.new{
                refresh_timer($REFRESH_TIME_MIN)
                }

		puts ""
		type("Lastest news...\r\n", "blue")
		puts ""
	end
end



## MAIN CODE

  warn_level = $VERBOSE
  $VERBOSE = nil
  $VERBOSE = warn_level

type("\r\nTypewriter RSS Reader\r\nVer.:#{$ver}\r\n\r\n", "yellow")


check_if_refresh()

while(1)
	for item in $item_array
	
		#.force_encoding(Encoding::UTF_8)
	
		type(item.pubdate + "\r\n".force_encoding(Encoding::UTF_8),"darkpurple")
		type(item.provider + "\r\n".force_encoding(Encoding::UTF_8),"purple")
		type(item.title + "\r\n".force_encoding(Encoding::UTF_8),"yellow")
		type(item.description + "\r\n".force_encoding(Encoding::UTF_8),"green")
		
		puts ""
		sleep $DELAY_BETWEEN_FEEDS_MIN
		
		check_if_refresh()
	end
end

