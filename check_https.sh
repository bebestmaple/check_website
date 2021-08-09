#!/bin/bash
################ Version Info ##################
# Create Date: 2021-08-09
# Version:     1.0
# Attention:   通过域名获取证书的过期时间
################################################

test -f result.log && rm -f result.log
echo '' > result.log

grep -v '^#' $@ | while read line;do # 读取存储了需要监测的域名的文件
    # echo "${line}"
    get_domain=$(echo "${line}" | awk -F ':' '{print $1}')
    get_port=$(echo "${line}" | awk -F ':' '{print $2}')

    # echo ${get_domain}
    # echo "${get_port}"
    # echo "======"

    # 使用openssl获取域名的证书情况，然后获取其中的到期时间
    END_TIME=$(echo | openssl s_client -servername ${get_domain}  -connect ${get_domain}:${get_port} 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' )

    END_TIME1=$(date +%s -d "$END_TIME") # 将日期转化为时间戳
    NOW_TIME=$(date +%s -d "$(date "+%Y-%m-%d %H:%M:%S")") # 将当前的日期也转化为时间戳
    RST=$(($(($END_TIME1 - $NOW_TIME))/(60*60*24))) # 到期时间减去目前时间再转化为天数

    echo "证书有效天数剩余：${RST}"

   if [ $RST -lt 30 ];then
     echo "$get_domain https 证书有效期少于30天，存在风险" >> result.log
   #else
   #  echo "$get_domain https 证书有效期在30天以上，放心使用!"
   fi
done

cat result.log | grep -v 200
exit 0
