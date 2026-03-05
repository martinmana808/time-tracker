import { useState } from 'react';
import { Sidebar, type ViewType } from './components/Sidebar';
import { ProjectsView } from './components/ProjectsView';
import { TimerView } from './components/TimerView';
import { DashboardView } from './components/DashboardView';





function App() {
  const [currentView, setCurrentView] = useState<ViewType>('timer');

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden font-sans">
      <Sidebar currentView={currentView} setCurrentView={setCurrentView} />
      
      <main className="flex-1 flex flex-col h-full overflow-hidden relative">
        <div className="flex-1 overflow-y-auto w-full">
          <div className="max-w-5xl mx-auto w-full">
            {currentView === 'dashboard' && <DashboardView />}
            {currentView === 'timer' && <TimerView />}
            {currentView === 'projects' && <ProjectsView />}
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
