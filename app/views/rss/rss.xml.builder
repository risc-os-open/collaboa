xml.instruct!
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@rss_title)
    xml.link(format_host_url)
    xml.description(@rss_title)
    @items.each { |item|
      xml.item do
        xml.title(h(item[:title]))
        xml.description(item[:content])
        xml.pubDate(item[:date].strftime("%a, %d %b %Y %H:%M:%S %Z"))
        xml.tag!("dc:creator", item[:author])
        xml.guid("Collaboa-#{item[:date].to_i}", "isPermaLink" => "false")
        xml.link(format_host_url + item[:link])
      end
    }
  end
end
