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
    entry.site = site
    entry.title = item.title
    entry.content_created_at = item.updated
    entry.description = item.summary

    conn = Faraday::Connection.new(:url => 'http://api.diffbot.com/v3/article') do |builder|
      builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
      builder.use FaradayMiddleware::FollowRedirects
      builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
    end
    begin
      res = conn.get '', {url: item.url, token: 'ffb1589fc545ecf85b9947b26f758409'}
      result = JSON.parse(res.body)
      entry.url = item.url
      entry.text = result['objects'][0]['text']
      entry.html = result['objects'][0]['html']
      entry.image = result['objects'][0]['images'][0]['url']
      entry.save
    rescue
      puts "Error"
    end
  end
end