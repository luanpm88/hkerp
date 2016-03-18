class UsersWorksheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :worksheet
end
