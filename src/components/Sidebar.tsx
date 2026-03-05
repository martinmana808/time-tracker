import { LayoutDashboard, Clock, FolderKanban, Settings } from 'lucide-react';
import { cn } from '../lib/utils';

export type ViewType = 'dashboard' | 'timer' | 'projects';

interface SidebarProps {
  currentView: ViewType;
  setCurrentView: (view: ViewType) => void;
}

export function Sidebar({ currentView, setCurrentView }: SidebarProps) {
  const navItems = [
    { id: 'timer', label: 'Time', icon: Clock },
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'projects', label: 'Projects', icon: FolderKanban },
  ] as const;

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 h-screen flex border-r border-slate-800 flex-col font-medium">
      <div className="h-20 flex items-center px-6 font-bold text-xl text-white tracking-wide">
        <div className="w-8 h-8 rounded-lg bg-orange-500 mr-3 flex items-center justify-center shadow-lg shadow-orange-500/30">
          <Clock className="w-5 h-5 text-white" />
        </div>
        HarvestClone
      </div>
      
      <nav className="flex-1 py-6 px-4 space-y-1">
        {navItems.map((item) => (
          <button
            key={item.id}
            onClick={() => setCurrentView(item.id)}
            className={cn(
              "w-full flex items-center px-4 py-2.5 rounded-lg transition-all duration-200",
              currentView === item.id 
                ? "bg-orange-500/10 text-orange-400" 
                : "hover:bg-slate-800 hover:text-slate-100"
            )}
          >
            <item.icon className={cn(
              "w-5 h-5 mr-3",
              currentView === item.id ? "text-orange-400" : "text-slate-500"
            )} />
            {item.label}
          </button>
        ))}
      </nav>
      
      <div className="p-4">
        <button className="flex items-center px-4 py-2.5 w-full text-sm text-slate-500 hover:text-slate-300 hover:bg-slate-800 rounded-lg transition-all duration-200">
          <Settings className="w-4 h-4 mr-3" />
          Settings
        </button>
      </div>
    </aside>
  );
}
