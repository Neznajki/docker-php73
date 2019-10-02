# docker-php73
Docker Image For Local PHP Project Versions


# installation
* git clone git@github.com:Neznajki/docker-php73.git
* cd docker-php73
* docker build -t docker/php73 .

# install proxy
* git clone git clone https://github.com/jwilder/nginx-proxy.git
* cd nginx-proxy
* docker build -t nginx/proxy .

# certificate enable
* create cert
```bash
mkdir ~/certs/
cd ~/certs

cat > local.conf <<EOL
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
organizationName_default = local

commonName          = Common Name (e.g. server FQDN or YOUR name)
commonName_default  = *.local

emailAddress         = Email Address
emailAddress_default = 
EOL

openssl req -nodes -new -x509 -keyout local.key -out local.crt -config local.conf
```
* start network
```bash
docker network create local_network
docker run -d --name local_network -p 80:80 -p 443:443 --restart always --net local_network -v /var/run/docker.sock:/tmp/docker.sock:ro -v $HOME/certs:/etc/nginx/certs/:ro nginx/proxy:latest
```
