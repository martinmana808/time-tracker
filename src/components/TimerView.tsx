import { useState, useEffect } from 'react';
import { useTimerStore } from '../store/useTimerStore';
import { Play, Square, Plus, Trash2, Clock } from 'lucide-react';
import { format } from 'date-fns';

function formatDuration(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
}

export function TimerView() {
  const { 
    projects, 
    timeEntries, 
    activeTimer, 
    startTimer, 
    stopTimer, 
    deleteTimeEntry, 
    addTimeEntry 
  } = useTimerStore();
  
  const [description, setDescription] = useState('');
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');
  const [elapsed, setElapsed] = useState(0);
  
  const [isManualMode, setIsManualMode] = useState(false);
  const [manualDuration, setManualDuration] = useState('01:00');

  // Sync state with active timer
  useEffect(() => {
    if (activeTimer) {
      setDescription(activeTimer.description);
      setSelectedProjectId(activeTimer.projectId || '');
    } else {
      setDescription('');
      setSelectedProjectId(projects.length > 0 ? projects[0].id : '');
    }
  }, [activeTimer, projects]);

  // Default project selection when loading
  useEffect(() => {
    if (!selectedProjectId && projects.length > 0) {
      setSelectedProjectId(projects[0].id);
    }
  }, [projects, selectedProjectId]);

  // Timer tick
  useEffect(() => {
    let interval: ReturnType<typeof setInterval>;
    if (activeTimer?.startTime) {
      setElapsed(Math.floor((Date.now() - activeTimer.startTime) / 1000));
      interval = setInterval(() => {
        setElapsed(Math.floor((Date.now() - activeTimer.startTime!) / 1000));
      }, 1000);
    } else {
      setElapsed(0);
    }
    return () => clearInterval(interval);
  }, [activeTimer]);

  const handleStartStop = () => {
    if (activeTimer) {
      stopTimer();
    } else {
      if (!selectedProjectId) {
        alert('Please create and select a project first.');
        return;
      }
      startTimer(selectedProjectId, description);
    }
  };

  const handleManualAdd = () => {
    if (!selectedProjectId) {
      alert('Please create and select a project first.');
      return;
    }
    
    // Parse duration (HH:MM or MM)
    let seconds = 3600; // 1 hr default
    const parts = manualDuration.split(':').map(Number);
    if (parts.length === 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
      seconds = parts[0] * 3600 + parts[1] * 60;
    } else if (parts.length === 1 && !isNaN(parts[0])) {
      seconds = parts[0] * 60; // assume minutes if no colon
    }

    const endTime = Date.now();
    addTimeEntry({
      projectId: selectedProjectId,
      description,
      startTime: endTime - (seconds * 1000),
      endTime,
    });
    
    setDescription('');
    setIsManualMode(false);
  };

  return (
    <div className="p-8 pb-32">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Time Tracking</h1>
          <p className="text-slate-500 mt-1">Track what you are currently working on.</p>
        </div>
      </div>

      {/* Timer Bar */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-4 mb-10 flex flex-col md:flex-row items-center gap-4">
        <input
          type="text"
          placeholder="What are you working on?"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          disabled={!!activeTimer}
          className="flex-1 w-full px-4 py-3 rounded-xl border border-slate-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 outline-none transition-all text-slate-900 disabled:bg-slate-50 disabled:text-slate-500"
        />
        
        <select
          value={selectedProjectId}
          onChange={(e) => setSelectedProjectId(e.target.value)}
          disabled={!!activeTimer}
          className="w-full md:w-48 px-4 py-3 rounded-xl border border-slate-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 outline-none transition-all text-slate-900 font-medium appearance-none bg-white cursor-pointer disabled:bg-slate-50 disabled:text-slate-500"
        >
          {projects.length === 0 ? (
            <option value="" disabled>No projects yet</option>
          ) : (
            projects.map(p => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))
          )}
        </select>

        {isManualMode ? (
          <div className="flex items-center gap-3">
            <input
              type="text"
              placeholder="01:00"
              value={manualDuration}
              onChange={(e) => setManualDuration(e.target.value)}
              className="w-24 font-mono font-bold text-lg px-3 py-2 text-center rounded-xl border border-slate-200 focus:border-blue-500 outline-none text-slate-900"
            />
            <button
              onClick={handleManualAdd}
              className="px-5 py-3 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-xl shadow-sm transition-all active:scale-95 whitespace-nowrap"
            >
              Log Time
            </button>
            <button onClick={() => setIsManualMode(false)} className="px-3 py-3 text-slate-400 hover:text-slate-600">
              Cancel
            </button>
          </div>
        ) : (
          <div className="flex items-center gap-4 border-l border-slate-100 pl-4 w-full md:w-auto justify-between">
            <span className="font-mono font-bold text-2xl text-slate-800 tracking-tight w-28 text-right">
              {formatDuration(elapsed)}
            </span>
            <button
              onClick={handleStartStop}
              className={`w-12 h-12 flex items-center justify-center rounded-xl shadow-sm transition-all active:scale-95 ${
                activeTimer 
                  ? "bg-red-500 hover:bg-red-600 text-white shadow-red-500/20" 
                  : "bg-emerald-500 hover:bg-emerald-600 text-white shadow-emerald-500/20"
              }`}
            >
              {activeTimer ? <Square className="w-5 h-5 fill-current" /> : <Play className="w-5 h-5 fill-current ml-1" />}
            </button>
            {!activeTimer && (
              <button
                onClick={() => setIsManualMode(true)}
                className="text-slate-400 hover:text-blue-600 transition-colors p-2 rounded-lg hover:bg-blue-50"
                title="Manual Entry"
              >
                <Plus className="w-5 h-5" />
              </button>
            )}
          </div>
        )}
      </div>

      {/* Recent Entries */}
      <h2 className="text-lg font-bold text-slate-800 mb-4">Recent Entries</h2>
      {timeEntries.length === 0 ? (
        <div className="text-center py-16 px-6 border border-dashed border-slate-200 rounded-2xl bg-slate-50/50">
          <Clock className="w-12 h-12 text-slate-300 mx-auto mb-3" />
          <h3 className="text-lg font-semibold text-slate-700 mb-1">No time logged yet</h3>
          <p className="text-slate-500 text-sm">Start the timer above to log your first activity.</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden divide-y divide-slate-100">
          {timeEntries.map((entry) => {
            const project = projects.find(p => p.id === entry.projectId);
            const durationSec = Math.floor((entry.endTime - entry.startTime) / 1000);
            
            return (
              <div key={entry.id} className="flex flex-col sm:flex-row sm:items-center p-4 hover:bg-slate-50 transition-colors group">
                <div className="flex-1 flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-6 w-full">
                  <div className="flex items-center w-full sm:w-1/4 min-w-[150px]">
                    <span 
                      className="w-3 h-3 rounded-full mr-3 shrink-0" 
                      style={{ backgroundColor: project?.color || '#cbd5e1' }}
                    />
                    <span className="font-semibold text-slate-800 truncate" title={project?.name || 'Deleted Project'}>
                      {project?.name || 'Deleted Project'}
                    </span>
                  </div>
                  
                  <div className="flex-1 text-slate-600 truncate" title={entry.description || '(No description)'}>
                    {entry.description || <span className="text-slate-400 italic">No description</span>}
                  </div>
                </div>

                <div className="flex items-center justify-between sm:justify-end gap-6 w-full sm:w-auto mt-3 sm:mt-0">
                  <div className="text-sm font-medium text-slate-500 whitespace-nowrap">
                    {format(entry.startTime, 'h:mm a')} - {format(entry.endTime, 'h:mm a')}
                  </div>
                  <div className="font-mono font-bold text-lg text-slate-800 tracking-tight w-24 text-right">
                    {formatDuration(durationSec)}
                  </div>
                  <button 
                    onClick={() => {
                      if (window.confirm('Delete this entry?')) deleteTimeEntry(entry.id);
                    }}
                    className="p-2 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors opacity-100 sm:opacity-0 group-hover:opacity-100 shrink-0"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
