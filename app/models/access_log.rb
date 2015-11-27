# == Schema Information
#
# Table name: access_logs
#
#  id         :integer          not null, primary key
#  entry_id   :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AccessLog < ActiveRecord::Base
end
