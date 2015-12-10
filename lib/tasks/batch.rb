class Tasks::Batch
  def self.parse
    urls = ['http://blog.livedoor.jp/dqnplus/atom.xml', 'http://blog.livedoor.jp/news23vip/atom.xml', 'http://blog.livedoor.jp/kinisoku/index.rdf', 'http://news4wide.livedoor.biz/index.rdf', 'http://news4vip.livedoor.biz/index.rdf', 'http://kanasoku.info/index.rdf', 'http://bipblog.com/index.rdf', 'http://alfalfalfa.com/index.rdf']
    urls.each do |url|
      xml = Faraday.get(url).body
      feed = Feedjira::Feed.parse xml
      site = feed.title
      fara = Faraday.new
      feed.entries.each do |entry|
        getContentByReadability(fara, entry, site)
      end
    end
  end
  # def self.parse
  #   urls = ['http://blog.livedoor.jp/dqnplus/atom.xml', 'http://blog.livedoor.jp/news23vip/atom.xml', 'http://blog.livedoor.jp/kinisoku/index.rdf', 'http://news4wide.livedoor.biz/index.rdf']
  #   urls.each do |url|
  #     xml = Faraday.get(url).body
  #     feed = Feedjira::Feed.parse xml
  #     site = feed.title
  #     feed.entries.each do |entry|
  #       getContentByDiffBot(entry, site)
  #     end
  #   end
  # end

  def self.getContentByReadability(fara, item, site)
    entry = Entry.new
    content = Content.new

    begin
      entry.site = site
      entry.title = item.title
      entry.content_created_at = item.updated
      entry.url = item.url

      res = fara.get item.url
      doc  = Readability::Document.new(res.body, :tags => %w[div p img a font br], :attributes => %w[src href], :remove_empty_nodes => false)
      nokogiri = Nokogiri::HTML(doc.content.encode("UTF-8"))
      entry.image = doc.images[0]
      entry.description = nokogiri.text[0, 200]
      entry.save

      content.entry_id = entry.id
      content.text = nokogiri.text
      content.html = doc.content.encode("UTF-8")
      content.save
    rescue
      puts "Error"
    end
  end

  def self.getContentByDiffBot(item, site)
    entry = Entry.new
    content = Content.new

    begin
      entry.site = site
      entry.title = item.title
      entry.content_created_at = item.updated

      conn = Faraday::Connection.new(:url => 'http://api.diffbot.com/v3/article') do |builder|
        builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
        builder.use FaradayMiddleware::FollowRedirects
        builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
      end
      res = conn.get '', {url: item.url, token: '22ee9be1be359a9d6b84e456fe081221'}
      result = JSON.parse(res.body)
      entry.url = item.url
      entry.image = result['objects'][0]['images'][0]['url']
      entry.description = result['objects'][0]['text'][0, 200]
      entry.save

      content.entry_id = entry.id
      content.text = result['objects'][0]['text']
      content.html = result['objects'][0]['html']
      content.save
    rescue
      puts "Error"
    end
  end
end