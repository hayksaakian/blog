class HtmlBody
  include Mongoid::Document
  belongs_to :listing

  attr_accessible :body, :url_to_scrape
  field :body, :type => String, :default => "<h1>HTML is not ready yet</h1>"
  field :url_to_scrape, :type => String

  def get_html_body
   	doc = Nokogiri::HTML(open(self.url_to_scrape))
    self.body = doc.at_xpath("//body").inner_html
    self.save
  end
end