class User
  include Mongoid::Document
  attr_accessible :email, :password, :password_confirmation, :account_type, :contact_name, :contact_number, :address, :zip_code
  has_and_belongs_to_many :dealers

  field :email, :type => String
  field :password_hash, :type => String
  field :password_salt, :type => String

  field :account_type, :type => String
  field :contact_name, :type => String
  field :contact_number, :type => String
  field :address, :type => String
  field :zip_code, :type => String

  attr_accessor :password
  before_save :encrypt_password

  validates :password, :confirmation => true
  validates :password, :presence => true, :on => :create
  validates :email, :presence => true
  validates :email, :uniqueness => true
  
  def self.authenticate(email, password)
  	user = User.first(conditions: { email: email })
    #user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
