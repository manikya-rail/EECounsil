class Blog < ApplicationRecord
  belongs_to :category
  has_one :media, class_name: 'Medium', dependent: :destroy, as: :mediable
  accepts_nested_attributes_for :media, reject_if: :all_blank

  validates :category_id, :title, :description, :media, presence: true
end
