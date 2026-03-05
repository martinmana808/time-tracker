import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { Project, TimeEntry, ActiveTimer } from '../types';

interface TimerState {
  projects: Project[];
  timeEntries: TimeEntry[];
  activeTimer: ActiveTimer | null;
  
  // Project actions
  addProject: (project: Omit<Project, 'id' | 'createdAt'>) => void;
  updateProject: (id: string, updates: Partial<Project>) => void;
  deleteProject: (id: string) => void;

  // Active Timer actions
  startTimer: (projectId: string, description: string) => void;
  stopTimer: () => void;
  updateActiveTimer: (updates: Partial<ActiveTimer>) => void;

  // Time Entry actions
  addTimeEntry: (entry: Omit<TimeEntry, 'id'>) => void;
  deleteTimeEntry: (id: string) => void;
}

export const useTimerStore = create<TimerState>()(
  persist(
    (set) => ({
      projects: [],
      timeEntries: [],
      activeTimer: null,

      addProject: (project) => set((state) => ({ 
        projects: [...state.projects, { 
          ...project, 
          id: crypto.randomUUID(), 
          createdAt: Date.now() 
        }] 
      })),
      
      updateProject: (id, updates) => set((state) => ({
        projects: state.projects.map((p) => p.id === id ? { ...p, ...updates } : p)
      })),
      
      deleteProject: (id) => set((state) => ({
        projects: state.projects.filter((p) => p.id !== id)
      })),

      startTimer: (projectId, description) => set({
        activeTimer: { projectId, description, startTime: Date.now() }
      }),
      
      stopTimer: () => set((state) => {
        if (!state.activeTimer || !state.activeTimer.startTime || !state.activeTimer.projectId) {
          return { activeTimer: null };
        }
        
        const newEntry: TimeEntry = {
          id: crypto.randomUUID(),
          projectId: state.activeTimer.projectId,
          description: state.activeTimer.description,
          startTime: state.activeTimer.startTime,
          endTime: Date.now(),
        };

        return {
          timeEntries: [newEntry, ...state.timeEntries],
          activeTimer: null
        };
      }),
      
      updateActiveTimer: (updates) => set((state) => ({
        activeTimer: state.activeTimer ? { ...state.activeTimer, ...updates } : null
      })),

      addTimeEntry: (entry) => set((state) => ({ 
        timeEntries: [{ ...entry, id: crypto.randomUUID() }, ...state.timeEntries] 
      })),
      
      deleteTimeEntry: (id) => set((state) => ({
        timeEntries: state.timeEntries.filter((t) => t.id !== id)
      })),
    }),
    {
      name: 'harvest-clone-storage',
    }
  )
);
