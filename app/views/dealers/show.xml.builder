#xml.instruct!
@dealer.reset_counter
xml.dataroot do
    @dealer.listings.each do |listing|
      xml.posts do
        xml.id listing.numeral_id
        xml.title listing.title
        xml.body listing.body
        xml.campaign listing.campaign_number
        xml.city listing.city
        xml.cat listing.cat
        xml.age listing.age
        xml.locat listing.locat
        xml.ema 1
      end
    end
end