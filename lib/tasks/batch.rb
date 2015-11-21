class Tasks::Batch
  def self.parse
    url = 'http://alfalfalfa.com/index.rdf'
    xml = Faraday.get(url).body
    feed = Feedjira::Feed.parse xml
    feed.entries.each do |entry|
      puts entry.title
    end
  end
end