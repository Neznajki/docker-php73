# docker-php73
Docker Image For Local PHP Project Versions


# installation
* docker login docker.pkg.github.com -u USERNAME -p PASSWORD/TOKEN
* start network | https enabled network in certificate enable section
```bash
docker network create local_network
docker run -d --name local_network -p 80:80 --restart always --net local_network -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy:latest
```

#setup mysql
```bash
mkdir -p ~/docker_common/mysql
cd ~/docker_common/mysql
cat > docker-compose.yml <<EOL
# Use root/example as user/password credentials

version: '3.1'

services:
    adminer:
        image: adminer
        restart: always
        ports:
            - 8080:8080

    mysql:
        hostname: mysql
        image: mysql:5.7
        container_name: mysql
        restart: always
        environment:
            MYSQL_DATABASE: 'authorization'
            # So you don't have to use root, but you can if you like
            MYSQL_USER: 'user'
            # You can use whatever password you like
            MYSQL_PASSWORD: '1'
            # Password for root access
            MYSQL_ROOT_PASSWORD: 'p1assword'
        ports:
            # <Port exposed> : < MySQL Port running inside container>
            - '3306:3306'
        expose:
            # Opens port 3306 on the container
            - '3306'
            # Where our data will be persisted
        volumes:
            #if you use /tmp dir there is chance that all data will be erased so you could pick any other dir
            - /tmp/authorization-module/db:/var/lib/mysql:cached

networks:
    default:
        external:
            name: local.net
EOL

docker-compose up -d

``` 

# certificate enable
* create cert
```bash
mkdir ~/certs/
cd ~/certs

cat > local.net.conf <<EOL
[ req ]
default_bits        = 2048
distinguished_name  = subject
string_mask         = utf8only

[ subject ]
countryName             = Country Name (2 letter code)
countryName_default     = LV

stateOrProvinceName     = State or Province Name (full name)
stateOrProvinceName_default = Latvia

localityName            = Locality Name (eg, city)
localityName_default    = Riga

organizationName         = Organization Name (eg, company)
organizationName_default = local_network

commonName          = Common Name (e.g. server FQDN or YOUR name)
commonName_default  = *.local.net

emailAddress         = Email Address
emailAddress_default = 
EOL

openssl req -nodes -new -x509 -keyout local.net.key -out local.net.crt -config local.net.conf
```
* start network dynamic
```bash
docker network create local.net 
docker run -d --name local_network -p 80:80 -p 443:443 --restart always --net local.net -v /var/run/docker.sock:/tmp/docker.sock:ro -v $HOME/certs:/etc/nginx/certs/:ro jwilder/nginx-proxy:latest
```
* start network strict
```bash
docker network create local.net \
--gateway=172.228.0.1 \
--subnet=172.228.0.0/25
docker run -d --name local_network -p 80:80 -p 443:443 --restart always --net local.net -v /var/run/docker.sock:/tmp/docker.sock:ro -v $HOME/certs:/etc/nginx/certs/:ro jwilder/nginx-proxy:latest
```
