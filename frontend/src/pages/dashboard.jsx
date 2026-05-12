import Navbar from "../components/Navbar";

export default function Dashboard() {
  return (
    <div>
      <Navbar />

      <div className="p-8">
        <h1 className="text-4xl font-bold mb-4">
          Dashboard Absensi
        </h1>

        <div className="grid md:grid-cols-3 gap-4">
          <div className="bg-white p-6 rounded-2xl shadow">
            <h2 className="text-xl font-bold">Total Kelas</h2>
            <p className="text-4xl mt-3">12</p>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow">
            <h2 className="text-xl font-bold">Sesi Hari Ini</h2>
            <p className="text-4xl mt-3">5</p>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow">
            <h2 className="text-xl font-bold">Hadir</h2>
            <p className="text-4xl mt-3">89%</p>
          </div>
        </div>
      </div>
    </div>
  );
}