

# Real-Time Chat System

Aplikasi *real-time chat* berskala produksi yang dibangun menggunakan kombinasi bertenaga **Elixir** dan **Phoenix Framework**. Proyek ini memanfaatkan mesin virtual **BEAM** untuk menangani jutaan koneksi *WebSocket* secara bersamaan dengan penggunaan memori yang sangat hemat, menjadikannya sangat stabil, cepat, dan tahan banting (*fault-tolerant*).

---

##  Penjelasan Detail Fitur  

Berikut adalah rincian fungsionalitas dari setiap fitur yang telah diimplementasikan secara penuh di dalam kode program backend dan frontend proyek ini:

### 1. Autentikasi & Keamanan Tingkat Lanjut
* **Pendaftaran & Login Akun:** Sistem registrasi menggunakan validasi keunikan email dan username. Kata sandi di-hashing menggunakan algoritma `Bcrypt` sebelum disimpan ke database PostgreSQL demi keamanan data pengguna.
* **Kunci Aplikasi (PIN Lock):** Fitur proteksi lapis kedua menggunakan PIN 6-digit yang terenkripsi di sisi backend (`pin_lock_hash`). Aplikasi akan mengunci antarmuka chat sebelum PIN yang benar dimasukkan oleh pengguna.
* **Sistem Blokir Pengguna:** Pengguna dapat memasukkan ID kontak lain ke dalam daftar `blocked_users`. Di sisi backend, sistem akan memvalidasi status blokir ini untuk mencegah pengiriman pesan di antara kedua pengguna tersebut.

### 2. Komunikasi & Arsitektur Real-Time
* **Koneksi WebSocket Phoenix Channels:** Jantung dari aplikasi ini. Membuka jalur pipa komunikasi persisten berlatensi sangat rendah (di bawah beberapa milidetik) antara klien dan server tanpa perlu melakukan *polling* HTTP berulang-ulang.
* **Pelacakan Kehadiran (Presence Status):** Memanfaatkan modul `Phoenix.Presence` yang berjalan di memori server (tanpa membebani database SQL). Status online/offline pengguna langsung didistribusikan ke seluruh rekan chat secara instan saat aplikasi dibuka atau ditutup.
* **Indikator Mengetik (Typing Indicator):** Menyiarkan sinyal interaktif dari satu pengguna ke pengguna lain di dalam ruangan chat yang sama saat mendeteksi adanya aktivitas input pada kolom pesan teks, menampilkan status *"X sedang mengetik..."*.
* **Sistem Status Pengiriman Pesan (Centang):** * **Centang 1 (Sent):** Pesan berhasil masuk dan tersimpan di database server.
    * **Centang 2 (Delivered):** Server mendeteksi perangkat tujuan sedang online dan mengirimkan sinyal ke pengirim.
    * **Centang Biru (Read):** Sinyal dipicu saat pengguna tujuan membuka ruang obrolan dan membaca pesan terkait.

### 3. Manipulasi & Logika Pesan
* **Pesan Teks Biasa:** Mengakomodasi pengiriman teks mentah, multi-baris, karakter khusus, hingga rendering emoji secara native.
* **Balas Pesan (Reply Chat):** Pengguna dapat mengutip isi pesan lama melalui pengisian kolom `reply_to_id`. Antarmuka akan menampilkan visualisasi kotak kutipan di atas pesan baru.
* **Teruskan Pesan (Forward Message):** Mengambil objek data pesan yang sudah ada dan menduplikasinya ke `room_id` lain tanpa mengubah isi pesan asli.
* **Ubah Pesan Terkirim (Edit Message):** Mengizinkan pengirim memperbarui teks pesan yang telah masuk ke database selama status pesan tersebut belum dihapus oleh sistem.
* **Tarik Pesan untuk Semua Orang (Delete for Everyone):** Mengubah status kolom `is_deleted` menjadi `true` di database. Isi teks asli, tautan gambar, serta suara akan dihapus secara permanen dari database dan digantikan dengan teks default *"Pesan ini telah dihapus"*.
* **Pencarian Riwayat Pesan:** Melakukan pencarian teks berbasis klausa `ilike` di database PostgreSQL untuk mencocokkan kata kunci tertentu di dalam suatu ruangan chat secara cepat dan efisien.

