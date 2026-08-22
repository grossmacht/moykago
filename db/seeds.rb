# MoykaGo — boshlang'ich (demo) ma'lumotlar.
# Ishga tushirish: bin/rails db:seed

require "securerandom"

puts "Seeding..."

Review.delete_all
Booking.delete_all
Car.delete_all
PromoCode.delete_all
Customer.delete_all
Service.delete_all
User.delete_all
Wash.delete_all

SERVICE_SETS = {
  basic: [
    [ "Standart yuvish (kuzov)", 60_000, 30 ],
    [ "Kuzov + ichki tozalash", 90_000, 50 ],
    [ "Premium yuvish (vosk bilan)", 130_000, 60 ]
  ],
  full: [
    [ "Standart yuvish (kuzov)", 70_000, 30 ],
    [ "Kuzov + ichki tozalash", 100_000, 50 ],
    [ "Premium yuvish (vosk bilan)", 150_000, 70 ],
    [ "Dvigatel yuvish", 120_000, 40 ],
    [ "Kimyoviy tozalash (salon)", 400_000, 180 ]
  ],
  premium: [
    [ "Ekspress yuvish", 80_000, 20 ],
    [ "Premium yuvish (vosk bilan)", 160_000, 60 ],
    [ "Detailing yuvish", 350_000, 120 ],
    [ "Kuzov polirovka", 900_000, 240 ]
  ],
  # SAM boks — bu yerdagi narx BIR DAQIQA uchun (mijoz joyida hisoblagichga
  # qarab pul tashlaydi/kartadan yechadi). "dur" esa taxminiy tavsiya etilgan
  # vaqt, oldindan sotib olinadigan paket emas.
  self_service: [
    [ "Bosimli suv bilan yuvish", 700, 10 ],
    [ "Ko'pik bilan yuvish", 1_100, 8 ],
    [ "Voskli ko'pik (himoya qatlami)", 1_600, 6 ],
    [ "G'ildirak/disklarni kimyoviy tozalash", 1_000, 5 ]
  ],
  automatic: [
    [ "Standart dastur (avtomat)", 35_000, 8 ],
    [ "Premium dastur (voskli, avtomat)", 55_000, 12 ],
    [ "Deluxe dastur (quritish bilan)", 75_000, 15 ]
  ]
}.freeze

