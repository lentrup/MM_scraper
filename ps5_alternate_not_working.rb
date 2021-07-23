require 'puppeteer'
require 'dotenv/load'
require 'pry-byebug'

Puppeteer.launch(headless: false, args: ['--window-size=1280,800','--no-sandbox']) do |browser|
  @page = browser.new_page
  @page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
  @page.goto("https://www.alternate.de/login.xhtml")
  sleep(1)
  cookie_button = @page.query_selector(".cookie-submit-all")
  cookie_button.click

	# LOGGING IN
	def login
		if @page.url.include?("login.xhtml")
			login = @page.query_selector("input[inputmode='email']")
			login.click
			login.type_text(ENV["LOGIN"])
			pw = @page.query_selector("input[type='password']")
			pw.click
			@page.keyboard.type_text(ENV["PASSWORD"])
			login_btn = @page.query_selector("#loginbutton")
			login_btn.click
		end
	end

	login

  # @page.goto("https://www.alternate.de/Sony-Interactive-Entertainment/PlayStation-5-Digital-Edition-Spielkonsole/html/product/1651221?sug=ps5%20digi")
  @page.goto("https://www.alternate.de/Transcend/220S-1-TB-SSD/html/product/1534685")
  login
  @page.wait_for_navigation do
	  add_to_basket_btn = @page.query_selector("a[onclick='global.checkTarpit(this, event)']")
	  add_to_basket_btn.click
  end
  login
	@page.goto("https://www.alternate.de/cart.xhtml")
	login
	@page.wait_for_navigation do
		zur_kasse = @page.query_selector("#tocheckoutform input[name='tocheckoutform:tocheckoutbtn']")
		zur_kasse.click
	end

	
	login


	# @page.wait_for_navigation do
	#   weiter_btn_1 = @page.query_selector("#next-step .btn-primary")
	#   weiter_btn_1.click
	# end


	
	# sleep(rand(2))
	# weiter_btn_2 = @page.query_selector("#next-step .btn-primary")
	# weiter_btn_2.click
	# sleep(rand(2))
	# weiter_btn_3 = @page.query_selector("#next-step .btn-primary")
	# weiter_btn_3.click
	# sleep(rand(2))
	# purchase_btn = @page.query_selector("#complete-purchase-form .btn-primary")





  binding.pry
end