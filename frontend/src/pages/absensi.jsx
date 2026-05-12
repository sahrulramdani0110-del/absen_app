import Navbar from "../components/Navbar";

export default function Absensi() {
  return (
    <div>
      <Navbar />

      <div className="p-8">
        <h1 className="text-3xl font-bold mb-6">
          Halaman Absensi
        </h1>

        <div className="bg-white p-6 rounded-2xl shadow">
          <p>
            Di halaman ini nanti bisa:
          </p>

          <ul className="list-disc ml-6 mt-3">
            <li>Buka sesi absensi</li>
            <li>Check-in lokasi GPS</li>
            <li>Upload foto</li>
            <li>Rekap kehadiran</li>
          </ul>
        </div>
      </div>
    </div>
  );
}