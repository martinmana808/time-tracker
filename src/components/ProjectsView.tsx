import React, { useState } from 'react';
import { useTimerStore } from '../store/useTimerStore';
import { Settings, Trash2, Plus, Palette, FolderKanban } from 'lucide-react';
import { format } from 'date-fns';

const COLORS = [
  '#ef4444', '#f97316', '#f59e0b', '#84cc16', '#22c55e',
  '#06b6d4', '#3b82f6', '#6366f1', '#a855f7', '#ec4899', '#64748b'
];

export function ProjectsView() {
  const { projects, addProject, deleteProject } = useTimerStore();
  const [isCreating, setIsCreating] = useState(false);
  const [newProjectName, setNewProjectName] = useState('');
  const [selectedColor, setSelectedColor] = useState(COLORS[0]);

  const handleCreateProject = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newProjectName.trim()) return;

    addProject({
      name: newProjectName.trim(),
      color: selectedColor,
    });
    
    setNewProjectName('');
    setIsCreating(false);
  };

  return (
    <div className="p-8 pb-32">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Projects</h1>
          <p className="text-slate-500 mt-1">Manage your teams, clients, or internal projects.</p>
        </div>
        
        <button 
          onClick={() => setIsCreating(true)}
          className="flex items-center px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-xl shadow-sm shadow-blue-600/20 transition-all active:scale-95"
        >
          <Plus className="w-5 h-5 mr-2" />
          New Project
        </button>
      </div>

      {isCreating && (
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 mb-8 animate-in fade-in slide-in-from-top-4 duration-200">
          <h2 className="text-lg font-semibold text-slate-800 mb-4">Create New Project</h2>
          <form onSubmit={handleCreateProject} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Project Name</label>
              <input
                autoFocus
                type="text"
                placeholder="e.g. Acme Website Redesign"
                value={newProjectName}
                onChange={(e) => setNewProjectName(e.target.value)}
                className="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 outline-none transition-all text-slate-900"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2 flex items-center">
                <Palette className="w-4 h-4 mr-1.5 text-slate-400" />
                Project Color
              </label>
              <div className="flex flex-wrap gap-3">
                {COLORS.map((color) => (
                  <button
                    key={color}
                    type="button"
                    onClick={() => setSelectedColor(color)}
                    style={{ backgroundColor: color }}
                    className={`w-8 h-8 rounded-full transition-all duration-200 ${
                      selectedColor === color ? 'ring-2 ring-offset-2 ring-slate-800 scale-110 shadow-sm' : 'hover:scale-110 opacity-80 hover:opacity-100'
                    }`}
                  />
                ))}
              </div>
            </div>

            <div className="pt-2 flex justify-end space-x-3">
              <button 
                type="button" 
                onClick={() => setIsCreating(false)}
                className="px-5 py-2.5 text-slate-600 font-medium hover:bg-slate-100 rounded-xl transition-colors"
              >
                Cancel
              </button>
              <button 
                type="submit"
                disabled={!newProjectName.trim()}
                className="px-5 py-2.5 bg-slate-900 hover:bg-slate-800 disabled:opacity-50 disabled:cursor-not-allowed text-white font-medium rounded-xl shadow-sm transition-all active:scale-95"
              >
                Save Project
              </button>
            </div>
          </form>
        </div>
      )}

      {projects.length === 0 && !isCreating ? (
        <div className="text-center py-20 px-6 border-2 border-dashed border-slate-200 rounded-3xl bg-slate-50/50">
          <FolderKanban className="w-16 h-16 text-slate-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-slate-700 mb-2">No projects yet</h3>
          <p className="text-slate-500 max-w-sm mx-auto mb-6">Create your first project to start tracking time against it.</p>
          <button 
            onClick={() => setIsCreating(true)}
            className="inline-flex items-center px-5 py-2.5 bg-white border border-slate-200 hover:border-slate-300 text-slate-700 font-medium rounded-xl shadow-sm transition-all active:scale-95"
          >
            <Plus className="w-5 h-5 mr-2 text-slate-400" />
            Create Project
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {projects.map((project) => (
            <div 
              key={project.id} 
              className="bg-white group rounded-2xl p-6 shadow-sm shadow-slate-200/50 border border-slate-200 hover:shadow-md hover:border-slate-300 transition-all duration-200 relative overflow-hidden"
            >
              <div 
                className="absolute top-0 left-0 w-full h-1.5" 
                style={{ backgroundColor: project.color }}
              />
              <div className="flex justify-between items-start mb-4 mt-1">
                <h3 className="text-lg font-bold text-slate-800 line-clamp-1 pr-4">{project.name}</h3>
                <div className="opacity-0 group-hover:opacity-100 transition-opacity flex space-x-1">
                  <button className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-colors">
                    <Settings className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => {
                      if (window.confirm('Delete this project? This will not delete time entries.')) {
                        deleteProject(project.id);
                      }
                    }}
                    className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
              <div className="text-sm text-slate-500">
                Created {format(project.createdAt, 'MMM d, yyyy')}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
