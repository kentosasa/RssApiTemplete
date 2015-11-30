class Tasks::Batch
  def self.parse
    urls = ['http://blog.livedoor.jp/dqnplus/atom.xml', 'http://blog.livedoor.jp/news23vip/atom.xml', 'http://blog.livedoor.jp/kinisoku/index.rdf', 'http://news4wide.livedoor.biz/index.rdf']
    urls.each do |url|
      xml = Faraday.get(url).body
      feed = Feedjira::Feed.parse xml
      site = feed.title
      feed.entries.each do |entry|
        getContent(entry, site)
      end
    end
  end

  def self.getContent(item, site)
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
      res = conn.get '', {url: item.url, token: 'ffb1589fc545ecf85b9947b26f758409'}
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