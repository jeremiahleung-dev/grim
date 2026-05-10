// grim — screen components, faithful to grim/Shared/Theme.swift + the SwiftUI source.
//
// Theme tokens:
//   background #0a0a0a · surface #1a1a1a · ink #f0ece0 · muted #888888
//   border #2e2e2e · accent #e8a045
//   font: monospaced (system-ui-monospace), lowercase everything

const T = {
  bg: '#0a0a0a',
  surface: '#1a1a1a',
  ink: '#f0ece0',
  muted: '#888888',
  border: '#2e2e2e',
  accent: '#e8a045',
  mono: 'ui-monospace, "SF Mono", Menlo, Consolas, monospace',
};
window.T = T;

// ─── Helpers ─────────────────────────────────────────────────
const fmt = (n) => Number(n).toLocaleString('en-US');

// Compute remaining for a virtual user (DOB 1996-07-17, life 90).
// Anchor "today" to a fixed reference so the prototype is deterministic.
const REF_TODAY = new Date('2026-05-09T12:00:00Z');
const DOB = new Date('1996-07-17T00:00:00Z');
const LIFE_EXPECTANCY = 90;
const MS_DAY = 24 * 60 * 60 * 1000;

function daysRemaining(dob = DOB, life = LIFE_EXPECTANCY) {
  const end = new Date(dob);
  end.setUTCFullYear(end.getUTCFullYear() + life);
  return Math.max(0, Math.floor((end - REF_TODAY) / MS_DAY));
}
const DAYS_LEFT = daysRemaining();
const WEEKS_LEFT = Math.floor(DAYS_LEFT / 7);
const YEARS_LEFT = Math.floor(DAYS_LEFT / 365.25);
const WEEKS_LIVED = Math.floor((REF_TODAY - DOB) / (MS_DAY * 7));

// ─── Phone shell (no iOS chrome — this is a fullscreen app) ──
function GrimShell({ children, dark = true, statusTime = '9:41' }) {
  // Use IOSDevice for status bar + home indicator authenticity, but
  // hide its nav (the app has its own).
  return (
    <IOSDevice width={390} height={844} dark={true}>
      <div style={{
        position: 'absolute', inset: 0, background: T.bg,
        fontFamily: T.mono, color: T.ink,
        overflow: 'hidden',
      }}>
        {children}
      </div>
    </IOSDevice>
  );
}

