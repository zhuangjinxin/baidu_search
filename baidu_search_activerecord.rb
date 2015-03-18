require 'socket'
require 'nokogiri'
require 'rubygems'
require_gem 'active_record'

$host = 'www.baidu.com'
$port = 80
$keywords = []
$results = []
$count = 0
$mutex = Mutex.new
$total = $*[1].nil? ? 100000 : $*[1].to_i
$keywords << ($*[0] || "eLong").downcase

def baidu_search_collection(keyword, count)
  if keyword.nil?
    $count = $total
    puts "\n302\n\n"
    return
  end
  return if count > $total
  socket = TCPSocket.open($host, $port)
  print "Search #{(count + 1).to_s.rjust(6)} : #{keyword}\n"
  path = "/s?wd=#{keyword.gsub(' ','%20')}"
  request = "GET #{path} HTTP/1.0\r\n\r\n"
  socket.print(request)
  response = socket.read
  headers, body = response.split("\r\n\r\n", 2)
  return if body.nil?
  body.force_encoding("UTF-8")
  doc = Nokogiri::HTML(body)
  index = 0
  results = []
  keywords = []
  doc.css('.c-container').each do |div|
    if div.css('.t a').any?
      if div[:mu].nil?
        url = div.css('.g').any? ? div.css('.g').first.content.split.first : "null"
      else
        url = div[:mu]
      end
      results << { count: count + 1, keyword: keyword, number: index += 1, title: div.css('.t a').first.content, url: url, created_at: Time.now.to_s }
    end
  end
  socket.close
  doc.css('#rs th a').each do |rs|
    keywords << rs.content.downcase unless $keywords.include?(rs.content.downcase)
  end

  $mutex.lock
    results.each { |result| $results << result }
    keywords.each { |keyword| $keywords << keyword }
  $mutex.unlock
end

ActiveRecord::Base.establish_connection(:adapter=>"mysql",:username=>"root",:password=>"root",:database　=>"mysql",:host=>"localhost")
class Result<ActiveRecord::Base
end
create table results(id integer PRIMARY KEY autoincrement, count integer, keyword varchar, number integer, title varchar, url varchar, created_at varchar)
end

puts

baidu_search_collection($keywords[$count], $count)

while $count < $total
  threads = []
  5.times do
    break if $count >= $total
    threads << Thread.new do
      baidu_search_collection($keywords[$count += 1], $count)
    end
  end
  threads.each do |t|
    t.join(5)
  end
  sleep 8
  if $count.even?
    if $results.count.eql?(0)
      $count = $total
      puts "\n302\n\n"
    else
      puts "\nSave #{$results.count} records to list.db/results\n\n"
      $results.each do |result|
		 rs = Result. new(:count => result[:count],:keyword =>result[:keyword],:number =>result[:number],:title =>result[:title],:url =>result[:url],:created_at =>result[:created_at],)
		 rs.save
      end
      dbh.disconnect if dbh 
      $results.clear
    end
  end
end
