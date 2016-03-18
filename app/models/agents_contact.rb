class AgentsContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :agent, :class_name => "Contact"
end
