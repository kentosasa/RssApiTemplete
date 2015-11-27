class Api::V1::EntriesController < ApplicationController
  def all
    render json: Entry.all
  end

  def new_entry
    render json: Entry.order("content_created_at DESC").limit(20)
  end

  def daily_ranking
    now = DateTime.now
    now -= 1
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now) }
  end

  def weekly_ranking
    now = DateTime.now
    now -= 7
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now) }
  end

  def monthly_ranking
    now = DateTime.now
    now -= 31
    render json: Entry.all.sort_by { |k| AccessLog.where(entry_id: k[:id]).where("created_at >= ?", now) }
  end

  def entries
    ids = param[:ids]
    entries = []
    ids.each do |id|
      entries << Entry.find(id)
    end
    render json: entries
  end
end