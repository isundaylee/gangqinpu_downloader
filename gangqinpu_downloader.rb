require 'nokogiri'
require 'open-uri'
require 'fileutils'

class GangqinpuDownloader

  URL_REGEX = /http:\/\/www.gangqinpu.com\/html\/(\d+).htm/
  ROOT_URL = "http://www.gangqinpu.com"
  IMG_URL_REGEX = /(.*)\/\d+.gif/
  PAGE_COUNT_REGEX = /共(\d+)页/

  TMP_DIR = '/tmp/gangqinpu_downloader'

  def initialize(url)
    unless url =~ URL_REGEX
      raise 'Invalid URL given: ' + url
    end

    @id = URL_REGEX.match(url)[1].to_i
    @url = url
  end

  def download(output)
    source = open(@url).read.force_encoding('GB2312').encode('utf-8')
    doc = Nokogiri::HTML(source)

    raise 'Cannot find page count. ' unless source =~ PAGE_COUNT_REGEX
    page_count = PAGE_COUNT_REGEX.match(source)[1].to_i

    img = doc.at_css('.pu_look #upid img')
    src = img['src']

    raise 'Invalid image url found: ' + src unless src =~ IMG_URL_REGEX

    img_base = IMG_URL_REGEX.match(src)[1]

    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)

    1.upto(page_count) do |i|
      puts 'Downloading page ' + i.to_s
      img_url = img_base + '/' + i.to_s + '.gif'
      path = File.join(TMP_DIR, i.to_s + '.gif')

      File.write(path, open(ROOT_URL + img_url).read)
    end

    `cd #{TMP_DIR} && convert -border 50x50 *.gif output.pdf`

    FileUtils.mv(File.join(TMP_DIR, 'output.pdf'), output)
  end

end