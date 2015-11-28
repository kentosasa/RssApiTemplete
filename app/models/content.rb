# == Schema Information
#
# Table name: contents
#
#  id         :integer          not null, primary key
#  entry_id   :integer
#  text       :text(65535)
#  html       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Content < ActiveRecord::Base
end
