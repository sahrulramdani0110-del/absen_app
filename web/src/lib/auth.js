import Cookies from "js-cookie";

export const getUser = () => {
  try {
    const user = Cookies.get("user");
    return user ? JSON.parse(user) : null;
  } catch {
    return null;
  }
};

export const getToken = () => Cookies.get("token") || null;

export const setAuth = (token, user) => {
  Cookies.set("token", token, { expires: 7 });
  Cookies.set("user", JSON.stringify(user), { expires: 7 });
};

export const clearAuth = () => {
  Cookies.remove("token");
  Cookies.remove("user");
};

export const isLoggedIn = () => !!getToken();
