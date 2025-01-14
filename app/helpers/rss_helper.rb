module RssHelper
  def format_host_url
    host = "http://" + request.host
    unless (request.port == 80) or (request.port == 443)
      host += ":" + request.port.to_s
    end
    host
  end
end
