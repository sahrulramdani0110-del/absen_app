import { useEffect, useState } from "react";
import API from "../api/axios";
import Navbar from "../components/Navbar";

export default function Kelas() {
  const [kelas, setKelas] = useState([]);

  useEffect(() => {
    fetchKelas();
  }, []);

  const fetchKelas = async () => {
    try {
      const res = await API.get("/kelas");
      setKelas(res.data);
    } catch (err) {
      console.log(err);
    }
  };

  return (
    <div>
      <Navbar />

      <div className="p-8">
        <h1 className="text-3xl font-bold mb-6">
          Data Kelas
        </h1>

        <div className="grid md:grid-cols-3 gap-4">
          {kelas.map((item) => (
            <div
              key={item.id}
              className="bg-white p-6 rounded-2xl shadow"
            >
              <h2 className="text-xl font-bold">
                {item.name}
              </h2>

              <p className="mt-2 text-gray-600">
                {item.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}