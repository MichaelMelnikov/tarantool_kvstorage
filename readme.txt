1. If you try to run this thing, first of all: change paths to local folders in file docker-compose.yml
<f:/tarantool/tarantool_kvstorage> - instead put your path here
-------
...
    volumes:
      - f:/tarantool/tarantool_kvstorage:/opt/tarantool
      - f:/tarantool/tarantool_kvstorage/data:/var/lib/tarantool
...
-------

2. Use Docker to deploy it on Windows 10

3. Do not forget to map your disk (F: in my case) for Docker aswell (see link below [4] for details)

4. links:
[1] rest client: https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo
[2] Docker: https://www.docker.com/
[3] Tarantool http server reference: https://github.com/tarantool/http
[4] Docker + Tarantool on Windows guide: https://habr.com/ru/company/mailru/blog/321998/
[5] some dude with some ideas: https://www.youtube.com/watch?v=OKP_mZYw470

5. call 'docker-compose up' in root folder to run this thing

6. interface: POST /kv, PUT /kv/key, GET /kv, GET /kv/key, DELETE /kv/key

7. Valid POST body
{
  "body":
  {
   "key": "test2",
    "value":
    {
      "DDDDD": "2dd2222",
      "AAAAA": "wwwweee",
      "VVVV": 0.0,
      "GGGGG": 66
    }
  }
}

8. Valid PUT body

{
  "body":
  {
    "value":
    {
      "DDDDD": "2dd2222",
      "AAAAA": "wwwweee",
      "VVVV": 0.0,
      "GGGGG": 66
    }
  }
}
