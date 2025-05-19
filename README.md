# fam_planner

# 🧹 Pametni Gospodinjski Planer

Mobilna Flutter aplikacija, namenjena organizaciji vsakdanjih gospodinjskih opravil, dogodkov, nakupov in članov gospodinjstva. Projekt v fazi razvoja, osredotočen na MVP (Minimal Viable Product), ki omogoča lokalno delovanje brez uporabniških računov.

---

## 🚀 Namen aplikacije

Aplikacija pomaga:

- Upravljati vsakodnevna in čistilna opravila
- Organizirati dogodke v gospodinjstvu
- Voditi skupni nakupovalni seznam
- Porazdeliti naloge med člane gospodinjstva

---

## 🧩 Ključne funkcionalnosti (MVP)

- ✅ Dnevna opravila / To-do lista
- ✅ Čistilna opravila po prostorih
- ✅ Skupni koledar dogodkov
- ✅ Nakupovalni seznam
- ✅ Člani gospodinjstva brez prijave
- ✅ Dark mode (ročno)
- ✅ Podpora za več jezikov (privzeto slovenščina)

---

## 🏗️ Tehnologija in struktura

### 📱 Platforma

- **Flutter** (Android, iOS, možnost kasnejše spletne različice)

### 💾 Podatkovna shramba

- MVP: **Hive** ali **SQLite** (lokalno)
- Pripravljeno za nadgradnjo na **Firebase**

### 🧠 Arhitektura

- Arhitekturni vzorec: **MVVM**
- **Riverpod** kot upravljalec stanja
- Dobra organizacija: `lib/screens`, `lib/widgets`, `lib/models`, `lib/services`
- Priporočeno: **dependency injection**

---

## 📦 Modeli (osnovne entitete)

```dart
class HouseholdMember {
  final String id;
  final String name;
  final Color color;
}

class Task {
  final String id;
  final String title;
  final String room;
  final String? assignedTo;
  final DateTime dueDate;
  final bool isRecurring;
  final bool isDone;
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String? assignedTo;
}

class ShoppingItem {
  final String id;
  final String name;
  final bool isBought;
  final String? addedBy;
}
```

---

## 🖥️ Uporabniški vmesnik

### Glavni zasloni:

- Home Dashboard
- Čistilna opravila
- Koledar
- Nakupovalni seznam
- Uporabniški profili
- Onboarding navodila

---

## 🧪 Varnostno kopiranje (Backup)

- Ročni izvoz/uvoz `.json` datotek
- Možnost lokalnega avtomatskega backupa
- Pripravljeno za prihodnjo sinhronizacijo

---

## 🛣️ Roadmap

### ✅ Faza 1 – MVP (lokalna uporaba)
- Osnovne funkcionalnosti + dark mode
- Slovenski jezik
- Lokalna shramba (Hive/SQLite)

### 🧪 Faza 2 – Nadgradnje lokalne uporabe
- Prioritizacija opravil
- Filtri in iskalnik
- Lokalna obvestila (notifikacije)
- Skupinsko urejanje seznama
- Statistika in grafi

### 🌐 Faza 3 – Sinhronizacija v oblak
- Firebase: prijava, sinhronizacija, push obvestila
- Več uporabnikov / naprav

### 🤖 Faza 4 – Pametne funkcije
- AI predlogi
- Sinhronizacija z Google/Apple koledarjem
- Govorni pomočniki

### 💰 Faza 5 – Monetizacija
- Angleška različica
- Premium funkcije (sinhronizacija, napredna statistika)
- PWA ali spletna verzija

---

## 📘 Dobre prakse

- Uporaba Gita za verzioniranje (smiselni commit-i, opisi)
- Komentiranje zahtevnih delov kode
- Sledenje arhitekturnim vzorcem in standardom
- Pripravljeno za testiranje in nadgradnjo

---

## 🌐 Večjezičnost (i18n)

- Privzeto: **slovenščina**
- Pripravljeno: `easy_localization` ali `intl`
- Kasneje: angleščina (`en.json`)

---

## 📄 Licenca

Projekt je trenutno v fazi razvoja. Licenca in pogoji bodo določeni ob javni izdaji.

---
