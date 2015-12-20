class Word < ActiveRecord::Base
  validates_uniqueness_of :val
  has_many :entry_word_relations
  has_many :entries, through: :entry_word_relations
end
