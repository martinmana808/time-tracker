import { useMemo } from 'react';
import { useTimerStore } from '../store/useTimerStore';
import { Clock, TrendingUp, Calendar, Hash } from 'lucide-react';
import { format, startOfDay, startOfWeek, isAfter } from 'date-fns';

function formatDuration(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  return `${h}h ${m}m`;
}

export function DashboardView() {
  const { projects, timeEntries } = useTimerStore();

  const stats = useMemo(() => {
    const now = new Date();
    const today = startOfDay(now);
    const thisWeek = startOfWeek(now, { weekStartsOn: 1 });

    let totalSeconds = 0;
    let todaySeconds = 0;
    let weekSeconds = 0;

    const projectTotals: Record<string, number> = {};

    timeEntries.forEach(entry => {
      const durationSec = Math.floor((entry.endTime - entry.startTime) / 1000);
      totalSeconds += durationSec;

      if (isAfter(new Date(entry.endTime), today)) {
        todaySeconds += durationSec;
      }
      if (isAfter(new Date(entry.endTime), thisWeek)) {
        weekSeconds += durationSec;
      }

      projectTotals[entry.projectId] = (projectTotals[entry.projectId] || 0) + durationSec;
    });

    // Sort projects by total time
    const topProjects = Object.entries(projectTotals)
      .map(([projectId, duration]) => ({
        project: projects.find(p => p.id === projectId),
        duration
      }))
      .filter(p => p.project)
      .sort((a, b) => b.duration - a.duration);

    return { totalSeconds, todaySeconds, weekSeconds, topProjects };
  }, [timeEntries, projects]);

  return (
    <div className="p-8 pb-32 animate-in fade-in duration-300">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Dashboard</h1>
        <p className="text-slate-500 mt-1">Overview of your time and projects.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center hover:shadow-md transition-shadow">
          <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center mr-4">
            <Clock className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm font-medium text-slate-500 mb-1">Today</p>
            <p className="text-2xl font-bold text-slate-900">{formatDuration(stats.todaySeconds)}</p>
          </div>
        </div>
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center hover:shadow-md transition-shadow">
          <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-xl flex items-center justify-center mr-4">
            <Calendar className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm font-medium text-slate-500 mb-1">This Week</p>
            <p className="text-2xl font-bold text-slate-900">{formatDuration(stats.weekSeconds)}</p>
          </div>
        </div>
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-center hover:shadow-md transition-shadow">
          <div className="w-12 h-12 bg-purple-50 text-purple-600 rounded-xl flex items-center justify-center mr-4">
            <TrendingUp className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm font-medium text-slate-500 mb-1">All Time</p>
            <p className="text-2xl font-bold text-slate-900">{formatDuration(stats.totalSeconds)}</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div>
          <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center">
            <Hash className="w-5 h-5 mr-2 text-slate-400" />
            Time by Project
          </h2>
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            {stats.topProjects.length === 0 ? (
              <div className="p-8 text-center text-slate-500">No time logged yet.</div>
            ) : (
              <div className="divide-y divide-slate-100">
                {stats.topProjects.map(({ project, duration }) => (
                  <div key={project!.id} className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors">
                    <div className="flex items-center">
                      <span 
                        className="w-3 h-3 rounded-full mr-3" 
                        style={{ backgroundColor: project!.color }}
                      />
                      <span className="font-medium text-slate-800">{project!.name}</span>
                    </div>
                    <span className="font-mono font-bold text-slate-600">{formatDuration(duration)}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
        
        <div>
          <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center">
            <Clock className="w-5 h-5 mr-2 text-slate-400" />
            Recent Activity
          </h2>
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden p-4">
            {timeEntries.length === 0 ? (
              <div className="p-8 text-center text-slate-500">No time logged yet.</div>
            ) : (
              <div className="space-y-4">
                {timeEntries.slice(0, 5).map(entry => {
                  const project = projects.find(p => p.id === entry.projectId);
                  const duration = Math.floor((entry.endTime - entry.startTime) / 1000);
                  return (
                    <div key={entry.id} className="flex items-start justify-between border-b border-slate-50 pb-4 last:border-0 last:pb-0 hover:bg-slate-50/50 p-2 -mx-2 rounded-lg transition-colors">
                      <div>
                        <div className="flex items-center mb-1">
                          <span 
                            className="w-2 h-2 rounded-full mr-2" 
                            style={{ backgroundColor: project?.color || '#cbd5e1' }}
                          />
                          <span className="text-sm font-medium text-slate-700">{project?.name || 'Deleted Project'}</span>
                        </div>
                        <p className="text-sm text-slate-500 pl-4">{entry.description || 'No description'}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-mono font-bold text-slate-700">{formatDuration(duration)}</p>
                        <p className="text-xs text-slate-400 mt-0.5">{format(entry.endTime, 'MMM d')}</p>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
