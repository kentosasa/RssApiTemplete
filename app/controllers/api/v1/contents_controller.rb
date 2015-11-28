class Api::V1::ContentsController < ApplicationController
  before_action :set_page
  def all
    render json: Entry.all.map {|item| item.content }
  end

  def new_entry
    render json: Entry.order("content_created_at DESC")[20 * @page + 0, 20].map {|item| item.content }
  end

  def daily_ranking
    now = DateTime.now
    now -= 1
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now).count }[20 * @page + 0, 20].map {|item| item.content }
  end

  def weekly_ranking
    now = DateTime.now
    now -= 7
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now).count }[20 * @page + 0, 20].map {|item| item.content }
  end

  def monthly_ranking
    now = DateTime.now
    now -= 31
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now).count }[20 * @page + 0, 20].map {|item| item.content }
  end

  def entry_list
    ids = params[:ids]
    entries = []
    ids.each do |id|
      entries << Entry.find(id)
    end
    render json: entries.sort_by { |k| k[:created_at]}.map {|item| item.content }
  end

  private
    def set_page
      page = params[:page] || 1
      @page = page.to_i - 1
    end
end