// ─── Top chrome: "grim" + ellipsis + week strip ──────────────
function TopChrome({ onSettings, onSelectDay, selectedDay }) {
  // Sun-anchored week containing REF_TODAY (2026-05-09 is Saturday).
  const today = REF_TODAY;
  const weekday = today.getUTCDay(); // 0 = Sun
  const sunday = new Date(today);
  sunday.setUTCDate(today.getUTCDate() - weekday);
  const days = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(sunday);
    d.setUTCDate(sunday.getUTCDate() + i);
    return d;
  });
  const letters = ['S', 'M', 'T', 'W', 'R', 'F', 'S']; // R for Thu, per source
  // Some example tasks-on-day flags
  const hasTasks = (d) => [1, 2, 5].includes(d.getUTCDay()); // Mon, Tue, Fri

  return (
    <div style={{ position: 'absolute', top: 0, left: 0, right: 0, paddingTop: 60, zIndex: 10 }}>
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 28px',
      }}>
        <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted, letterSpacing: 0.2 }}>grim</span>
        <button onClick={onSettings} style={{
          background: 'none', border: 0, color: T.muted, cursor: 'pointer',
          fontSize: 14, padding: 4, lineHeight: 1,
        }}>•••</button>
      </div>

      {/* Week strip */}
      <div style={{ display: 'flex', padding: '20px 28px 0' }}>
        {days.map((d, i) => {
          const isToday = d.toDateString() === today.toDateString();
          const isPast = !isToday && d < today;
          const color = isToday ? T.accent : (isPast ? 'rgba(240,236,224,0.2)' : 'rgba(240,236,224,0.6)');
          const dot = hasTasks(d);
          return (
            <button key={i} onClick={() => onSelectDay && onSelectDay(d)} style={{
              flex: 1, background: 'none', border: 0, cursor: 'pointer',
              padding: '8px 0', display: 'flex', flexDirection: 'column',
              alignItems: 'center', gap: 6,
            }}>
              <span style={{ fontFamily: T.mono, fontSize: 11, color }}>{letters[i]}</span>
              <span style={{
                width: 3, height: 3, borderRadius: '50%',
                background: dot ? color : 'transparent',
              }} />
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─── Bottom chrome: today prompt + life-list hint ────────────
function BottomChrome({ promptText, lifeCount, onOpenLife }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 10,
      paddingBottom: 48, display: 'flex', flexDirection: 'column',
    }}>
      {(promptText || lifeCount > 0) && (
        <button onClick={onOpenLife} style={{
          margin: '0 28px 24px', padding: 18,
          background: 'none', border: `1px solid ${T.border}`,
          color: T.ink, textAlign: 'left', cursor: 'pointer',
          display: 'flex', flexDirection: 'column', gap: 6,
        }}>
          <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>today</span>
          <span style={{
            fontFamily: T.mono, fontSize: 11,
            color: promptText ? 'rgba(240,236,224,0.8)' : 'rgba(136,136,136,0.5)',
            lineHeight: 1.55,
          }}>
            {promptText || 'tap to add things you want to do with your days →'}
          </span>
        </button>
      )}

      <button onClick={onOpenLife} style={{
        background: 'none', border: 0, cursor: 'pointer',
        color: 'rgba(136,136,136,0.4)', fontFamily: T.mono, fontSize: 11,
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      }}>
        <span style={{ fontSize: 9 }}>▲</span>
        <span>{lifeCount === 0 ? 'your life list' : `${lifeCount} things`}</span>
      </button>
    </div>
  );
}

// ─── Centered countdown body ─────────────────────────────────
function CountdownBody({ unit = 'days', expired = false }) {
  const value = expired ? 0 : (unit === 'days' ? DAYS_LEFT : unit === 'weeks' ? WEEKS_LEFT : YEARS_LEFT);
  const label = expired ? 'you made it.' : `${unit} remaining`;
  const today = 'Saturday, May 9';

  return (
    <div style={{
      position: 'absolute', inset: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'flex-start',
      padding: '0 28px',
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'flex-start' }}>
        <div style={{
          fontFamily: T.mono, fontSize: 72, fontWeight: 500, color: T.ink,
          lineHeight: 1, letterSpacing: -1,
        }}>{fmt(value)}</div>
        <div style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>{label}</div>
        <div style={{ fontFamily: T.mono, fontSize: 11, color: 'rgba(136,136,136,0.45)' }}>{today}</div>
        <div style={{ display: 'flex', gap: 6, paddingTop: 4 }}>
          {['days', 'weeks', 'years'].map((u) => (
            <span key={u} style={{
              width: 4, height: 4, borderRadius: '50%',
              background: u === unit ? T.muted : 'rgba(136,136,136,0.25)',
            }} />
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Screen 1: Onboarding — Welcome ──────────────────────────
function Onboarding_Welcome() {
  const [pulse, setPulse] = React.useState(true);
  React.useEffect(() => {
    const id = setInterval(() => setPulse(p => !p), 1400);
    return () => clearInterval(id);
  }, []);
  return (
    <GrimShell>
      <div style={{
        position: 'absolute', inset: 0, padding: '0 28px',
        display: 'flex', flexDirection: 'column', justifyContent: 'center',
        alignItems: 'flex-start', gap: 20,
      }}>
        <div style={{ fontFamily: T.mono, fontSize: 40, fontWeight: 500, color: T.ink }}>grim</div>
        <div style={{
          fontFamily: T.mono, fontSize: 11, color: T.muted, lineHeight: 2,
          whiteSpace: 'pre-line',
        }}>{'you have a finite number\nof days.\n\nthis is how many remain.'}</div>
        <div style={{
          fontFamily: T.mono, fontSize: 11,
          color: pulse ? 'rgba(136,136,136,0.6)' : 'rgba(136,136,136,0.25)',
          paddingTop: 8, transition: 'color 1.4s ease-in-out',
        }}>tap to begin</div>
      </div>
    </GrimShell>
  );
}

// ─── Screen 2: Onboarding — DOB picker (faux iOS wheel) ──────
function WheelColumn({ values, selected, width = 80, align = 'center' }) {
  // Stylized iOS wheel: selected centered, neighbours faded.
  const ROW = 34;
  const idx = values.indexOf(selected);
  return (
    <div style={{
      width, height: ROW * 5, position: 'relative', overflow: 'hidden',
      maskImage: 'linear-gradient(to bottom, transparent, #000 28%, #000 72%, transparent)',
      WebkitMaskImage: 'linear-gradient(to bottom, transparent, #000 28%, #000 72%, transparent)',
    }}>
      <div style={{
        position: 'absolute', left: 0, right: 0,
        top: ROW * 2 - idx * ROW,
        transition: 'top 0.25s ease-out',
      }}>
        {values.map((v, i) => {
          const dist = Math.abs(i - idx);
          const opacity = dist === 0 ? 1 : dist === 1 ? 0.55 : dist === 2 ? 0.22 : 0.1;
          return (
            <div key={v} style={{
              height: ROW, display: 'flex', alignItems: 'center',
              justifyContent: align, padding: '0 10px',
              fontFamily: T.mono, fontSize: 18, color: T.ink, opacity,
            }}>{v}</div>
          );
        })}
      </div>
    </div>
  );
}

function Onboarding_DOB() {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const days = Array.from({length: 31}, (_, i) => String(i + 1));
  const years = Array.from({length: 80}, (_, i) => String(2024 - i));
  return (
    <GrimShell>
      <div style={{
        position: 'absolute', inset: 0, padding: '0 28px',
        display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 24,
      }}>
        <div style={{
          fontFamily: T.mono, fontSize: 40, fontWeight: 500, color: T.ink,
          lineHeight: 1.2, whiteSpace: 'pre-line',
        }}>{'when were\nyou born?'}</div>

        <div style={{
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          gap: 0, position: 'relative',
        }}>
          {/* selection rails */}
          <div style={{
            position: 'absolute', left: 0, right: 0, top: '50%',
            transform: 'translateY(-50%)', height: 34,
            background: 'rgba(255,255,255,0.05)',
            borderRadius: 8, pointerEvents: 'none',
          }} />
          <WheelColumn values={months} selected="Jul" width={80} align="flex-start" />
          <WheelColumn values={days} selected="17" width={56} align="center" />
          <WheelColumn values={years} selected="1996" width={88} align="center" />
        </div>
      </div>

      {/* CTA */}
      <button style={{
        position: 'absolute', left: 28, right: 28, bottom: 48,
        padding: '18px 24px', background: T.ink, border: 0, color: T.bg,
        fontFamily: T.mono, fontSize: 11, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <span>next</span>
        <span style={{ fontSize: 12 }}>→</span>
      </button>
    </GrimShell>
  );
}

// ─── Screen 3: Onboarding — Life expectancy ──────────────────
function Onboarding_Life() {
  const [val, setVal] = React.useState(90);
  return (
    <GrimShell>
      <div style={{
        position: 'absolute', inset: 0, padding: '0 28px',
        display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 24,
      }}>
        <div style={{
          fontFamily: T.mono, fontSize: 40, fontWeight: 500, color: T.ink,
          lineHeight: 1.2, whiteSpace: 'pre-line',
        }}>{'how long\nwill you live?'}</div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{
            fontFamily: T.mono, fontSize: 72, fontWeight: 500, color: T.ink, lineHeight: 1,
          }}>{val}</div>

          {/* slider */}
          <input
            type="range" min={70} max={120} step={1} value={val}
            onChange={(e) => setVal(Number(e.target.value))}
            className="grim-slider"
            style={{ width: '100%' }}
          />

          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>70</span>
            <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>120</span>
          </div>
        </div>
      </div>

      <button style={{
        position: 'absolute', left: 28, right: 28, bottom: 48,
        padding: '18px 24px', background: T.ink, border: 0, color: T.bg,
        fontFamily: T.mono, fontSize: 11, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <span>start</span>
        <span style={{ fontSize: 12 }}>→</span>
      </button>
    </GrimShell>
  );
}

// ─── Screen 4: Main — interactive countdown ──────────────────
function MainCountdown({ initialUnit = 'days', initialPrompt = null, initialLife = [], initialSheet = null }) {
  const [unit, setUnit] = React.useState(initialUnit);
  const [sheet, setSheet] = React.useState(initialSheet);
  const [selectedDay, setSelectedDay] = React.useState(null);
  const [life, setLife] = React.useState(initialLife);
  const [prompt, setPrompt] = React.useState(initialPrompt);

  const swipeRef = React.useRef({ x: 0, y: 0 });
  const units = ['days', 'weeks', 'years'];
  const onPointerDown = (e) => { swipeRef.current = { x: e.clientX, y: e.clientY }; };
  const onPointerUp = (e) => {
    const dx = e.clientX - swipeRef.current.x;
    const dy = e.clientY - swipeRef.current.y;
    if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) > 30) {
      const i = units.indexOf(unit);
      if (dx < 0 && i < 2) setUnit(units[i + 1]);
      if (dx > 0 && i > 0) setUnit(units[i - 1]);
    }
  };

  return (
    <GrimShell>
      <TopChrome
        onSettings={() => setSheet('settings')}
        onSelectDay={(d) => { setSelectedDay(d); setSheet('day'); }}
      />

      <div
        style={{ position: 'absolute', inset: 0 }}
        onPointerDown={onPointerDown}
        onPointerUp={onPointerUp}
      >
        <CountdownBody unit={unit} />
      </div>

      <BottomChrome
        promptText={prompt}
        lifeCount={life.length}
        onOpenLife={() => setSheet('life')}
      />

      {/* Sheets */}
      <Sheet open={sheet === 'life'} onClose={() => setSheet(null)}>
        <LifeListSheet
          items={life}
          prompt={prompt}
          onAdd={(t) => setLife([...life, { id: crypto.randomUUID(), text: t }])}
          onRemove={(id) => setLife(life.filter(x => x.id !== id))}
          onRefreshPrompt={() => setPrompt('today, text your sister and ask about her week. small check-ins are how you keep close people close — and you said you want to be a present brother.')}
        />
      </Sheet>

      <Sheet open={sheet === 'settings'} onClose={() => setSheet(null)}>
        <SettingsSheet />
      </Sheet>

      <Sheet open={sheet === 'day'} onClose={() => setSheet(null)}>
        <DayDetailSheet date={selectedDay || REF_TODAY} />
      </Sheet>
    </GrimShell>
  );
}

// ─── Sheet container ─────────────────────────────────────────
function Sheet({ open, onClose, children }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 100,
      pointerEvents: open ? 'auto' : 'none',
    }}>
      {/* dimmer */}
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)',
        opacity: open ? 1 : 0, transition: 'opacity 0.25s ease',
      }} />
      {/* sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        height: '92%', background: T.bg,
        borderTopLeftRadius: 14, borderTopRightRadius: 14,
        transform: open ? 'translateY(0)' : 'translateY(100%)',
        transition: 'transform 0.3s cubic-bezier(0.32, 0.72, 0, 1)',
        overflow: 'hidden', display: 'flex', flexDirection: 'column',
      }}>
        {children}
      </div>
    </div>
  );
}

// ─── Life list sheet ─────────────────────────────────────────
function LifeListSheet({ items, prompt, onAdd, onRemove, onRefreshPrompt }) {
  const [val, setVal] = React.useState('');
  const [thinking, setThinking] = React.useState(false);

  const submit = () => {
    if (!val.trim()) return;
    onAdd(val.trim());
    setVal('');
    setThinking(true);
    setTimeout(() => { setThinking(false); onRefreshPrompt(); }, 1200);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <SheetHeader title="your life list" />

      {items.length > 0 && (
        <div style={{ margin: '0 28px 24px', padding: 20, border: `1px solid ${T.border}` }}>
          <div style={{ fontFamily: T.mono, fontSize: 11, color: T.muted, marginBottom: 10 }}>today</div>
          {thinking ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontFamily: T.mono, fontSize: 11, color: T.muted }}>
              <Spinner /> <span>thinking...</span>
            </div>
          ) : prompt ? (
            <React.Fragment>
              <div style={{ fontFamily: T.mono, fontSize: 11, color: T.ink, lineHeight: 1.7 }}>{prompt}</div>
              <button onClick={() => { setThinking(true); setTimeout(() => setThinking(false), 1100); }} style={{
                background: 'none', border: 0, padding: 0, marginTop: 6,
                fontFamily: T.mono, fontSize: 11, color: 'rgba(136,136,136,0.5)', cursor: 'pointer',
              }}>refresh →</button>
            </React.Fragment>
          ) : (
            <div style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>no suggestion yet — add items to your list.</div>
          )}
        </div>
      )}

      <div style={{ flex: 1, overflowY: 'auto' }}>
        {items.length === 0 ? (
          <div style={{
            padding: '40px 28px', fontFamily: T.mono, fontSize: 11,
            color: 'rgba(136,136,136,0.5)', lineHeight: 1.7,
          }}>
            things you want to do, feel, or become.<br />
            no shoulds. only what's true.
          </div>
        ) : (
          items.map((it, i) => (
            <div key={it.id} style={{
              display: 'flex', alignItems: 'flex-start', gap: 14,
              padding: '10px 28px',
            }}>
              <span style={{
                width: 4, height: 4, borderRadius: '50%',
                background: T.accent, marginTop: 7, flexShrink: 0,
              }} />
              <span style={{ fontFamily: T.mono, fontSize: 11, color: T.ink, lineHeight: 1.7, flex: 1 }}>
                {it.text}
              </span>
            </div>
          ))
        )}
      </div>

      <SheetInput
        value={val} onChange={setVal} placeholder="add something..."
        onSubmit={submit}
      />
    </div>
  );
}

// ─── Settings sheet ──────────────────────────────────────────
function SettingsSheet() {
  const [active, setActive] = React.useState('dob');
  const [le, setLe] = React.useState(90);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <SheetHeader title="settings" />

      <div style={{ flex: 1, overflowY: 'auto', padding: '0 0 24px' }}>
        {/* DOB */}
        <div onClick={() => setActive('dob')} style={{
          opacity: active === 'dob' ? 1 : 0.45, transition: 'opacity 0.2s',
          padding: '0 28px',
        }}>
          <div style={{
            fontFamily: T.mono, fontSize: 11, marginBottom: 16,
            color: active === 'dob' ? T.ink : T.muted,
          }}>date of birth</div>
          <div style={{
            display: 'flex', justifyContent: 'center', position: 'relative', marginBottom: 8,
          }}>
            <div style={{
              position: 'absolute', left: 0, right: 0, top: '50%',
              transform: 'translateY(-50%)', height: 34,
              background: 'rgba(255,255,255,0.05)', borderRadius: 8,
            }} />
            <WheelColumn values={['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']} selected="Jul" width={80} align="flex-start" />
            <WheelColumn values={Array.from({length: 31}, (_, i) => String(i + 1))} selected="17" width={56} align="center" />
            <WheelColumn values={Array.from({length: 80}, (_, i) => String(2024 - i))} selected="1996" width={88} align="center" />
          </div>
        </div>

        <div style={{ height: 1, background: T.border, margin: '32px 28px' }} />

        {/* Life expectancy */}
        <div onClick={() => setActive('le')} style={{
          opacity: active === 'le' ? 1 : 0.45, transition: 'opacity 0.2s',
          padding: '0 28px',
        }}>
          <div style={{
            fontFamily: T.mono, fontSize: 11, marginBottom: 16,
            color: active === 'le' ? T.ink : T.muted,
          }}>life expectancy</div>
          <div style={{
            fontFamily: T.mono, fontSize: 72, fontWeight: 500,
            color: T.ink, lineHeight: 1, marginBottom: 12,
          }}>{le}</div>
          <input type="range" min={70} max={120} value={le}
            onChange={(e) => setLe(Number(e.target.value))}
            className="grim-slider" style={{ width: '100%' }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4 }}>
            <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>70</span>
            <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>120</span>
          </div>
        </div>
      </div>

      <button style={{
        margin: '0 28px 48px', padding: '18px 24px',
        background: T.ink, border: 0, color: T.bg,
        fontFamily: T.mono, fontSize: 11, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <span>save</span>
        <span style={{ fontSize: 12 }}>→</span>
      </button>
    </div>
  );
}

// ─── Day detail sheet ────────────────────────────────────────
function DayDetailSheet({ date }) {
  const [tasks, setTasks] = React.useState([
    { id: 'a', text: 'morning walk before opening the laptop' },
    { id: 'b', text: 'call mom — ask about the garden' },
  ]);
  const [val, setVal] = React.useState('');
  const today = new Date(REF_TODAY);
  const isToday = date && date.toDateString() === today.toDateString();
  const isPast = date && !isToday && date < today;
  const wkLong = date.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();
  const moLong = date.toLocaleDateString('en-US', { month: 'long' }).toLowerCase();
  const header = `${wkLong}, ${moLong} ${date.getUTCDate()}`;
  const prompt = isToday
    ? 'what will you do with today?'
    : isPast ? `what did you do on ${wkLong}?` : `what will you do on ${wkLong}?`;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <SheetHeader title={header} />
      <div style={{
        padding: '0 28px 28px', fontFamily: T.mono, fontSize: 11,
        color: 'rgba(136,136,136,0.5)',
      }}>{prompt}</div>

      <div style={{ flex: 1, overflowY: 'auto' }}>
        {tasks.length === 0 ? (
          <div style={{ padding: '0 28px', fontFamily: T.mono, fontSize: 11, color: 'rgba(136,136,136,0.3)' }}>
            nothing yet.
          </div>
        ) : tasks.map(t => (
          <div key={t.id} style={{
            display: 'flex', alignItems: 'flex-start', gap: 14,
            padding: '10px 28px',
          }}>
            <span style={{
              width: 4, height: 4, borderRadius: '50%',
              background: isToday ? T.accent : T.muted,
              marginTop: 7, flexShrink: 0,
            }} />
            <span style={{ fontFamily: T.mono, fontSize: 11, color: T.ink, lineHeight: 1.7 }}>
              {t.text}
            </span>
          </div>
        ))}
      </div>

      <SheetInput value={val} onChange={setVal} placeholder="add something..."
        onSubmit={() => {
          if (!val.trim()) return;
          setTasks([...tasks, { id: crypto.randomUUID(), text: val.trim() }]);
          setVal('');
        }} />
    </div>
  );
}

// ─── Sheet helpers ───────────────────────────────────────────
function SheetHeader({ title }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', justifyContent: 'center', padding: '12px 0 24px' }}>
        <div style={{
          width: 36, height: 4, borderRadius: 2,
          background: 'rgba(136,136,136,0.3)',
        }} />
      </div>
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '0 28px 32px',
      }}>
        <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>{title}</span>
        <span style={{ fontFamily: T.mono, fontSize: 13, color: T.muted, fontWeight: 500 }}>✕</span>
      </div>
    </div>
  );
}

