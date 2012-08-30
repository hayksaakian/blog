module MyConstants
	DEFAULT_DEALER_NAME = "Auto-get Dealer Name from CSV File"
	DEFAULT_ZIP = "Auto-get ZIP from CSV File"
	DEFAULT_LOCATION = "Auto-get Location from ZIP"
	DEFAULT_FULL_LOCATION = "Auto-get Full Location from ZIP & Location"

	DEFAULT_DEALER_CONTACT_URL = "https://dealerbus.com/dbcontact.html"
	DEFAULT_DEALER_BANNER_URL = "http://placehold.it/1000x300.png"

	def self.MAKE_GEOCODING_URL(arg)
		require 'open-uri' 
    uri = 'http://maps.googleapis.com/maps/api/geocode/json?address='+arg.to_s+'&sensor=true'
    URI.parse(uri)
  end

	FTP_SERVER = "www.teslamarketing.com"
	FTP_USERNAME = "chobohob"
	FTP_PASS = "t3mpP@ss"

	CREDIT_IMG_SRC = "http://teslamarketing.com/cl/banner/template/credit.gif"
	CONTACT_IMG_SRC = "http://teslamarketing.com/cl/banner/contact.jpg"
	MAIN_LANDING_URL = "http://dealerbus.com/"
	MAIN_FOOTER_IMG_SRC = "http://teslamarketing.com/cl/banner/dealerbus-footer.jpg"
	DOMAIN_NAMES = {
		"staging" => "hayktest.herokuapp.com", 
		"development" => "localhost:5000", 
		"production" =>  "hayktest.herokuapp.com", 
		"test" => "localhost:5000"
	}
	DOMAIN_NAME = DOMAIN_NAMES[Rails.env]
end