"use client";
import { useEffect, useState } from "react";
import { Users, CalendarCheck, Clock, TrendingUp } from "lucide-react";
import api from "@/lib/api";
import { getUser } from "@/lib/auth";

export default function DashboardPage() {
  const [user, setUser] = useState(null);
  const [riwayat, setRiwayat] = useState([]);
  const [sesi, setSesi] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setUser(getUser());
    const fetchData = async () => {
      try {
        const [riwayatRes, sesiRes] = await Promise.all([
          api.get("/api/absensi/riwayat"),
          api.get("/api/absensi/sesi"),
        ]);
        setRiwayat(riwayatRes.data.data || []);
        setSesi(sesiRes.data || []);
      } catch {
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const totalHadir = riwayat.filter((r) => r.status === "hadir").length;
  const totalTerlambat = riwayat.filter((r) => r.status === "terlambat").length;
  const sesiAktif = sesi.filter((s) => s.status === "open").length;
  const persentase = riwayat.length > 0
    ? Math.round(((totalHadir + totalTerlambat) / riwayat.length) * 100)
    : 0;

  const stats = [
    { label: "Total Absensi", value: riwayat.length, icon: CalendarCheck, color: "text-accent bg-accent-soft" },
    { label: "Hadir Tepat Waktu", value: totalHadir, icon: TrendingUp, color: "text-success bg-success/10" },
    { label: "Terlambat", value: totalTerlambat, icon: Clock, color: "text-warning bg-warning/10" },
    { label: "Sesi Aktif", value: sesiAktif, icon: Users, color: "text-ink bg-ink/5" },
  ];

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-ink">
          Halo, {user?.name?.split(" ")[0]} 👋
        </h1>
        <p className="text-ink-muted text-sm mt-1">
          Berikut ringkasan kehadiran kamu
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {stats.map(({ label, value, icon: Icon, color }) => (
          <div key={label} className="card p-5">
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-3 ${color}`}>
              <Icon className="w-5 h-5" />
            </div>
            <p className="text-2xl font-bold text-ink">{loading ? "—" : value}</p>
            <p className="text-xs text-ink-muted mt-0.5">{label}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Kehadiran bar */}
        <div className="card p-6">
          <h2 className="font-semibold text-ink mb-4">Tingkat Kehadiran</h2>
          <div className="flex items-end gap-3 mb-2">
            <span className="text-4xl font-bold text-ink">{persentase}%</span>
            <span className="text-ink-muted text-sm mb-1">dari {riwayat.length} sesi</span>
          </div>
          <div className="w-full bg-ink/5 rounded-full h-3">
            <div
              className="bg-accent h-3 rounded-full transition-all duration-700"
              style={{ width: `${persentase}%` }}
            />
          </div>
          <div className="flex gap-4 mt-4 text-xs text-ink-muted">
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-success inline-block" /> Hadir: {totalHadir}
            </span>
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-warning inline-block" /> Terlambat: {totalTerlambat}
            </span>
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-danger inline-block" /> Alpha: {riwayat.filter(r => r.status === "alpha").length}
            </span>
          </div>
        </div>

        {/* Riwayat terbaru */}
        <div className="card p-6">
          <h2 className="font-semibold text-ink mb-4">Riwayat Terbaru</h2>
          {loading ? (
            <p className="text-ink-muted text-sm">Memuat...</p>
          ) : riwayat.length === 0 ? (
            <p className="text-ink-muted text-sm">Belum ada riwayat absensi</p>
          ) : (
            <div className="space-y-3">
              {riwayat.slice(0, 5).map((r, i) => (
                <div key={i} className="flex items-center justify-between py-2 border-b border-ink/5 last:border-0">
                  <div>
                    <p className="text-sm font-medium text-ink">{r.title}</p>
                    <p className="text-xs text-ink-muted">{r.kelas_name} · {new Date(r.checked_in_at).toLocaleDateString("id-ID")}</p>
                  </div>
                  <span className={`badge-${r.status}`}>{r.status}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