WASHES = [
  { name: "AquaLux Moyka", district: "Chilonzor", address: "Bunyodkor shoh ko'chasi, 12A",
    phone: "+998901112233", open_hour: 8, close_hour: 22, bays: 3, featured: true, set: :full,
    description: "Chilonzor markazidagi zamonaviy moyka: 3 post, kutish zali va Wi-Fi." },
  { name: "Toza Avto", district: "Yunusobod", address: "Amir Temur shoh ko'chasi, 88",
    phone: "+998901234567", open_hour: 7, close_hour: 23, bays: 4, featured: true, set: :premium,
    description: "Premium detailing markazi. Keramika va polirovka bo'yicha ustalar." },
  { name: "Oq Bulut", district: "Mirzo Ulug'bek", address: "Buyuk Ipak Yo'li, 45",
    phone: "+998935556677", open_hour: 8, close_hour: 21, bays: 2, featured: true, set: :basic,
    description: "Metro yonida, tez va sifatli. Doimiy mijozlarga chegirma." },
  { name: "Crystal Wash", district: "Yakkasaroy", address: "Shota Rustaveli ko'chasi, 21",
    phone: "+998977778899", open_hour: 9, close_hour: 21, bays: 2, featured: true, set: :full,
    description: "Yakkasaroydagi qulay moyka: ichki tozalash va dvigatel yuvish ham bor." },
  { name: "Moyka 24", district: "Shayxontohur", address: "Navoiy ko'chasi, 7",
    phone: "+998909998877", open_hour: 6, close_hour: 23, bays: 5, set: :basic,
    description: "Erta ochiladi, kech yopiladi. 5 post — navbat deyarli bo'lmaydi." },
  { name: "Avto Hammom", district: "Olmazor", address: "Universitet ko'chasi, 4B",
    phone: "+998933332211", open_hour: 8, close_hour: 20, bays: 2, set: :basic,
    description: "Talabalar shaharchasi yaqinida, hamyonbop narxlar." },
  { name: "Shine Servis", district: "Sergeli", address: "Yangi Sergeli ko'chasi, 30",
    phone: "+998901010101", open_hour: 8, close_hour: 22, bays: 3, set: :full,
    description: "Sergeli avtobozori yonida. Kimyoviy tozalash bo'yicha tajribali jamoa." },
  { name: "Delfin Moyka", district: "Yashnobod", address: "Farg'ona yo'li, 112",
    phone: "+998944445566", open_hour: 7, close_hour: 22, bays: 3, set: :basic,
    description: "Farg'ona yo'lidagi keng hududli moyka, yuk mashinalari ham qabul qilinadi." },
  { name: "Mirobod Avto SPA", district: "Mirobod", address: "Afrosiyob ko'chasi, 9",
    phone: "+998971231212", open_hour: 9, close_hour: 21, bays: 2, set: :premium,
    description: "Biznes-klass mashinalar uchun SPA: detailing, polirovka, salon parvarishi." },
  { name: "Uchtepa Wash", district: "Uchtepa", address: "Chilonzor daha, 19-kvartal",
    phone: "+998935671234", open_hour: 8, close_hour: 21, bays: 2, set: :basic,
    description: "Mahalliy, ishonchli va arzon. Doimiy mijozlar uchun 10-yuvish bepul." },
  { name: "Bektemir Avtomoyka", district: "Bektemir", address: "Toshkent halqa yo'li, 3-km",
    phone: "+998909090909", open_hour: 7, close_hour: 22, bays: 4, set: :basic,
    description: "Halqa yo'lida qulay joylashuv, katta mashinalar uchun ham post bor." },
  { name: "Yangihayot Moyka Plus", district: "Yangihayot", address: "Index bozori yoni, 2A",
    phone: "+998933211230", open_hour: 8, close_hour: 22, bays: 3, set: :full,
    description: "Yangihayotdagi eng yangi moyka: zamonaviy uskuna, isitiladigan boks." },

  { name: "SAM Box 24", district: "Chilonzor", address: "Qatortol ko'chasi, 5",
    phone: "+998901112244", open_hour: 0, close_hour: 24, bays: 2, wash_type: "self_service", set: :self_service,
    description: "24/7 ishlaydigan o'zi-o'ziga xizmat ko'rsatish moykasi: ko'pik, shampun va bosim ostidagi suv — o'zingiz yuvasiz, narxi arzon." },
  { name: "Tez Yuv SAM", district: "Sergeli", address: "Yangi Sergeli ko'chasi, 55",
    phone: "+998935556611", open_hour: 6, close_hour: 24, bays: 3, wash_type: "self_service", set: :self_service,
    description: "3 ta mustaqil boks, navbatsiz. O'zingiz yuvib, vaqtingizni tejang." },
  { name: "AutoWash Robot", district: "Yunusobod", address: "Amir Temur shoh ko'chasi, 120",
    phone: "+998901119900", open_hour: 0, close_hour: 24, bays: 1, wash_type: "automatic", set: :automatic,
    description: "To'liq avtomatlashtirilgan portal moyka — 8 daqiqada tayyor, 24/7 ishlaydi, navbat deyarli bo'lmaydi." },
  { name: "Portal Moyka Plus", district: "Mirobod", address: "Nizomiy ko'chasi, 33",
    phone: "+998977712340", open_hour: 7, close_hour: 23, bays: 1, wash_type: "automatic", set: :automatic,
    description: "Zamonaviy tunnel-tipidagi avtomat moyka: kontaktsiz yuvish, quritish bilan." }
]

REVIEWERS = [ "Aziz", "Jasur", "Dilshod", "Malika", "Sardor", "Nodira", "Bekzod", "Kamola", "Ulug'bek", "Shohruh" ]
COMMENTS_GOOD = [
  "Juda sifatli yuvishdi, vaqtida boshladi.",
  "Bron qilib borgandim, kutmasdan qabul qilishdi. Zo'r!",
  "Salon tozalash a'lo darajada. Tavsiya qilaman.",
  "Xodimlar muloyim, ish tez va toza.",
  "Narxiga arziydi, mashina yaltirab ketdi."
]
COMMENTS_MID = [
  "Yaxshi, lekin biroz kutishga to'g'ri keldi.",
  "Sifat yaxshi, faqat ichki tozalash tezroq bo'lsa bo'lardi."
]

