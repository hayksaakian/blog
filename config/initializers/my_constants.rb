module MyConstants
	CREDIT_IMG_SRC = "http://teslamarketing.com/cl/banner/template/credit.gif"
	CONTACT_IMG_SRC = "http://teslamarketing.com/cl/banner/contact.jpg"
	MAIN_LANDING_URL = "http://dealerbus.com/"
	MAIN_FOOTER_IMG_SRC = "http://teslamarketing.com/cl/banner/dealerbus-footer.jpg"
	DOMAIN_NAMES = {"staging" => "hayktest.heroku.com", "development" => "localhost:3000", "production" =>  "hayktest.heroku.com", "test" => "localhost:3000"}
	DOMAIN_NAME = DOMAIN_NAMES[Rails.env]
end