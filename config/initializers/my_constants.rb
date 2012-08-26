module MyConstants
	FTP_SERVER = "www.teslamarketing.com"
	FTP_USERNAME = "chobohob"
	FTP_PASS = "t3mpP@ss"
	CREDIT_IMG_SRC = "http://teslamarketing.com/cl/banner/template/credit.gif"
	CONTACT_IMG_SRC = "http://teslamarketing.com/cl/banner/contact.jpg"
	MAIN_LANDING_URL = "http://dealerbus.com/"
	MAIN_FOOTER_IMG_SRC = "http://teslamarketing.com/cl/banner/dealerbus-footer.jpg"
	DOMAIN_NAMES = {"staging" => "hayktest.herokuapp.com", 
		"development" => "localhost:5000", 
		"production" =>  "hayktest.herokuapp.com", 
		"test" => "localhost:5000"}
	DOMAIN_NAME = DOMAIN_NAMES[Rails.env]
end