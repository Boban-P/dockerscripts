#### Usage
This container is used to create CA, SUB-CA, Server certificate and client certificates signed with CA or SUB-CA.<br>
mount to /easycrt to preserv files.
```sh
# for generating ca
docker run --rm \
    -e CERT_TYPE=CA
    --mount type=bind,source=/your/cert/path,destination=/easycrt \
    -e COUNTRY={COUNTRY_CODE} \
    -e PROVINCE={PROVINCE_NAME} \
    -e CITY={CITY_NAME} \
    -e ORG={ORGANISATION} \
    -e EMAIL={EMAIL} \
    -e UNIT={ORGANISATION UNIT} \
    -e CN={COMMON NAME} \
    -e KEY_SIZE=2048 \
    -e CA_EXPIRE_DAYS=3650 \
    -e CERT_EXPIRE_DAYS=1080 \
    -e DIGEST=sha512 \
    -e ALGORITHM={ec or rsa} \
    bb526/easyrsa
```
##### Generating Sub ca
```sh
# good to generate CA first
docker run --rm \
    -e CERT_TYPE=SUB-CA
    -e SUB_CA_NAME={your sub ca name} \
    --mount type=bind,source=/your/cert/path,destination=/easycrt \
    -e COUNTRY={COUNTRY_CODE} \
    -e PROVINCE={PROVINCE_NAME} \
    -e CITY={CITY_NAME} \
    -e ORG={ORGANISATION} \
    -e EMAIL={EMAIL} \
    -e UNIT={ORGANISATION UNIT} \
    -e CN={COMMON NAME} \
    -e KEY_SIZE=2048 \
    -e CA_EXPIRE_DAYS=3650 \
    -e CERT_EXPIRE_DAYS=1080 \
    -e DIGEST=sha512 \
    -e ALGORITHM={ec or rsa} \
    bb526/easyrsa
```
##### Generating Signed server certificate.
```sh
docker run --rm \
    -e CERT_TYPE=SERVER
    -e SUB_CA_NAME={your sub ca name} \
    -e CN={COMMON NAME} \
    -e ALT_NAMES={OPTIONAL: FORMAT: DNS:domain1,DNS:domain2,...} \
    --mount type=bind,source=/your/cert/path,destination=/easycrt \
    -e COUNTRY={COUNTRY_CODE} \
    -e PROVINCE={PROVINCE_NAME} \
    -e CITY={CITY_NAME} \
    -e ORG={ORGANISATION} \
    -e EMAIL={EMAIL} \
    -e UNIT={ORGANISATION UNIT} \
    -e KEY_SIZE=2048 \
    -e CERT_EXPIRE_DAYS=1080 \
    -e DIGEST=sha512 \
    -e ALGORITHM={ec or rsa} \
    bb526/easyrsa
```
##### Generating Signed client certificate.
```sh
docker run --rm \
    -e CERT_TYPE=CLIENT
    -e SUB_CA_NAME={your sub ca name} \
    -e CN={COMMON NAME} \
    --mount type=bind,source=/your/cert/path,destination=/easycrt \
    -e COUNTRY={COUNTRY_CODE} \
    -e PROVINCE={PROVINCE_NAME} \
    -e CITY={CITY_NAME} \
    -e ORG={ORGANISATION} \
    -e EMAIL={EMAIL} \
    -e UNIT={ORGANISATION UNIT} \
    -e KEY_SIZE=2048 \
    -e CERT_EXPIRE_DAYS=1080 \
    -e DIGEST=sha512 \
    -e ALGORITHM={ec or rsa} \
    bb526/easyrsa
```
[Refer documentation](https://easy-rsa.readthedocs.io/en/latest/#using-easy-rsa-as-a-ca) | 
[Real easy implementation](https://gist.github.com/QueuingKoala/e2c1c067a312384915b5)
