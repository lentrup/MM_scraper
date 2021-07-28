require 'puppeteer'
require 'dotenv/load'
require 'pry-byebug'
require 'pry-byebug'
require 'telegram/bot'
require 'rest-client'
require 'cgi'
require 'time'

class MediaMarktSraper
	def initialize
		Puppeteer.launch(headless: true, args: ['--window-size=1280,800','--no-sandbox']) do |browser|
		  @browser = browser
		  set_page
		  @page_links =[
		  	"https://www.mediamarkt.de/de/product/_sony-playstation%C2%AE5-digital-edition-2661939.html",
		  	"https://www.mediamarkt.de/de/product/_sony-ps5-digital-ps-plus-90-tage-mitgliedschaft-2739309.html",
		  	"https://www.mediamarkt.de/de/product/_sony-playstation%C2%AE5-digital-edition-dualsense%E2%84%A2-2715825.html"
		  ]
		  @next_link_index = 0
		  login
		  start_cycle
		end
	end

	def login
		@page = @browser.new_page
		@page.goto("https://www.mediamarkt.de/de/myaccount/auth/login", wait_until: 'networkidle2')
		wait_medium
		# @page.wait_for_selector("button[id='privacy-layer-accept-all-button']", timeout: 5000)
		@page.screenshot(path: "t.png")
		accept_cookies = @page.query_selector("button[id='privacy-layer-accept-all-button']")
		wait
		accept_cookies.click
		wait
		login = @page.query_selector("input[name='email__input']")
		login.click
		wait
		login.type_text(ENV["LOGIN"])
		pw = @page.query_selector("input[name='password__input']")
		wait
		pw.click
		@page.keyboard.type_text(ENV["PASSWORD"])
		wait
		login_btn = @page.query_selector("button[id='mms-login-form__login-button']")
		login_btn.click
		wait
	end

	def start_cycle
		send_message("Bot is still online") if Time.now.strftime("%H:%M") == "19:00"
		# send_message("#{Time.new.to_s} | I am still online and runnning")
		add_to_cart_btn = product_available?
		if add_to_cart_btn
			send_message("#{Time.new.to_s} | PS5 AVAILABLE!!!!!!!!") 
			go_to_checkout
		else
			p add_to_cart_btn
			start_cycle
		end
	end

	def product_available?
		wait_longer
		set_page
		@next_link_index = 0 if @next_link_index == 3
		puts "checking if #{@page_links[@next_link_index]} is available.."
		@page.goto(@page_links[@next_link_index], wait_until: 'networkidle2')
		# @page.goto("https://www.mediamarkt.de/de/product/_isy-ita-751-2-2668534.html", wait_until: 'networkidle2')
		@next_link_index += 1 
		begin
			@page.wait_for_selector("button[id='pdp-add-to-cart-button']", timeout: 5000 )
			add_to_cart_btn = @page.query_selector("button[id='pdp-add-to-cart-button']")
		rescue StandardError => e
			p e
			add_to_cart_btn = nil
		end

		@page.evaluate("document.querySelector(`button[id='pdp-add-to-cart-button']`).click()") if add_to_cart_btn
		@page.close
		add_to_cart_btn
	end

	def go_to_checkout
		set_page
		wait
		puts "going to checkout"
		@page.goto("https://www.mediamarkt.de/checkout/payment", wait_until: 'networkidle2')
		wait
		# selecting the vorkasse option
		@page.wait_for_selector(".dttyiN .bGZfev")

		@page.evaluate("() => { Array.prototype.slice.call(document.querySelectorAll('div')).filter(function(el){return el.textContent==='Vorkasse'})[0].click()}")
		wait
		continue_to_summary_btn = @page.evaluate("() => { document.querySelector('.dttyiN .bGZfev').click()}")
		wait
		@page.wait_for_selector(".StepWrapperstyled__StyledSummary-sc-1mi7ueb-4 .bGZfev")
		purchase_btn = @page.query_selector(".StepWrapperstyled__StyledSummary-sc-1mi7ueb-4 .bGZfev")
		wait
		purchase_btn.click
		# binding.pry
	end

	def wait
		puts "waiting.."
		sleep(rand(1..2))
	end

	def wait_medium
		puts "waiting medium.."
		sleep(rand(5..8))
	end

	def wait_longer
		puts "waiting longer.."
		# still need to tweak this one to lower it so that it does not trigger the captcha
		sleep(rand(5..10))
	end

	def send_message(message)
		RestClient.get("https://api.telegram.org/bot#{ENV["TELEGRAM_TOKEN"]}/sendMessage?chat_id=#{ENV["TELEGRAM_CHAT_ID"]}&text=#{message}&parse_mode=markdown")
	end

	def set_page
		@page = @browser.new_page
		@page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
	end

end


begin
	MediaMarktSraper.new
rescue StandardError => e
	puts e.message
	puts e.backtrace
	RestClient.get("https://api.telegram.org/bot#{ENV["TELEGRAM_TOKEN"]}/sendMessage?chat_id=#{ENV["TELEGRAM_CHAT_ID"]}&text=#{CGI.escape e.full_message}")
end



