class Tasks::Batch
  def self.parse
    url = 'http://hypernews.2chblog.jp/atom.xml'
    xml = Faraday.get(url).body
    feed = Feedjira::Feed.parse xml
    puts feed.title
    feed.entries.each do |entry|
      getContent(entry)
    end
  end

  def self.getContent(entry)
    title = entry.title
    created_at = entry.updated
    summary = entry.summary

    conn = Faraday::Connection.new(:url => 'http://api.diffbot.com/v3/article') do |builder|
      builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
      builder.use FaradayMiddleware::FollowRedirects
      builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
    end
    res = conn.get '', {url: entry.url, token: 'ffb1589fc545ecf85b9947b26f758409'}
    result = JSON.parse(res.body)
    text = result['objects'][0]['text']
    html = result['objects'][0]['html']
    image = result['objects'][0]['images'][0]['url']
    puts title
    begin
    rescue
    end
  end
end