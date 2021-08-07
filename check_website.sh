#!/bin/bash

test -f result.log && rm -f result.log
echo '' > result.log
for url in $@
do
        #curl抓取网站http状态码
        code=`curl -o /dev/null --retry 3 --retry-max-time 8 -s -w %{http_code} $url`
        echo "$code ---> $url">>result.log
done

#找出非200返回码的站点
cat result.log | grep -v 200
exit 0
