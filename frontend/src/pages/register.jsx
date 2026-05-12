import { useState } from "react";
import { useNavigate, Link } from "react-router-dom"; // ✅ perbaikan: import Link
import API from "../api/axios";

export default function Register() {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    name: "",
    email: "",
    password: "",
    role: "member",
  });

  const handleRegister = async (e) => {
    e.preventDefault();

    try {
      await API.post("/auth/register", form);
      alert("Register berhasil");
      navigate("/login");
    } catch (err) {
      alert(err.response?.data?.message || "Register gagal");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-100">
      <form
        onSubmit={handleRegister}
        className="bg-white p-8 rounded-2xl shadow-lg w-[400px]"
      >
        <h1 className="text-3xl font-bold mb-6 text-center">Register</h1>

        <input
          type="text"
          placeholder="Nama"
          className="w-full border p-3 rounded-xl mb-4"
          value={form.name}
          onChange={(e) => setForm({ ...form, name: e.target.value })}
        />

        <input
          type="email"
          placeholder="Email"
          className="w-full border p-3 rounded-xl mb-4"
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
        />

        <input
          type="password"
          placeholder="Password"
          className="w-full border p-3 rounded-xl mb-4"
          value={form.password}
          onChange={(e) => setForm({ ...form, password: e.target.value })}
        />

        {/* Opsional: pilihan role */}
        <select
          className="w-full border p-3 rounded-xl mb-4"
          value={form.role}
          onChange={(e) => setForm({ ...form, role: e.target.value })}
        >
          <option value="member">Member</option>
          <option value="admin">Admin</option>
        </select>

        <button className="w-full bg-green-600 text-white p-3 rounded-xl">
          Register
        </button>

        <p className="text-center mt-4">
          Sudah punya akun? <Link to="/login">Login</Link>
        </p>
      </form>
    </div>
  );
}