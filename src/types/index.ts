export interface Project {
  id: string;
  name: string;
  color: string;
  createdAt: number;
}

export interface TimeEntry {
  id: string;
  projectId: string;
  description: string;
  startTime: number;
  endTime: number;
}

export interface ActiveTimer {
  projectId: string | null;
  description: string;
  startTime: number | null;
}
