"use client";
import { useEffect, useState } from "react";
import { Plus, Users, ChevronDown, ChevronUp, Trash2, X } from "lucide-react";
import toast from "react-hot-toast";
import api from "@/lib/api";

export default function KelasPage() {
  const [kelas, setKelas] = useState([]);
  const [organisasi, setOrganisasi] = useState([]);
  const [expanded, setExpanded] = useState(null);
  const [anggota, setAnggota] = useState({});
  const [modalKelas, setModalKelas] = useState(false);
  const [modalOrg, setModalOrg] = useState(false);
  const [modalAnggota, setModalAnggota] = useState(null);
  const [loading, setLoading] = useState(true);

  const [formKelas, setFormKelas] = useState({ org_id: "", name: "", description: "" });
  const [formOrg, setFormOrg] = useState({ name: "", address: "" });
  const [formAnggota, setFormAnggota] = useState({ user_id: "", role: "member" });

  const fetchKelas = () => api.get("/api/kelas").then(r => setKelas(r.data)).catch(() => {});

  useEffect(() => {
    Promise.all([
      fetchKelas(),
      api.get("/api/organisasi").then(r => setOrganisasi(r.data)).catch(() => {}),
    ]).finally(() => setLoading(false));
  }, []);

  const toggleExpand = async (id) => {
    if (expanded === id) { setExpanded(null); return; }
    setExpanded(id);
    if (!anggota[id]) {
      try {
        const { data } = await api.get(`/api/kelas/${id}/anggota`);
        setAnggota(a => ({ ...a, [id]: data.data }));
      } catch {}
    }
  };

  const handleBuatOrg = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/organisasi", formOrg);
      toast.success("Organisasi dibuat!");
      setModalOrg(false);
      setFormOrg({ name: "", address: "" });
      const { data } = await api.get("/api/organisasi");
      setOrganisasi(data);
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal");
    }
  };

  const handleBuatKelas = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/kelas", formKelas);
      toast.success("Kelas dibuat!");
      setModalKelas(false);
      setFormKelas({ org_id: "", name: "", description: "" });
      fetchKelas();
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal");
    }
  };

  const handleTambahAnggota = async (e) => {
    e.preventDefault();
    try {
      await api.post(`/api/kelas/${modalAnggota}/anggota`, formAnggota);
      toast.success("Anggota ditambahkan!");
      setModalAnggota(null);
      setFormAnggota({ user_id: "", role: "member" });
      const { data } = await api.get(`/api/kelas/${modalAnggota}/anggota`);
      setAnggota(a => ({ ...a, [modalAnggota]: data.data }));
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal");
    }
  };

  const handleHapusAnggota = async (kelasId, userId) => {
    if (!confirm("Hapus anggota ini?")) return;
    try {
      await api.delete(`/api/kelas/${kelasId}/anggota/${userId}`);
      toast.success("Anggota dihapus");
      setAnggota(a => ({ ...a, [kelasId]: a[kelasId].filter(m => m.id !== userId) }));
    } catch (err) {
      toast.error(err.response?.data?.message || "Gagal");
    }
  };

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-ink">Manajemen Kelas</h1>
          <p className="text-ink-muted text-sm mt-1">Kelola kelas dan anggota</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setModalOrg(true)} className="btn-secondary flex items-center gap-2 text-sm">
            <Plus className="w-4 h-4" /> Organisasi
          </button>
          <button onClick={() => setModalKelas(true)} className="btn-primary flex items-center gap-2 text-sm">
            <Plus className="w-4 h-4" /> Kelas
          </button>
        </div>
      </div>

      {loading ? (
        <p className="text-ink-muted">Memuat...</p>
      ) : kelas.length === 0 ? (
        <div className="card p-12 text-center">
          <Users className="w-12 h-12 text-ink/10 mx-auto mb-3" />
          <p className="text-ink-muted">Belum ada kelas. Buat kelas pertama kamu!</p>
        </div>
      ) : (
        <div className="space-y-3">
          {kelas.map(k => (
            <div key={k.id} className="card overflow-hidden">
              <div
                className="flex items-center justify-between p-5 cursor-pointer hover:bg-ink/[0.02]"
                onClick={() => toggleExpand(k.id)}
              >
                <div>
                  <h3 className="font-semibold text-ink">{k.name}</h3>
                  <p className="text-xs text-ink-muted mt-0.5">{k.org_name} {k.description && `· ${k.description}`}</p>
                </div>
                <div className="flex items-center gap-3">
                  <button
                    onClick={e => { e.stopPropagation(); setModalAnggota(k.id); }}
                    className="btn-secondary text-xs py-1.5 px-3 flex items-center gap-1"
                  >
                    <Plus className="w-3 h-3" /> Anggota
                  </button>
                  {expanded === k.id ? <ChevronUp className="w-4 h-4 text-ink-muted" /> : <ChevronDown className="w-4 h-4 text-ink-muted" />}
                </div>
              </div>

              {expanded === k.id && (
                <div className="border-t border-ink/5 px-5 pb-5">
                  {!anggota[k.id] ? (
                    <p className="text-ink-muted text-sm pt-4">Memuat anggota...</p>
                  ) : anggota[k.id].length === 0 ? (
                    <p className="text-ink-muted text-sm pt-4">Belum ada anggota</p>
                  ) : (
                    <table className="w-full text-sm mt-4">
                      <thead>
                        <tr className="border-b border-ink/5">
                          <th className="text-left py-2 text-ink-muted font-medium text-xs">Nama</th>
                          <th className="text-left py-2 text-ink-muted font-medium text-xs">Email</th>
                          <th className="text-left py-2 text-ink-muted font-medium text-xs">Role</th>
                          <th className="text-left py-2 text-ink-muted font-medium text-xs">Bergabung</th>
                          <th />
                        </tr>
                      </thead>
                      <tbody>
                        {anggota[k.id].map(m => (
                          <tr key={m.id} className="border-b border-ink/5 last:border-0">
                            <td className="py-2.5 font-medium text-ink">{m.name}</td>
                            <td className="py-2.5 text-ink-muted">{m.email}</td>
                            <td className="py-2.5 capitalize text-ink-muted">{m.role}</td>
                            <td className="py-2.5 text-ink-muted text-xs">{new Date(m.joined_at).toLocaleDateString("id-ID")}</td>
                            <td className="py-2.5 text-right">
                              <button
                                onClick={() => handleHapusAnggota(k.id, m.id)}
                                className="text-ink-muted hover:text-danger transition-colors"
                              >
                                <Trash2 className="w-4 h-4" />
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Modal Organisasi */}
      {modalOrg && (
        <div className="fixed inset-0 bg-ink/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="font-bold text-ink text-lg">Buat Organisasi</h2>
              <button onClick={() => setModalOrg(false)}><X className="w-5 h-5 text-ink-muted" /></button>
            </div>
            <form onSubmit={handleBuatOrg} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Nama Organisasi</label>
                <input className="input" placeholder="cth: SMK Negeri 1 Bandung" value={formOrg.name} onChange={e => setFormOrg(f => ({ ...f, name: e.target.value }))} required />
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Alamat (opsional)</label>
                <input className="input" placeholder="Alamat organisasi" value={formOrg.address} onChange={e => setFormOrg(f => ({ ...f, address: e.target.value }))} />
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setModalOrg(false)} className="btn-secondary flex-1">Batal</button>
                <button type="submit" className="btn-primary flex-1">Buat</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Kelas */}
      {modalKelas && (
        <div className="fixed inset-0 bg-ink/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="font-bold text-ink text-lg">Buat Kelas</h2>
              <button onClick={() => setModalKelas(false)}><X className="w-5 h-5 text-ink-muted" /></button>
            </div>
            <form onSubmit={handleBuatKelas} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Organisasi</label>
                <select className="input" value={formKelas.org_id} onChange={e => setFormKelas(f => ({ ...f, org_id: e.target.value }))} required>
                  <option value="">Pilih organisasi</option>
                  {organisasi.map(o => <option key={o.id} value={o.id}>{o.name}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Nama Kelas</label>
                <input className="input" placeholder="cth: XII RPL 1" value={formKelas.name} onChange={e => setFormKelas(f => ({ ...f, name: e.target.value }))} required />
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Deskripsi (opsional)</label>
                <input className="input" placeholder="Deskripsi kelas" value={formKelas.description} onChange={e => setFormKelas(f => ({ ...f, description: e.target.value }))} />
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setModalKelas(false)} className="btn-secondary flex-1">Batal</button>
                <button type="submit" className="btn-primary flex-1">Buat Kelas</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Tambah Anggota */}
      {modalAnggota && (
        <div className="fixed inset-0 bg-ink/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="font-bold text-ink text-lg">Tambah Anggota</h2>
              <button onClick={() => setModalAnggota(null)}><X className="w-5 h-5 text-ink-muted" /></button>
            </div>
            <form onSubmit={handleTambahAnggota} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">User ID</label>
                <input type="number" className="input" placeholder="ID user yang akan ditambahkan" value={formAnggota.user_id} onChange={e => setFormAnggota(f => ({ ...f, user_id: e.target.value }))} required />
                <p className="text-xs text-ink-muted mt-1">Cek ID user dari database atau response register</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-ink mb-1.5">Role</label>
                <select className="input" value={formAnggota.role} onChange={e => setFormAnggota(f => ({ ...f, role: e.target.value }))}>
                  <option value="member">Member</option>
                  <option value="leader">Leader</option>
                </select>
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setModalAnggota(null)} className="btn-secondary flex-1">Batal</button>
                <button type="submit" className="btn-primary flex-1">Tambah</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