function SheetInput({ value, onChange, placeholder, onSubmit }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center',
      margin: '0 28px 48px',
      border: `1px solid ${T.border}`,
    }}>
      <input
        value={value} onChange={(e) => onChange(e.target.value)}
        onKeyDown={(e) => e.key === 'Enter' && onSubmit()}
        placeholder={placeholder}
        style={{
          flex: 1, background: 'transparent', border: 0,
          padding: '18px 24px', color: T.ink, fontFamily: T.mono, fontSize: 11,
          outline: 'none',
        }}
      />
      <button onClick={onSubmit} style={{
        background: 'none', border: 0, padding: '0 24px 0 0',
        color: value.trim() ? T.ink : T.muted,
        fontFamily: T.mono, fontSize: 14, cursor: 'pointer', height: '100%',
      }}>+</button>
    </div>
  );
}

function Spinner() {
  return (
    <span style={{
      display: 'inline-block', width: 9, height: 9,
      border: `1.5px solid ${T.muted}`, borderTopColor: 'transparent',
      borderRadius: '50%', animation: 'spin 0.8s linear infinite',
    }} />
  );
}

// ─── Bonus screen: "you made it" empty/expired state ─────────
function ExpiredScreen() {
  return (
    <GrimShell>
      <TopChrome />
      <CountdownBody unit="days" expired={true} />
      <BottomChrome lifeCount={0} promptText={null} onOpenLife={() => {}} />
    </GrimShell>
  );
}

