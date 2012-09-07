module ApplicationHelper
	def number_to_currency(number, options = {})
	  options[:locale] ||= I18n.locale
	  super(number, options)
	end
  def initial_caps
    self.tr('-', ' ').split(' ').map { |word| word.chars.first.upcase.to_s + "." }.join
  end
end
