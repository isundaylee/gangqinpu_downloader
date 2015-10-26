require_relative 'gangqinpu_downloader'

url = ARGV[0]
output = ARGV[1]

GangqinpuDownloader.new(url).download(output)