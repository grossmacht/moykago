# MoykaGo — Toshkent avtomoyka bron qilish platformasi

Biznes-rejaning **1-bosqichi (Agregator MVP)** bo'yicha qurilgan veb-sayt:
mijoz tumanidagi moykani topadi, xizmat va vaqtni tanlab bron qiladi;
moyka egasi panelda bronlarni boshqaradi; administrator butun tizimni ko'radi.

Hamroh hujjatlar: `avtomoyka_biznes_reja.docx`, `avtomoyka_marketplace_bozor_tahlili.docx`,
`avtomoyka_moliyaviy_model.xlsx` (C:\Project\Moyka).

## Imkoniyatlar

**Mijoz uchun (ro'yxatdan o'tish shart emas):**
- Moykalarni tuman, narx va reyting bo'yicha qidirish/saralash
- Xizmatlar, narxlar, ish vaqti, sharhlar (reyting — suv tomchilari 💧)
- Sana + soatga bron qilish (band/o'tgan soatlar avtomatik yopiladi)
- Bron kodi (masalan, `M7K2QX`) orqali holatni kuzatish va bekor qilish
- «Bronlarim» — telefon raqami bo'yicha barcha bronlarni ko'rish

**Moyka egasi paneli** (`/panel/kirish`):
- Kunlik bronlar ro'yxati: tasdiqlash / bajarildi / bekor qilish
- Xizmatlar va narxlarni boshqarish
- Moyka ma'lumotlari (ish vaqti, postlar soni va h.k.)

**Admin panel** (`/admin`):
- Ko'rsatkichlar: moykalar, bronlar, oylik GMV
- Moykalarni qo'shish/tahrirlash, egasiga kirish ochish
- Barcha bronlar (holat bo'yicha filtr)

## Texnologiya

Ruby on Rails 8.1 · SQLite · Hotwire/Turbo · Propshaft (toza CSS, framework'siz).
Onlayn to'lov (Payme/Click/Uzum) va SMS xabarnoma — keyingi bosqich uchun joy qoldirilgan
(hozircha to'lov joyida: naqd/karta).

## Ishga tushirish (WSL Ubuntu)

```bash
cd ~/moyka
bin/rails db:prepare db:seed   # birinchi marta
bin/rails server -b 0.0.0.0 -p 3111
# Brauzerda: http://localhost:3111
```

## Demo kirishlar (seed ma'lumotlari)

| Rol | Telefon | Parol |
|---|---|---|
| Administrator | +998900000000 | admin123 |
| Moyka egasi (AquaLux) | +998900000001 | moyka123 |
| Moyka egalari (qolgan 11 ta) | +998900000002 … +99890000012 | moyka123 |

Seed'da 12 ta namunaviy Toshkent moykasi, 46 xizmat va sharhlar bor —
haqiqiy moykalar ulanganida admin paneldan kiritiladi.

## Telegram-bot

Sayt bilan **bitta bazada** ishlaydi: botdan qilingan bron moyka egasi panelida
va admin panelda darhol ko'rinadi.

Bot oqimi: `/start` → 🚿 Moyka topish → tuman → moyka → xizmat → sana → soat →
telefon (kontakt tugmasi) → ✅ bron kodi. «📋 Bronlarim» — ko'rish va bekor qilish.

**Ishga tushirish:**
1. Telegram'da [@BotFather](https://t.me/BotFather) → `/newbot` → token oling
2. Tokenni saqlang: `echo "TOKEN" > config/telegram_token` (git'ga tushmaydi)
3. `bin/rails bot:run`

Token'siz sinash: `bin/rails runner script/bot_simulation.rb` — to'liq suhbatni
taqlid qilib, 13 ta tekshiruv o'tkazadi.

## Keyingi qadamlar (rejaga muvofiq)

1. Payme/Click onlayn to'lov integratsiyasi
2. SMS orqali bron tasdig'i (Eskiz.uz yoki Play Mobile)
3. Obuna paketlari va B2B modul (2–3-bosqich)
