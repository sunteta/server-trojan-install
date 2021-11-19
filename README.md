<img src='https://github.com/xflash-panda/server-shaowsocks-install/blob/master/img/xflash-panda.png' width='100px' align='center'>


## 建议

> 我们建议您使用Debian(>=8)进行部署，当然你也可以选择CentOS(>=7)

> 服务端版本请使用 [xflash-panda/v2board](https://github.com/xflash-panda/v2board), 不要使用原版，采用了新的接口协议

## 快速使用

1.首先将节点域名解析到节点服务器，并且可以ping通  
2.执行下列命令签发证书

```
# 请将命令中的domain.com替换成节点域名

curl -fsSL https://github.com/xflash-panda/server-trojan-install/raw/master/sign.sh | bash -s domain.com
```

3.执行部署命令

```
# 请将命令中的API替换成授权地址
# 请将命令中的TOKEN替换成后台系统配置->服务端->通讯密钥
# 请将命令中的NODE替换成后台添加的节点ID(Trojan)

curl -fsSL https://github.com/xflash-panda/server-trojan-install/raw/master/install.sh | bash -s API TOKEN NODE
```

## Docker 部署
```
docker run -d --name=server-trojan \
-v /root/.cert:/root/.cert \
-e API=API地址 \
-e TOKEN=通讯密钥 \
-e NODE=节点ID \
--restart=always \
--network=host \
xflashpanda/server-trojan:latest
```
