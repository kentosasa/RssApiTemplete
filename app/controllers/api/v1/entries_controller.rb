class Api::V1::EntriesController < ApplicationController
  def all
    render json: Entry.all
  end
end