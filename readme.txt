1. If you try to run this first of all: change paths to local folders in file 
docker-compose.yml <f:/tarantool/tarantool_kvstorage> - instead put your path here
-------
...
    volumes:
      - f:/tarantool/tarantool_kvstorage:/opt/tarantool
      - f:/tarantool/tarantool_kvstorage/data:/var/lib/tarantool
...
-------

2. Use docker to deply it on Windows 10

3. Do not forget to map your disk (F: in my case) for docker aswell (see link below [4])

4. links:
[1] rest client: https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo
[2] docker: https://www.docker.com/
[3] tarantool http server reference: https://github.com/tarantool/http
[4] docker + tarantool on windows guide: https://habr.com/ru/company/mailru/blog/321998/
[5] some dude with some ideas: https://www.youtube.com/watch?v=OKP_mZYw470

5. call 'docker-compose up' in this folder to run this thing



