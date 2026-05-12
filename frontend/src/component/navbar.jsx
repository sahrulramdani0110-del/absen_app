import { useNavigate } from "react-router-dom";

export default function Navbar() {
  const navigate = useNavigate();

  const logout = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  return (
    <div className="bg-blue-700 text-white p-4 flex justify-between">
      <h1 className="text-xl font-bold">
        Sistem Absensi Digital
      </h1>

      <button
        onClick={logout}
        className="bg-red-500 px-4 py-2 rounded-xl"
      >
        Logout
      </button>
    </div>
  );
}