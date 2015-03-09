class Spree::BoardProduct < ActiveRecord::Base
  
  belongs_to :board
  belongs_to :product	
  before_create :set_z_index
  default_scope  { where("#{Spree::BoardProduct.quoted_table_name}.deleted_at IS NULL") }
  
  state_machine :state, :initial => :pending_approval do
    event :mark_for_approval do
      transition [:pending_approval, :marked_for_deletion, :marked_for_removal] => :marked_for_approval
    end
    
    event :approve do
      transition [:pending_approval, :marked_for_deletion, :marked_for_approval] => :approved
    end
    
    event :remove do
      transition :marked_for_removal => :removed, :unless => :published_on_site
    end
    
    event :mark_for_removal do
      transition [:pending_approval, :marked_for_approval, :approved] => :marked_for_removal, :unless => :published_on_site
    end
    
    event :delete do
      transition [:pending_approval, :marked_for_approval, :approved] => :deleted, :unless => :published_on_site
    end
    
    event :mark_for_deletion do
      transition [:pending_approval, :marked_for_approval, :approved] => :marked_for_deletion, :unless => :published_on_site
    end
    
  end
  
  
  def published_on_site
    false
  end
  
  def self.by_supplier(supplier_id)
    includes(:product).where("products.supplier_id = #{supplier_id}").references(:product)
  end
  
  def set_z_index
    self.z_index = self.board.board_products.size
  end
  
  def destroy
    board = self.board
    self.update_attribute('deleted_at', Time.zone.now)
    if board
      board.board_products.reload
      board.queue_image_generation
    end
  end
  
  def self.marked_for_removal
    where(:state => "marked_for_removal")
  end
  
  def self.marked_for_deletion
    where(:state => "marked_for_deletion")
  end
  
  def self.marked_for_approval
    where(:state => "marked_for_approval")
  end
  
  def self.approved
    where(:state => "approved")
  end
  
  def self.pending_approval
    where(:state => "pending_approval")
    #includes(:product).where("isnull(spree_products.deleted_at) and isnull(spree_board_products.approved_at) and isnull(spree_board_products.removed_at)")
  end
  
end