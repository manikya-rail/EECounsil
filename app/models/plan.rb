class Plan < ApplicationRecord
  has_many :package_plans, dependent: :destroy
  has_many :packages, through: :package_plans
  has_many :subscriptions

  enum duration_interval: [:day, :week, :month, :year]
  enum valid_days: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  validates :name, presence: true
  validates :duration, presence: true

  validates :duration_interval, presence: true
  validates :valid_days, presence: true
end
