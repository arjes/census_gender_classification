class Person < ActiveRecord::Base
  validates :gender, inclusion: {in: ['male', 'female', ''] }
  validates :height, presence: true
  validates :weight, presence: true
end
