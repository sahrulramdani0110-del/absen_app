"use client";
import { useEffect, useState } from "react";
import { Plus, MapPin, Clock, CheckCircle, X } from "lucide-react";
import toast from "react-hot-toast";
import api from "@/lib/api";
import { getUser } from "@/lib/auth";

export default function AbsensiPage() {
  const [user, setUser] = useState(null);
  const [sesi, setSesi] = useState([]);
  const [kelas, setKelas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modalBuka, setModalBuka] = useState(false);
  const [modalCheckin, setModalCheckin] = useState(null);
  const [locating, setLocating] = useState(false);

  const [formSesi, setFormSesi] = useState({
    kelas_id: "", title: "", start_time: "",
    latitude: "", longitude: "", radius_meters: 100,
  });
  const [formCheckin, setFormCheckin] = useState({
    session_id: "", latitude: "", longitude: "", device_type: "web",
  });

  const fetchSesi = async () => {
    try {
      const { data } = await api.get("/api/absensi/sesi");
      setSesi(data);
    } catch {}
  };

  useEffect(() => {
    setUser(getUser());
    const init = async () => {
      await Promise.all([
        fetchSesi(),
        api.get("/api/kelas").then(r => setKelas(r.data)).catch(() => {}),
      ]);
      setLoading(false);
    };
    init();
  }, []);

  const getLocation = (target) => {
    setLocating(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const coords = { latitude: pos.coords.latitude, longitude: pos.coords.longitude };
        if (target === "sesi") setFormSesi(f => ({ ...f, ...coords }));
        else setFormCheckin(f => ({ ...f, ...coords }));
        toast.success("Lokasi berhasil didapat");
        setLocating(false);
      },
      () => { toast.error("Gagal mendapat lokasi"); setLocating(false); }
    );
  };

  const handleBukaSesi = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/absensi/sesi", formSesi);
      toast.success("Sesi absensi dibuka!");
      setModalBuka(false);
      setFormSesi({ kelas_id: "", title: "", start_time: "", latitude: "", longitude: "", radius_meters: 100 });
      fetchSesi();
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal membuka sesi");
    }
  };

  const handleCheckin = async (e) => {
    e.preventDefault();
    try {
      const { data } = await api.post("/api/absensi/checkin", formCheckin);
      toast.success(`Absensi berhasil — ${data.status}!`);
      setModalCheckin(null);
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal absen");
    }
  };

  const handleTutupSesi = async (id) => {
    if (!confirm("Tutup sesi ini?")) return;
    try {
      await api.patch(`/api/absensi/sesi/${id}/tutup`);
      toast.success("Sesi ditutup");
      fetchSesi();
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal menutup sesi");
    }
  };

  const openCheckin = (s) => {
    setFormCheckin({ session_id: s.id, latitude: "", longitude: "", device_type: "web" });
    setModalCheckin(s);
  };

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-ink">Absensi</h1>
          <p className="text-ink-muted text-sm mt-1">Kelola sesi dan lakukan check-in</p>
        </div>
        {user?.role === "admin" && (
          <button onClick={() => setModalBuka(true)} className="btn-primary flex items-center gap-2">
            <Plus className="w-4 h-4" /> Buka Sesi
          </button>
        )}
      </div>

      {/* Daftar sesi */}
      {loading ? (
        <p className="text-ink-muted">Memuat sesi...</p>
      ) : sesi.length === 0 ? (
        <div className="card p-12 text-center">
          <CalendarIcon className="w-12 h-12 text-ink/10 mx-auto mb-3" />
          <p className="text-ink-muted">Belum ada sesi absensi</p>
        </div>
      ) : (
        <div className="grid gap-4">
          {sesi.map((s) => (
            <div key={s.id} className="card p-5 flex items-center justify-between">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-ink">{s.title}</h3>
                  <span className={`badge-${s.status}`}>{s.status === "open" ? "Terbuka" : "Ditutup"}</span>
                </div>
                <p className="text-xs text-ink-muted">{s.kelas_name}</p>
                <div className="flex items-center gap-4 mt-2 text-xs text-ink-muted">
                  <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3" />
                    {new Date(s.start_time).toLocaleString("id-ID")}
                  </span>
                  {s.latitude && (
                    <span className="flex items-center gap-1">
                      <MapPin className="w-3 h-3" /> GPS aktif · radius {s.radius_meters}m
                    </span>
                  )}
                </div>
              </div>
              <div className="flex items-center gap-2 ml-4">
                {s.status === "open" && (
                  <>
                    <button
                      onClick={() => openCheckin(s)}
                      className="btn-primary text-sm py-2 px-4 flex items-center gap-1.5"
                    >
                      <CheckCircle className="w-4 h-4" /> Absen
                    </button>
                    {user?.role === "admin" && (
                      <button
                        onClick={() => handleTutupSesi(s.id)}
                        className="btn-danger text-sm py-2 px-4"
                      >
                        Tutup
                      </button>
                    )}
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal Buka Sesi */}
      {modalBuka && (
        <div className="fixed inset-0 bg-ink/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="font-bold text-ink text-lg">Buka Sesi Absensi</h2>
              <button onClick={() => setModalBuka(false)} className="text-ink-muted hover:text-ink">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={handleBukaSesi} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Kelas</label>
                <select className="input" value={formSesi.kelas_id} onChange={e => setFormSesi(f => ({ ...f, kelas_id: e.target.value }))} required>
                  <option value="">Pilih kelas</option>
                  {kelas.map(k => <option key={k.id} value={k.id}>{k.name}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Judul Sesi</label>
                <input type="text" className="input" placeholder="cth: Absensi Senin Pagi" value={formSesi.title} onChange={e => setFormSesi(f => ({ ...f, title: e.target.value }))} required />
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Waktu Mulai</label>
                <input type="datetime-local" className="input" value={formSesi.start_time} onChange={e => setFormSesi(f => ({ ...f, start_time: e.target.value }))} required />
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Radius (meter)</label>
                <input type="number" className="input" value={formSesi.radius_meters} onChange={e => setFormSesi(f => ({ ...f, radius_meters: e.target.value }))} />
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Lokasi (opsional)</label>
                <button type="button" onClick={() => getLocation("sesi")} className="btn-secondary text-sm flex items-center gap-2">
                  <MapPin className="w-4 h-4" /> {locating ? "Mendapat lokasi..." : formSesi.latitude ? `${Number(formSesi.latitude).toFixed(4)}, ${Number(formSesi.longitude).toFixed(4)}` : "Gunakan Lokasi Saat Ini"}
                </button>
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setModalBuka(false)} className="btn-secondary flex-1">Batal</button>
                <button type="submit" className="btn-primary flex-1">Buka Sesi</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Check-in */}
      {modalCheckin && (
        <div className="fixed inset-0 bg-ink/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="font-bold text-ink text-lg">Check-in Absensi</h2>
              <button onClick={() => setModalCheckin(null)} className="text-ink-muted hover:text-ink">
                <X className="w-5 h-5" />
              </button>
            </div>
            <p className="text-sm text-ink-muted mb-4">Sesi: <span className="font-medium text-ink">{modalCheckin.title}</span></p>
            <form onSubmit={handleCheckin} className="space-y-4">
              {modalCheckin.latitude && (
                <div>
                  <label className="block text-sm font-medium text-ink mb-1.5">Lokasi Saya</label>
                  <button type="button" onClick={() => getLocation("checkin")} className="btn-secondary text-sm flex items-center gap-2 w-full justify-center">
                    <MapPin className="w-4 h-4" />
                    {locating ? "Mendapat lokasi..." : formCheckin.latitude ? `${Number(formCheckin.latitude).toFixed(4)}, ${Number(formCheckin.longitude).toFixed(4)}` : "Ambil Lokasi Sekarang"}
                  </button>
                  <p className="text-xs text-ink-muted mt-1">Sesi ini memerlukan validasi GPS</p>
                </div>
              )}
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setModalCheckin(null)} className="btn-secondary flex-1">Batal</button>
                <button type="submit" className="btn-primary flex-1 flex items-center justify-center gap-2">
                  <CheckCircle className="w-4 h-4" /> Absen Sekarang
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

function CalendarIcon({ className }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
    </svg>
  );
}
