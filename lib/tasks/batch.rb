class Tasks::Batch
  def self.parse
    #seekingalpha business, wall stories jurnal business, washinton post business, ajc business, fox business, times business, CNN money

    #
    urls = ['http://seekingalpha.com/analysis/all/most-popular/feed','http://www.wsj.com/xml/rss/3_7014.xml', 'http://feeds.washingtonpost.com/rss/business', 'http://www.ajc.com/flist/business/top-business-headlines/fCb/rss/','http://feeds.foxbusiness.com/foxbusiness/latest', 'http://rss.nytimes.com/services/xml/rss/nyt/Business.xml', 'http://rss.cnn.com/rss/money_news_international.rss']
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

  def self.getContentByReadability(fara, item, site)
    entry = Entry.new
    content = Content.new

      entry.site = site
      entry.title = item.title
      entry.content_created_at = DateTime.now
      entry.url = item.url

      res = fara.get item.url
      doc  = Readability::Document.new(res.body, :tags => %w[div p img a font br], :attributes => %w[src href], :remove_empty_nodes => false)
      nokogiri = Nokogiri::HTML(doc.content.encode("UTF-8"))
      doc.images.each do |image|
        if Entry.where(image: image).blank?
          entry.image = image
          break
        end
      end
      if entry.image.nil?
        tmp = Nokogiri::HTML(res.body)
        tmp.xpath("//meta[@property='og:image']/@content").each do |attr|
          entry.image = attr.value
        end
      end
      return if entry.image.nil?
      entry.description = nokogiri.text[0, 200]
      if entry.save
        AccessLog.create(entry_id: entry.id, user_id: 0)
      end
      puts "#{Entry.count} #{doc.images} #{item.url}"

      content.entry_id = entry.id
      content.text = nokogiri.text
      content.html = doc.content.encode("UTF-8")
      content.save
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
      if entry.save
        AccessLog.create(entry_id: entry.id, user_id: 0)
      end

      content.entry_id = entry.id
      content.text = result['objects'][0]['text']
      content.html = result['objects'][0]['html']
      content.save
    rescue
      puts "Error"
    end
  end
end