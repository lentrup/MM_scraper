require 'puppeteer'
require 'dotenv/load'
require 'pry-byebug'

class MediaMarktSraper
	def initialize
		Puppeteer.launch(headless: false, args: ['--window-size=1280,800']) do |browser|
		  @page = browser.new_page
		  @page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
		  login
		  start_cycle
		end
	end

	def login
		@page.goto("https://www.mediamarkt.de/de/myaccount/auth/login", wait_until: 'domcontentloaded')
		wait
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
		add_to_cart_btn = product_available?
		if add_to_cart_btn
			go_to_checkout
		else
			p add_to_cart_btn
			start_cycle
		end
	end

	def product_available?
		wait_longer
		@page.goto("https://www.mediamarkt.de/de/product/_sony-playstation%C2%AE5-digital-edition-2661939.html", wait_until: 'domcontentloaded')
		# @page.goto("https://www.mediamarkt.de/de/product/_isy-ita-751-2-2668534.html", wait_until: 'domcontentloaded')
		add_to_cart_btn = @page.query_selector("button[id='pdp-add-to-cart-button']")
		wait
		add_to_cart_btn
	end

	def go_to_checkout
		@page.goto("https://www.mediamarkt.de/checkout", wait_until: 'domcontentloaded')
		wait
		go_to_checkout = @page.query_selector(".bGZfev")
		wait
		go_to_checkout.click
		binding.pry
	end

	def wait
		sleep(rand(1..2))
	end

	def wait_longer
		# still need to tweak this one to lower it so that it does not trigger the captcha
		sleep(rand(20..30))
	end

end

MediaMarktSraper.new
