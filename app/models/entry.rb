# == Schema Information
#
# Table name: entries
#
#  id                 :integer          not null, primary key
#  site               :string(255)
#  title              :string(255)
#  description        :text(65535)
#  content_created_at :datetime
#  text               :text(65535)
#  html               :text(65535)
#  image              :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  url                :string(255)
#

class Entry < ActiveRecord::Base
end
