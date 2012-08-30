class Snapshot
  include Mongoid::Document
  belongs_to :listing

  attr_accessible :snapshot, :url_to_shoot
  mount_uploader :snapshot, SnapshotUploader
  field :snapshot
  field :url_to_shoot, :type => String

  def make_snapshot
	  file = Tempfile.new(["#{Process.pid}_snapshot_#{self.id}", 'png'], '/tmp', :encoding => 'ascii-8bit')
	  file.write(IMGKit.new(self.url_to_shoot).to_png)
	  file.flush
	  self.snapshot = file
	  self.save
	  file.unlink
	  self.listing.html_body.delay.get_html_body
  end
end
