import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api from '../apis/axiosInstance';

interface User {
  id: number;
  username: string;
  fullName: string;
  roleCode: string;
}

interface MenuItem {
  code: string;
  name: string;
  icon: string;
  route: string;
  sortOrder: number;
}

interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  menus: MenuItem[];
  setAuth: (user: User, accessToken: string, refreshToken: string) => void;
  fetchMenus: () => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      menus: [],

      setAuth: (user, accessToken, refreshToken) => 
        set({ user, accessToken, refreshToken }),

      fetchMenus: async () => {
        try {
          const res = await api.get('/menu');
          if (res.data?.isSuccess) {
            set({ menus: res.data.data });
          }
        } catch {
          // fallback: keep existing menus
        }
      },

      logout: () => {
        localStorage.clear();
        set({ user: null, accessToken: null, refreshToken: null, menus: [] });
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        menus: state.menus,
      }),
    }
  )
);
