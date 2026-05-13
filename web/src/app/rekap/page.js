"use client";
import { useEffect, useState } from "react";
import { Search } from "lucide-react";
import api from "@/lib/api";

export default function RekapPage() {
  const [sesi, setSesi] = useState([]);
  const [selected, setSelected] = useState(null);
  const [rekap, setRekap] = useState(null);
  const [loading, setLoading] = useState(true);
  const [loadingRekap, setLoadingRekap] = useState(false);

  useEffect(() => {
    api.get("/api/absensi/sesi").then(r => {
      setSesi(r.data);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, []);

  const handleSelect = async (s) => {
    setSelected(s);
    setLoadingRekap(true);
    try {
      const { data } = await api.get(`/api/absensi/sesi/${s.id}/rekap`);
      setRekap(data);
    } catch {}
    setLoadingRekap(false);
  };

  const statusColor = { hadir: "badge-hadir", terlambat: "badge-terlambat", izin: "badge-izin", alpha: "badge-alpha" };

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-ink">Rekap Absensi</h1>
        <p className="text-ink-muted text-sm mt-1">Pilih sesi untuk melihat rekap kehadiran</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* List sesi */}
        <div className="card p-4">
          <h2 className="font-semibold text-ink mb-3 px-2">Pilih Sesi</h2>
          {loading ? (
            <p className="text-ink-muted text-sm px-2">Memuat...</p>
          ) : sesi.length === 0 ? (
            <p className="text-ink-muted text-sm px-2">Belum ada sesi</p>
          ) : (
            <div className="space-y-1">
              {sesi.map(s => (
                <button
                  key={s.id}
                  onClick={() => handleSelect(s)}
                  className={`w-full text-left px-3 py-3 rounded-xl transition-all ${selected?.id === s.id ? "bg-accent-soft" : "hover:bg-ink/5"}`}
                >
                  <p className={`text-sm font-medium ${selected?.id === s.id ? "text-accent" : "text-ink"}`}>{s.title}</p>
                  <p className="text-xs text-ink-muted mt-0.5">{s.kelas_name} · {new Date(s.start_time).toLocaleDateString("id-ID")}</p>
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Detail rekap */}
        <div className="lg:col-span-2">
          {!selected ? (
            <div className="card p-12 text-center h-full flex flex-col items-center justify-center">
              <Search className="w-12 h-12 text-ink/10 mb-3" />
              <p className="text-ink-muted">Pilih sesi dari daftar kiri</p>
            </div>
          ) : loadingRekap ? (
            <div className="card p-12 text-center">
              <p className="text-ink-muted">Memuat rekap...</p>
            </div>
          ) : rekap ? (
            <div className="card p-6">
              <h2 className="font-bold text-ink text-lg mb-1">{selected.title}</h2>
              <p className="text-ink-muted text-sm mb-5">{selected.kelas_name} · {new Date(selected.start_time).toLocaleString("id-ID")}</p>

              {/* Statistik */}
              <div className="grid grid-cols-4 gap-3 mb-6">
                {[
                  { label: "Hadir", val: rekap.rekap.hadir, cls: "bg-success/10 text-success" },
                  { label: "Terlambat", val: rekap.rekap.terlambat, cls: "bg-warning/10 text-warning" },
                  { label: "Izin", val: rekap.rekap.izin, cls: "bg-accent-soft text-accent" },
                  { label: "Alpha", val: rekap.rekap.alpha, cls: "bg-danger/10 text-danger" },
                ].map(({ label, val, cls }) => (
                  <div key={label} className={`rounded-xl p-3 text-center ${cls}`}>
                    <p className="text-2xl font-bold">{val}</p>
                    <p className="text-xs font-medium mt-0.5">{label}</p>
                  </div>
                ))}
              </div>

              {/* Tabel */}
              <div className="overflow-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-ink/5">
                      <th className="text-left py-2 px-3 text-ink-muted font-medium text-xs">Nama</th>
                      <th className="text-left py-2 px-3 text-ink-muted font-medium text-xs">Email</th>
                      <th className="text-left py-2 px-3 text-ink-muted font-medium text-xs">Status</th>
                      <th className="text-left py-2 px-3 text-ink-muted font-medium text-xs">Waktu</th>
                      <th className="text-left py-2 px-3 text-ink-muted font-medium text-xs">Device</th>
                    </tr>
                  </thead>
                  <tbody>
                    {rekap.data.length === 0 ? (
                      <tr><td colSpan={5} className="text-center py-6 text-ink-muted">Belum ada yang absen</td></tr>
                    ) : rekap.data.map((r, i) => (
                      <tr key={i} className="border-b border-ink/5 last:border-0">
                        <td className="py-2.5 px-3 font-medium text-ink">{r.name}</td>
                        <td className="py-2.5 px-3 text-ink-muted">{r.email}</td>
                        <td className="py-2.5 px-3"><span className={statusColor[r.status]}>{r.status}</span></td>
                        <td className="py-2.5 px-3 text-ink-muted font-mono text-xs">{new Date(r.checked_in_at).toLocaleTimeString("id-ID")}</td>
                        <td className="py-2.5 px-3 text-ink-muted capitalize">{r.device_type}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}
