class Tasks::Batch
  def self.parse
    urls = ['http://b-o-y.me/feed','http://mens.tasclap.jp/rss', 'http://mtrl.tokyo/feed','https://jooy.jp/feed.rss', 'http://mtrl.tokyo/comments/feed']
    urls.each do |url|
      xml = Faraday.get(url).body
      feed = Feedjira::Feed.parse xml
      site = feed.title
      fara = Faraday.new
      feed.entries.each do |entry|
        getContentByReadability(fara, entry, site)
      end
    end
    # setWord
    # setCategory
  end

  def self.setWord
    nm = Natto::MeCab.new
    Entry.all.each do |entry|
      next if entry.entry_word_relations.count > 0
      nm.parse(entry.content.text) do |n|
        next unless n.feature.split(',')[0] == '名詞'
        Word.create(val: n.surface)
        EntryWordRelation.create(entry_id: entry.id, word_id: Word.find_by_val(n.surface).id)
      end
      Entry.delete(entry) if entry.words.count == 0
    end
  end

  def self.setCategory
    categories = []
    Entry.pluck(:category).uniq.compact.each do |category|
      10.times do |n|
        tmp = Hash.new(0)
        tmp['category'] = category
        tmp['entry'] = Entry.where(category: category).sample(1)[0]
        tmp['vec'] = getVec(tmp['entry'])
        categories << tmp
      end
    end

    Entry.all.each do |entry|
      next if entry.category.present?
      vec = getVec(entry)
      results = []
      categories.each do |stand|
        tmp = Hash.new(0)
        tmp['score'] = getSimilar(stand['vec'], vec)
        tmp['category'] = stand['category']
        results << tmp
      end
      entry.update_column(:category, results.sort_by{|tmp| tmp['score']}.last['category'])
    end
  end

  def self.getSimilar(vec_a, vec_b)
    tmp_p = Time.now
    ab = 0
    a = 0
    b = 0

    Word.pluck(:val).each do |val|
      ab += vec_a[val] * vec_b[val]
      a += vec_a[val] **2
      b += vec_b[val] **2
    end
    puts "getSim #{Time.now-tmp_p}"
    return ab/(Math.sqrt(a)*Math.sqrt(b))
  end


  private
  def self.getVec(entry)
    tmp_p = Time.now
    vec = Hash.new(0)
    entry.entry_word_relations.each do |rel|
      vec[rel.word.val] += 1
    end
    vec.each do |key, val|
      vec[key] = (1-Math.log(Word.find_by_val(key).entries.uniq.count ,Entry.count))*val/entry.entry_word_relations.count.to_f
    end
    puts "getVec #{Time.now-tmp_p}"
    return vec
  end

  def self.getContentByReadability(fara, item, site)
    entry = Entry.new
    content = Content.new

      entry.site = site
      entry.title = item.title
      entry.content_created_at = item.updated
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
      entry.description = nokogiri.text[0, 200]
      entry.save

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