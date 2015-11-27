class Api::V1::AccessLogsController < ApplicationController
  def access
    entry_id = param[:entry_id]
    user_id = param[:user_id]
    AccessLog.crate(entry_id: entry_id, user_id: user_id)
  end
end