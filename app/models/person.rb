class Person < ActiveRecord::Base
  validates :gender, inclusion: {in: ['male', 'female', ''] }
  validates :height, presence: true, numericality: {greater_than: 0 } 
  validates :weight, presence: true, numericality: {greater_than: 0 } 
end
