Spree::User.class_eval do
  has_many :boards, :foreign_key => :designer_id

end