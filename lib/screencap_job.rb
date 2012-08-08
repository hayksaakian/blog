module ScreencapJob
	def process(id)
		listing = Listing.find(id)
		file = File.new("#{Rails.root}/tmp/#{Process.pid}_snapshot_#{self.id}",'wb')
    #s = root_url+'404'
    s = "http://hayktest.herokuapp.com/404"
    #s = "/"
    file.write(IMGKit.new(s).to_png)
    file.flush
    listing.snapshot = file
    listing.save
	end
end