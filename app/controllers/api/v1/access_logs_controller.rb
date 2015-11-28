class Api::V1::AccessLogsController < ApplicationController
  def access
    entry_id = params[:entry_id]
    user_id = params[:user_id]
    AccessLog.create(entry_id: entry_id, user_id: user_id)
    render json: "OK"
  end
end