# Tumanlar markazining taxminiy koordinatasi (aniq geodeziya emas, yo'nalish uchun yetarli)
DISTRICT_COORDS = {
  "Chilonzor" => [ 41.2856, 69.2034 ], "Yunusobod" => [ 41.3608, 69.2879 ],
  "Mirzo Ulug'bek" => [ 41.3378, 69.3319 ], "Yakkasaroy" => [ 41.2889, 69.2586 ],
  "Shayxontohur" => [ 41.3264, 69.2401 ], "Olmazor" => [ 41.3550, 69.1950 ],
  "Uchtepa" => [ 41.2950, 69.1700 ], "Sergeli" => [ 41.2081, 69.2295 ],
  "Yashnobod" => [ 41.2950, 69.3400 ], "Mirobod" => [ 41.2989, 69.2801 ],
  "Bektemir" => [ 41.2333, 69.3667 ], "Yangihayot" => [ 41.2650, 69.1450 ]
}.freeze

washes = WASHES.map do |attrs|
  set = attrs.delete(:set)
  base_lat, base_lng = DISTRICT_COORDS[attrs[:district]]
  attrs[:latitude] = (base_lat + rand(-0.004..0.004)).round(6)
  attrs[:longitude] = (base_lng + rand(-0.004..0.004)).round(6)
  wash = Wash.create!(attrs)
  pricing_unit = set == :self_service ? "per_minute" : "fixed"
  SERVICE_SETS[set].each do |(name, price, dur)|
    wash.services.create!(name: name, price: price, duration_minutes: dur, pricing_unit: pricing_unit)
  end
  wash
end

# Sharhlar
washes.each do |wash|
  rand(2..6).times do
    good = rand < 0.75
    wash.reviews.create!(
      name: REVIEWERS.sample,
      rating: good ? [ 4, 5, 5 ].sample : 3,
      comment: (good ? COMMENTS_GOOD : COMMENTS_MID).sample,
      created_at: rand(1..60).days.ago
    )
  end
end

# Moyka egalari (panel uchun) — demo parol: moyka123
washes.each_with_index do |wash, i|
  User.create!(
    name: "#{wash.name} egasi",
    phone: format("+9989000000%02d", i + 1),
    password: "moyka123",
    role: :owner,
    wash: wash
  )
end

# Administrator — demo parol: admin123
User.create!(name: "Administrator", phone: "+998900000000", password: "admin123", role: :admin)

# Namuna bronlar (bugun va ertaga)
demo_names = [ [ "Akmal", "+998901111111", "Cobalt, oq" ], [ "Sherzod", "+998902222222", "Gentra, qora" ],
               [ "Lola", "+998903333333", "Spark, kulrang" ], [ "Botir", "+998904444444", "Malibu 2, oq" ] ]
washes.first(4).each_with_index do |wash, i|
  name, phone, car = demo_names[i]
  service = wash.services.first
  slot = format("%02d:00", [ wash.open_hour + 2 + i, wash.close_hour - 1 ].min)
  Booking.create!(
    wash: wash, service: service, date: Date.current + 1, slot: slot,
    customer_name: name, customer_phone: phone, car_model: car,
    status: i.even? ? :yangi : :tasdiqlandi
  )
end

# Mijoz akkauntlari (demo parol: mijoz123)
customers = [
  Customer.create!(name: "Aziz Rahimov", phone: "+998901112200", password: "mijoz123"),
  Customer.create!(name: "Dilnoza Karimova", phone: "+998901112201", password: "mijoz123")
]
customers.first.cars.create!(model: "Cobalt", make: "Chevrolet")
customers.last.cars.create!(model: "Spark", make: "Chevrolet")
customers.last.update!(referred_by: customers.first) # Dilnoza — Azizning taklifi bilan

# Demo promo-kod
PromoCode.create!(code: "MOYKA10", discount_type: :percent, value: 10, usage_limit: 100)

# Bir nechta bajarilgan bron — komissiya paneli bo'sh ko'rinmasligi uchun
washes.first(2).each_with_index do |wash, i|
  customer = customers[i]
  service = wash.services.first
  # Bu "kechagi, allaqachon bajarilgan" bronni ifodalaydi — vaqt o'tib ketgan
  # bo'lishi mumkinligi uchun yaratish tekshiruvlarini o'tkazib yuboramiz.
  booking = wash.bookings.new(
    service: service, date: Date.current, slot: format("%02d:00", wash.open_hour + 1),
    customer_name: customer.name, customer_phone: customer.phone, customer: customer
  )
  booking.save!(validate: false)
  booking.complete!(payment_method: i.even? ? :naqd : :karta)
end

puts "Tayyor: #{Wash.count} moyka, #{Service.count} xizmat, #{Review.count} sharh, #{User.count} foydalanuvchi, " \
     "#{Customer.count} mijoz, #{Car.count} mashina, #{Booking.count} bron, #{PromoCode.count} promo-kod."
