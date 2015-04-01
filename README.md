# <h5>百度搜索爬虫</h5>
用linux/mac + ruby + mysql实现<br>
1. 随便找一个词,用于在百度搜索查询一个搜索结果. 拿到底部的10个’相关搜索词’. 这10个词逐个在百度下拉框里获取新的词<br>
2. 遍历所有词汇,重复步骤1 直到抓到10万个不同的关键词. 存到数据库中<br>
3. 遍历这10万个词汇, 向百度查询搜索结果, 用程序解析这个结果 把前10名的title,域名记录到数据库中<br>
4. 所有网络请求的部分用5个线程来执行<br>
5. 所有http请求用socket实现<br>

#baidu_search_mysql.rb
$ruby baidu_search_mysql.rb eLong 100000
[Before running the program,you need install ruby/gem/nokogiri/dbi/mysql on your computer.]
About MySQL:
username:root
password:root
databese:mysql
table:results

#baidu_search_sqlite3.rb
$ruby baidu_search_sqlite3.rb eLong 100000
[Before running the program,you need install ruby/gem/nokogiri/sqlite3 on your computer.]
