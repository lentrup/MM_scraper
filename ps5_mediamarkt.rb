require 'puppeteer'
require 'dotenv/load'
require 'pry-byebug'
require 'pry-byebug'
require 'telegram/bot'
require 'rest-client'


class MediaMarktSraper
	def initialize
		Puppeteer.launch(headless: false, args: ['--window-size=2560,1600','--no-sandbox']) do |browser|
		  @page = browser.new_page
		  @page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
		  login
		  start_cycle
		end
	end

	def login
		@page.goto("https://www.mediamarkt.de/de/myaccount/auth/login", wait_until: 'domcontentloaded')
		@page.wait_for_selector("button[id='privacy-layer-accept-all-button']")
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
		send_message("#{Time.new.to_s} | I am still online and runnning")
		add_to_cart_btn = product_available?
		if product_available?
			send_message("#{Time.new.to_s} | PS5 AVAILABLE!!!!!!!!") 
			go_to_checkout
		else
			p add_to_cart_btn
			start_cycle
		end
	end

	def product_available?
		wait_longer
		# @page.goto("https://www.mediamarkt.de/de/product/_sony-playstation%C2%AE5-digital-edition-2661939.html", wait_until: 'domcontentloaded')
		@page.goto("https://www.mediamarkt.de/de/product/_isy-ita-751-2-2668534.html", wait_until: 'domcontentloaded')
		wait
		add_to_cart_btn = @page.query_selector("button[id='pdp-add-to-cart-button']")
		@page.evaluate(String.new("document.querySelector(`button[id='pdp-add-to-cart-button']`).click()"))
		add_to_cart_btn
	end

	def go_to_checkout
		wait
		@page.goto("https://www.mediamarkt.de/checkout", wait_until: 'domcontentloaded')
		wait
		go_to_checkout_btn = @page.query_selector(".bGZfev")
		wait
		go_to_checkout_btn.click
		wait
		purchase_btn = @page.query_selector(".StepWrapperstyled__StyledSummary-sc-1mi7ueb-4 .bGZfev")
		# wait
		# purchase_btn.click
		binding.pry
	end

	def wait
		sleep(rand(1..2))
	end

	def wait_medium
		sleep(rand(5..8))
	end

	def wait_longer
		# still need to tweak this one to lower it so that it does not trigger the captcha
		sleep(rand(20..30))
	end

	def send_message(message)
		RestClient.get("https://api.telegram.org/bot#{ENV["TELEGRAM_TOKEN"]}/sendMessage?chat_id=#{ENV["TELEGRAM_CHAT_ID"]}&text=#{message}&parse_mode=markdown")
	end
end

MediaMarktSraper.new