// ─── Bonus screen: Week-of-life grid (CountdownView) ─────────
function WeekGridScreen() {
  const totalWeeks = LIFE_EXPECTANCY * 52;
  const weeksLived = WEEKS_LIVED;
  const [hover, setHover] = React.useState(null);

  const livedYears = (weeksLived / 52).toFixed(1);

  return (
    <GrimShell>
      {/* tiny header — same chrome as other screens */}
      <div style={{ position: 'absolute', top: 60, left: 28, right: 28, zIndex: 10, display: 'flex', justifyContent: 'space-between' }}>
        <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>your life · in weeks</span>
        <span style={{ fontFamily: T.mono, fontSize: 11, color: T.muted }}>{livedYears}/{LIFE_EXPECTANCY}</span>
      </div>

      {/* centered block */}
      <div style={{
        position: 'absolute', inset: 0, padding: '0 28px',
        display: 'flex', flexDirection: 'column', justifyContent: 'center',
        gap: 20,
      }}>
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(52, 1fr)',
          gap: 1.5,
        }}>
          {Array.from({ length: totalWeeks }).map((_, i) => {
            let bg = T.surface;
            if (i < weeksLived) bg = 'rgba(136,136,136,0.5)';
            if (i === weeksLived) bg = T.accent;
            const isHover = hover === i;
            return (
              <div
                key={i}
                onMouseEnter={() => setHover(i)}
                onMouseLeave={() => setHover(h => (h === i ? null : h))}
                style={{
                  aspectRatio: '1 / 1', background: bg, borderRadius: 1,
                  outline: isHover ? `1px solid ${T.ink}` : 'none',
                  outlineOffset: 1, cursor: 'pointer',
                  transition: 'outline-color 0.1s',
                }}
              />
            );
          })}
        </div>

        {/* readout — populated on hover, otherwise current-week summary */}
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end',
          fontFamily: T.mono, fontSize: 11, color: T.muted,
        }}>
          <span>
            {hover !== null
              ? `week ${fmt(hover + 1)} · age ${(hover / 52).toFixed(1)}`
              : `week ${fmt(weeksLived + 1)} · this week`}
          </span>
          <span>{fmt(totalWeeks - weeksLived)} weeks left</span>
        </div>

        {/* legend */}
        <div style={{ display: 'flex', gap: 16, fontFamily: T.mono, fontSize: 11, color: T.muted }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 6, height: 6, background: 'rgba(136,136,136,0.5)' }} />
            lived
          </span>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 6, height: 6, background: T.accent }} />
            this week
          </span>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 6, height: 6, background: T.surface, outline: `1px solid ${T.border}` }} />
            ahead
          </span>
        </div>
      </div>
    </GrimShell>
  );
}

Object.assign(window, {
  Onboarding_Welcome, Onboarding_DOB, Onboarding_Life,
  MainCountdown, ExpiredScreen, WeekGridScreen,
  // for the focused canvas sheets variants below:
  Sheet, LifeListSheet, SettingsSheet, DayDetailSheet, GrimShell,
  TopChrome, BottomChrome, CountdownBody,
});
