#xml.instruct!
xml.dataroot do
  xml.posts do
    @dealer.listings.each do |listing|
      xml.post do
        xml.id listing.id
        xml.title listing.title
        xml.body listing.body
        xml.campaign 11111
        xml.city listing.city
        xml.cat listing.cat
        xml.age listing.age
        xml.locat listing.locat
        xml.ema 1
      end
    end
  end
end