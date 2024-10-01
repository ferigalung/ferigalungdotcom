---
author: Sat Naing
pubDatetime: 2024-10-01T05:00:00Z
modDatetime: 2024-10-01T05:22:47.400Z
title: Bagaimana Cara Deploy Dockerized App ke VPS?
slug: deploy-dockerized-app-ke-vps
featured: true
draft: false
tags:
  - deployment
  - docker
  - vps
description:
  Solusi untuk deploy aplikasi backend/frontend dalam bentuk container docker di VPS.
---

## Table of contents


## 1. Persiapan Repository (Setting docker-compose file dan Dockerfile)

Dalam tutorial kali ini kita bakal pakai contoh repository mern-app berikut:
[Mern Boilerplate](https://github.com/ferigalung/mern-boilerplate)

Dalam repo tersebut terdapat 2 folder yaitu backend dan frontend, dalam folder backend, berisi kodingan REST-API menggunakan express, sedangkan di frontend berisikan kodingan reactjs.
![struktur folder](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F6a4807d3-3d1c-44ac-b25d-9bfc1ddade18%2FUntitled.png?table=block&id=0cc3e4a8-ab92-4278-925b-7401739c32ef&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Pertama-tama kita perlu membuat Dockerfile (tanpa extension) pada root repository:
![buat file Dockerfile](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F94f72f0a-610d-4b32-9229-81f3b3ba45f2%2FUntitled.png?table=block&id=d38a1031-89b4-492f-b9ed-727eba4053dd&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Penjelasan singkat tentang apa itu Dockerfile. Dockerfile adalah tempat untuk menaruh rangkaian script yang akan kita jalankan pada container docker yang akan kita buat untuk aplikasi kita. Berikut adalah script Dockerfile yang kita butuhkan:
```docker
FROM node:16-alpine
WORKDIR /app

COPY ./package.json ./package.json
COPY ./backend ./backend
COPY ./frontend ./frontend

RUN npm install
RUN npm install --prefix frontend
RUN npm run build --prefix frontend

EXPOSE 8000

CMD ["npm","start"]
```

Akan saya jelaskan satu persatu script di atas.

- Untuk script pertama yaitu **FROM** adalah script untuk mendefinisikan image apa yang akan dibutuhkan / dipakai oleh aplikasi kita, dalam hal ini kita memakai image node 16 versi alphine. List image yang bisa digunakan bisa kalian check di docker hub: [node - Official Image](https://hub.docker.com/_/node)
- Script kedua **WORKDIR**, script ini berfungsi untuk membuat direktori pada container yang akan kita buat, direktori untuk menyimpan file-file project kita, bisa diisi terserah kalian, pada kasus kali ini kita menamai folder tersebut **/app**.
- Script selanjutnya adalah **COPY**, script ini berfungsi untuk meng-copy file dan direktori dari repository kita dan menaruhnya di container docker yang akan kita buat, dalam hal ini kita perlu meng-copy folder **/backend /frontend** dan file **package.json**.
- Selanjutnya **RUN** adalah script yang perlu kita jalankan nanti di container saat container pertama kali dibuat, script ini sama persis dengan yang biasa kita gunakan saat ingin menjalankan aplikasi kita seperti npm install dan npm run build.
- **EXPOSE** adalah script untuk menentukan di PORT berapa app kita akan berjalan, port yang diexpose ke luar (yang bisa kita akses).
- Terakhir adalah **CMD**, ini fungsinya mirip dengan **RUN** namun **CMD** akan dijalankan setiap kita menjalankan container, dalam hal ini yaitu ***npm start***.

Kurang lebih seperti itu susuan Dockerfile kita, sudah selesai. Sekarang kita akan beralih membuat docker-compose file. Apa itu docker-compose file? docker-compose berfungsi untuk mengeksekusi installasi image beserta configurasinya. Singkatnya, si docker-compose inilah yang akan membuat container docker, sedangkan Dockerfile tadi adalah file configurasi image yang akan kita buat.

Buat file dengan nama **docker-compose.yml** yang berada pada posisi root folder project. Berikut isi dari docker-compose file:
```yaml
networks:
  local:
    external: true

services:
  mernapp:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - 8000:8000
    depends_on:
      - mongo
    networks:
      - local
    environment:
      NODE_ENV: production
      PORT: 8000
      JWT_SECRET: cc7e0d44fd473002f1c42166567ds59001140ec6389b7353f8088f2f59sd32
      MONGO_URL: mongodb://mongo/mern_boilerplate
  mongo:
    image: "mongo:4.4"
    networks:
      - local
    ports:
      - 27017:27017
    volumes:
      - ../mongodb-data:/data
```

akan saya jelaskan singkat tentang script di atas. yang pertama adalah networks, menentukan network apa yang akan kita pakai, di sini saya memakai network bernama local yang akan dapat diakses secara external. Setelah itu kita mendefinisikan services yang akan kita buat. Terdapat 2 service yang kita butuhkan, pertama adalah service mernapp kita, dan mongodb sebagai database.

Terdapat perbedaan yang jelas dari script 2 service di atas, di service mongo, kita langsung mendefinisikan image: “mongo:4.4” sedangkan di service mernapp kita tidak memakai image, tapi build, ini karena kita tidak memakai image yang disediakan docker hub secara langsung, melainkan kita mensettingnya terlebih dulu di Dockerfile kita, jadi kita perlu mem-build ulang image node:16-alphine yang kita pakai.

## 2. Create VM di VPS Service (ex: DigitalOcean)

Login ke penyedia layanan VPS kalian, di sini saya memakai DigitalOcean. Setelah login ke dashboard, pilih Create Droplet (VM), sesuaikan setting spesifikasi VM sesuai yang kalian mau, setelah itu tekan Create Droplet.
![Create Droplet di DigitalOcean](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F815e5b29-e568-4d37-9816-2074d17dfd81%2FUntitled.png?table=block&id=9292d5a5-d4ca-4a13-9a46-e78235a0e6ab&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Setelah membuat Droplet / VM, kalian akan mendapatkan ip public, ip inilah yang akan kita pakai untuk mengakses VM tersebut via ssh.
![IP Public VM](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F733ece27-6eb4-48ef-ad20-7b04dac095fa%2FUntitled.png?table=block&id=65e73484-9135-48ed-85c5-37310e1c7ff5&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

## 3. Setting DNS di Cloudflare

Untuk DNS managementnya kita akan memakai Cloudflare, Cloudflare ini selain untuk DNS management, kita juga bisa memanfaatkannya sebagai CDN, yang akan membantu site kita bisa diakses lebih cepat menggunakan caching data. Cloudflare juga menyedia SSL certification, namun pada tutorial kali ini, kita hanya akan fokus pada DNS managementnya saja.

Silahkan login ke akun cloudflare kalian di https://dash.cloudflare.com/ jika belum memiliki akun, silahkan daftar terlebih dahulu. Oh iya, pastikan juga untuk punya domain nya terlebih dahulu ya, karena di tutorial ini, berasumsi kalian sudah punya domain.

Setelah login di cloudflare, kalian bisa menambahkan domain kalian dengan cara klik tombol **add site**.
![Home Cloudflare](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F100a9e0b-6e47-4ba6-9172-957bae562ffb%2FUntitled.png?table=block&id=e2ce3bf9-5eee-4860-a3d4-72707fb8464d&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)
![Add Site Cloudflare](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb0f4321b-6cf4-454f-9932-b029e69b2f10%2FUntitled.png?table=block&id=6ccd8aa5-0b9a-4fa9-9e56-87c94b6e2e19&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Setelah berhasil add site, step selanjutnya yang perlu kalian lakukan adalah mengganti name server domain kalian ke name server cloudflare. Caranya adalah kalian login ke website penyedia domain kalian, lalu ubah name server domain kalian di sana, ini adalah contoh cara mengubahnya jika kalian beli domainnya di idwebhost:
![idwebhost](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F2a11bbd0-8a79-4e6e-8c21-d75dc9eb0f68%2FUntitled.png?table=block&id=0a4e79c8-bb04-4047-8df1-1c8a7894d09f&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)
![nameserver idwebhost](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F86c8653a-4ed2-47ba-bead-60298dfc0e9d%2FUntitled.png?table=block&id=2bd8edbf-a627-4242-824f-f98be89f75b7&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

isikan name server cloudflare yang tertera di halaman DNS Cloudflare seperti berikut:
![cloudflare nameserver](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F14aa92cc-45ca-460d-8ce4-66b194ca170f%2FUntitled.png?table=block&id=11dde2ae-2945-4dbc-a9cc-2bf15439438e&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Setelah selesai mengubah nameserver, kita akan menambahkan record pada DNS Cloudflare, buka menu berikut:
![dns cloudflare](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F728fb80c-10a0-4e67-8674-d83c3547146a%2FUntitled.png?table=block&id=312c8783-d03c-4227-ab1a-3dddf1fcd95e&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Tambahkan record dengan cara klik add record isi type nya dengan A, dan name nya isi dengan @ untuk mengarah ke domain default kalian, lalu isi IPv4 Address dengan IP Droplet / VM yang telah kalian buat tadi, lalu save.
![save dns cloudflare](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fe213872b-a3f2-40a7-a10b-cec819f895e6%2FUntitled.png?table=block&id=35f2ee0d-519b-4ffd-8401-f11e859c0a1a&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

pada kasus kali ini, kita akan deploy mernapp kita ke subdomain, bukan di domain utama, maka dari itu, kita perlu untuk menambah record baru lagi, isi type dengan CNAME, isi name dengan nama subdomain yang diinginkan, lalu isi target dengan @, lalu save.
![cname](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fcb27fc33-a0ec-4194-a23a-0d8d556d20c3%2FUntitled.png?table=block&id=4c0c3684-6295-4457-8e31-50846534d18c&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Oke. setting DNS Cloudflare sudah selesai, kita akan beralih ke setting server kita.

## 4. login VM via SSH

Selanjutnya kita akan mengakses VM / Droplet kita via ssh, untuk di windows bisa memakai putty untuk mengakses ssh, namun kali ini saya memakai linux, jadi bisa langsung menggunakan command ssh di terminal seperti di bawah ini
![ssh](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ffce822b9-f679-4435-865c-7363c5d3a261%2FUntitled.png?table=block&id=bbf187e4-0af0-4f6d-8080-48da462f5508&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

masukkan password yang sudah kalian setting tadi, lalu kita bisa login ke VM.
![login ssh](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F979d9142-8647-48d9-b672-9316983232be%2FUntitled.png?table=block&id=86ac4b56-528b-440d-af9d-2aed1147e29b&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

## 5. Installasi Docker

Jalankan script berikut untuk menginstall docker:
```bash
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```
```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```bash
sudo apt-get update
```
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
```bash
sudo groupadd docker
```
```bash
sudo usermod -aG docker $USER
```
```bash
newgrp docker
```

Jalankan semua script di atas satu-persatu, dan docker akan terinstall. Untuk info lebih detail kalian bisa melihat tutorial installasi docker di sini: https://docs.docker.com/engine/install/ubuntu/

## 6. installasi Nginx

Sekarang kita perlu menginstall Nginx, berikut langkah-langkahnya:
```bash
sudo apt update
sudo apt install nginx
```

setelah menginstall nginx, kita perlu settting firewall menggunakan ufw, jalankan script berikut:
```bash
sudo ufw allow 'Nginx HTTP'
```
```bash
sudo ufw allow ssh
```

dengan ini, web server kita akan bisa diakses melalui http dan juga ssh, jangan melewatkan proses ini, karena jika kalian melewatkan proses ini, maka kalian tidak akan bisa mengakses VM kalian lagi via SSH setelah menginstall nginx (seperti saya 🤣).

Setelah itu, kalian bisa mengecek status web server kalian apakah sudah berjalan atau belum dengan cara jalankan command berikut
```bash
systemctl status nginx
```

jika sudah berjalan, maka akan muncul status seperti ini:
![nginx](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F50d58bba-023d-44a5-b266-163f9ac90b6c%2FUntitled.png?table=block&id=468cae74-011b-4ae3-8482-8cb20bb15eb4&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

jika belum aktif, kalian perlu menjalankan command berikut:
```bash
systemctl start nginx
```

Saat ini kalian seharusnya sudah bisa mengakses ip VM kalian di browser, maka akan muncul seperti ini:
![nginx landingpage](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ff66769e8-afe4-44d6-9583-c686743f42c9%2FUntitled.png?table=block&id=d7862882-ef37-4f1b-ab9d-bd0bfc5a473a&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

## 7. Git Clone Repo

Sekarang kita akan membuat folder untuk subdomain kita:
```bash
sudo mkdir -p /var/www/mern-build-test.ferigalung.com/html
```

Setelah itu, atur permissionnya seperti ini:
```bash
sudo chown -R $USER:$USER /var/www/mern-build-test.ferigalung.com/html
```
```bash
sudo chmod -R 755 /var/www/mern-build-test.ferigalung.com
```

lalu change directory ke folder html yang berada di dalam folder subdomain
```bash
cd /var/www/mern-build-test.ferigalung.com**/**html
```

setelah itu, clone repo yang sudah kalian siapkan tadi
```bash
git clone https://github.com/ferigalung/mern-boilerplate.git .
```

## 8. Docker Compose Up

setelah itu, jalankan docker compose up untuk mem-build image dan membuat container docker
```bash
docker compose up -d
```

Jika terdapat error network, maka perlu membuat network terlebih dahulu, lalu jalankan docker compose up lagi
```bash
docker network create local
```

Ok, sampai di sini seharusnya kita sudah bisa mengakses aplikasi kita melalui IP dan port yang sudah kita setting di docker-compose file kita, silahkan coba buka di browser kalian
![login](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F6deaf884-cd8c-4a56-b6a7-a2b5fdcc5156%2FUntitled.png?table=block&id=c882d340-3995-472d-97ef-5214e7765520&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Oke, panjang banget ya prosesnya, dan sampe sekarang mungkin kalian bertanya-tanya, kog aksesnya masih pake IP address, engga pakai subdomain? nah, masih ada proses terakhir yang bakal bikin kita bisa akses lewat subdomain, sabar yah.

## 9. Setting Nginx Config dan Proxypass

Untuk menghindari kemungkinan masalah memori  yang dapat timbul dari penambahan name server, perlu untuk menyesuaikan satu value di file /etc/nginx/nginx.conf. Buka file:
```bash
sudo nano /etc/nginx/nginx.conf
```

lalu hapus **#** di depan line *server_names_hash_bucket_size*
```bash
...
http {
    ...
    server_names_hash_bucket_size 64;
    ...
}
...
```

setelah itu kita membuat server block sesuai nama domain/subdomain kita seperti berikut:
```bash
sudo nano /etc/nginx/sites-available/mern-build-test.ferigalung.com
```

paste script di bawah ini, lalu tekan **Ctrl+X**, ketik **y**, lalu **enter**
```bash
server {
        listen 80;
        listen [::]:80;

        root /var/www/mern-build-test.ferigalung.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name mern-build-test.ferigalung.com www.mern-build-test.ferigalung.com;

        location / {
                proxy_pass http://127.0.0.1:8000;
        }
}
```

script di atas berfungsi supaya ketika seseorang mengakses subdomain kita, maka dia akan diarahkan ke port 8000 yaitu port dari docker container kita, sama seperti mengarahkannya ke IP yang barusan kita akses [http://165.22.249.96:8000](http://165.22.249.96:8000/)

Setelah itu, link file server block tadi ke folder site-enabled, dengan cara jalankan command ini:
```bash
sudo ln -s /etc/nginx/sites-available/mern-build-test.ferigalung.com /etc/nginx/sites-enabled/
```

setelah semuanya selesai, restart server nginx kita:
```bash
sudo systemctl restart nginx
```

Selesai, sekarang coba akses aplikasi kalian menggunakan subdomain
![subdomain](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F335e6b40-c4dd-4873-bd4b-e24283d3a8d9%2FUntitled.png?table=block&id=71439e2b-96e0-4ea5-a09d-c461303741f6&spaceId=bd144859-63a9-49b8-afec-44feb1ee4d75&name=Untitled.png&userId=5863135a-26c9-46c8-8ae5-76783b2e5c58&cache=v2)

Seperti itulah proses deploy aplikasi dari 0 sampai selesai menggunakan docker, nginx, dan juga cloudflare di VPS, selamat mencoba 😁.