### 4. Manajemen Grup, Saluran, & Media
* **Pembuatan Kamar & Grup:** Sistem memisahkan tipe kamar menjadi `private` (1-on-1), `group` (grup multi-user), dan `broadcast` (saluran searah).
* **Hak Akses Admin Grup:** Anggota pembuat grup otomatis mendapatkan peran (`role`) sebagai `admin`. Hanya admin yang memiliki otoritas untuk memanggil fungsi penambahan anggota baru ke dalam grup.
* **Undangan Lewat Tautan Unik:** Saat grup dibuat, backend menghasilkan kode token heksadesimal acak yang unik (`unique_link`). Pengguna luar dapat bergabung ke dalam grup hanya dengan mengakses tautan tersebut.
* **Unggah Multimedia & Pesan Suara:** REST API multipart di `MediaController` memproses pengunggahan file fisik, memvalidasi ekstensi berkas, menyimpannya di direktori penyimpanan lokal `/priv/static/uploads/`, lalu mengembalikan URL publiknya. Tipe media otomatis dikategorikan menjadi `image`, `voice` (rekaman suara), atau `document` (PDF/Word).

### 5. Integrasi Pintar & Antarmuka Modern
* **Penerjemah Bahasa Otomatis:** Saat menerima pesan berbahasa asing, backend dapat meneruskan teks tersebut secara asinkron lewat `Task` Elixir ke API eksternal (seperti LibreTranslate) dan mengembalikan hasil terjemahan langsung ke layar pengguna tanpa interupsi.
* **Otomatisasi Asisten Bot:** Sistem menyediakan bot internal (ID: `0`) yang bertindak sebagai pemantau kata kunci. Pengguna bisa mengetik perintah khusus seperti `/help`, `/info`, atau `/waktu`, dan bot akan langsung mengirimkan balasan real-time ke dalam ruangan chat tersebut.
* **Phoenix LiveView & Tema Dark Mode:** Antarmuka pengguna dibangun secara reaktif langsung dari backend menggunakan LiveView. Logika penggantian tema *Dark Mode* ditangani lewat modifikasi status *state* `dark_mode: true/false` yang secara instan merender class CSS yang sesuai pada browser pengguna tanpa perlu menulis script JavaScript tambahan.

---

## InStallasi 
```
mix deps.get
mix ecto.setup => Buka file config/dev.exs dan sesuaikan nama username serta password PostgreSQL sesuai dengan konfigurasi database lokal di komputermu. Setelah itu, buat dan jalankan migrasi database dengan perintah:
mix ecto.setup -> Perintah ini akan otomatis membuat database mr_rm19_chat_dev dan menyusun seluruh tabel SQL (users, rooms, members, messages) secara nyata.
mix compile

mix phx.server 
Atau jika kamu ingin masuk ke dalam terminal interaktif Elixir (IEx) sambil menjalankan server, gunakan:

iex -S mix phx.server
Setelah server menyala, aplikasi web interaktif LiveView dapat langsung diakses melalui browser di alamat:
Antarmuka Chat Utama (LiveView): http://localhost:4000/chat

Kamu bisa menggunakan aplikasi seperti Postman atau Insomnia untuk menguji endpoint REST API berikut:

Registrasi Akun: POST http://localhost:4000/api/register (Kirim payload: username, email, password)

Login Akun: POST http://localhost:4000/api/login (Kirim payload: email, password -> Akan mengembalikan token WebSocket JWT)

Unggah Media: POST http://localhost:4000/api/upload (Kirim file via form-data dengan key: file)
```
## Author
Mr.Rm19 - ramdan19id@gmail.com - github.com/Rm19x
