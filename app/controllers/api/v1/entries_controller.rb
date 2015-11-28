class Api::V1::EntriesController < ApplicationController
  before_action :set_page
  def all
    render json: Entry.all
  end

  def new_entry
    render json: Entry.order("content_created_at DESC")[20 * @page + 0, 20]
  end

  def daily_ranking
    now = DateTime.now
    now -= 1
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now).count }[20 * @page + 0, 20]
  end

  def weekly_ranking
    now = DateTime.now
    now -= 7
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now).count }[20 * @page + 0, 20]
  end

  def monthly_ranking
    now = DateTime.now
    now -= 31
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now).count }[20 * @page + 0, 20]
  end

  def entries
    ids = param[:ids]
    entries = []
    ids.each do |id|
      entries << Entry.find(id)
    end
    render json: entries
  end

  private
    def set_page
      page = params[:page] || 1
      @page = page.to_i - 1
    end
end