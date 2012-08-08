# A model mounting an uploader with delayed processing should pass delayed: true to the uploader:
#     mount_uploader :image, ArtistUploader, delayed: true
# ...and the uploader's versions should be conditional on is_processing_delayed?:
#     version :small, :if => :is_processing_delayed? {...}
module DelayedImageProcessing

 def mount_uploader(column, uploader=nil, options={}, &block)
   delay = options.delete(:delayed)
   super
   if delay
     process_in_background(column)
     if uploader && !uploader.include?(DelayedImageProcessing::UploaderMethods)
       uploader.send(:include, DelayedImageProcessing::UploaderMethods)
     end
   end
 end
 
 def process_in_background(column = :image)
   after_save :"queue_recreate_#{column}_versions!", :if => :"#{column}_file_changed"
   attr_accessor :"#{column}_file_changed"
   define_model_callbacks :image_processing

   class_eval <<-RUBY, _FILE_, __LINE__+1
     def queue_recreate_#{column}_versions!
       self.#{column}_file_changed = false
       self.delay.recreate_#{column}_versions!
     end
     
     def recreate_#{column}_versions!
       begin
         #{column}.is_processing_delayed = true
         _run_image_processing_callbacks do
           #{column}.recreate_versions!
         end
       ensure
         #{column}.is_processing_delayed = false
       end
     end
     
     def #{column}=(obj)  # track when a new file has been set
       super(obj)
       self.#{column}_file_changed = true
     end
   RUBY
   
 end
 
 module UploaderMethods
   def is_processing_delayed?(img = nil)
     !! @is_processing_delayed
   end

   def is_processing_immediate?(img = nil)
     ! is_processing_delayed?
   end

   def is_processing_delayed=(value)
     @is_processing_delayed = value
   end
 end

end
 