---
author: Feri Galung
pubDatetime: 2025-05-22T05:00:00Z
modDatetime: 2025-05-22T05:22:47.400Z
title: Cara Migrasi Website dari Vercel ke Cloudflare Pages (Gratis)
slug: cara-pindahin-website-dari-vercel-ke-cloudflare-pages
featured: true
draft: true
tags:
  - deployment
  - migrasi
  - hosting
description:
  Solusi untuk yang mau pindah dari vercel, tanpa beli VPS
---

## Table of contents


## 🧩 Pendahuluan

Gue udah cukup lama hosting website pribadi gue di Vercel karena gampang setupnya, cocok buat Astro JS. Tapi belakangan ini, gue mutusin buat cabut dan pindah ke Cloudflare Pages.

Alasan gue bukan cuma soal teknis, tapi juga soal prinsip pribadi. Di artikel ini, gue bakal jelasin dua sisi itu: kenapa secara **etis** gue nggak nyaman lagi pakai Vercel, dan kenapa **secara teknis** Cloudflare Pages bisa jadi alternatif yang solid.

---

## ✊ Alasan Personal: Gue Cabut dari Vercel karena Prinsip

Beberapa waktu lalu, CEO Vercel _*(Guillermo Rauch)*_ nge-tweet *"gm from the Holy Land 🇮🇱 💙"* tanpa nunjukin empati apa pun ke warga sipil Palestina yang lagi dijajah dan dibantai.

👉 [Lihat tweet dari Guillermo Rauch](https://x.com/rauchg/status/1918517763644985605)

Sebagai individu, gue ngerasa nggak nyaman terus pakai platform yang pemimpinnya ngasih statement kayak gitu

---

## ⚙️ Alasan Teknis: Cloudflare Pages Cukup Banget buat Kebutuhan Gue

Selain alasan personal, ternyata secara teknis juga Cloudflare Pages **bukan downgrade sama sekali**. Bahkan buat use-case kayak gue (blog pribadi static), malah lebih ringan dan cepat.

Beberapa hal yang gue suka:

- Auto deploy via GitHub (mirip kayak Vercel)
- Support custom domain + SSL gratis
- CDN & DNS-nya udah di-handle langsung sama Cloudflare
- Gratis, tanpa batasan bandwidth kayak Vercel
- Bisa dipakai buat Next.js static export juga

---

## 🔁 Step-by-Step Migrasi dari Vercel ke Cloudflare Pages

Berikut langkah-langkah migrasi yang gue lakuin:

1. **Clone repo dari GitHub**  
   Gue udah connect-in Vercel ke GitHub dari awal, jadi tinggal pull aja.

2. **Export ke static site**  
   Kalau pakai Next.js, tambahin ini di `next.config.js`:
   ```js
   module.exports = {
     output: 'export',
   };
