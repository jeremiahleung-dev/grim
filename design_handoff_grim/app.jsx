// grim — design canvas mounting all screens.

const { DesignCanvas, DCSection, DCArtboard } = window;

// Pre-built sheet snapshots: render the main countdown with a sheet open.
// We use MainCountdown's initial-state props.
function ScreenLifeListEmpty() {
  return <MainCountdown initialLife={[]} initialPrompt={null} initialSheet="life" />;
}
function ScreenLifeListFilled() {
  return <MainCountdown
    initialLife={[
      { id: '1', text: 'be a present brother to my sister' },
      { id: '2', text: 'learn to make pasta from scratch' },
      { id: '3', text: 'see the northern lights' },
      { id: '4', text: 'write something honest about my dad' },
      { id: '5', text: 'run a half marathon under 1:45' },
      { id: '6', text: 'finally read 100 years of solitude' },
      { id: '7', text: 'sleep under stars in the desert' },
      { id: '8', text: 'learn enough portuguese to get by' },
    ]}
    initialPrompt="today, text your sister and ask about her week. small check-ins are how you keep close people close — and you said you want to be a present brother."
    initialSheet="life"
  />;
}
function ScreenSettings() {
  return <MainCountdown initialSheet="settings" />;
}
function ScreenDayDetail() {
  return <MainCountdown initialSheet="day" />;
}
function ScreenMainWithPrompt() {
  return <MainCountdown
    initialLife={[
      { id: '1', text: 'be a present brother' },
      { id: '2', text: 'learn pasta' },
      { id: '3', text: 'northern lights' },
    ]}
    initialPrompt="today, text your sister and ask about her week. small check-ins are how you keep close people close."
  />;
}

function App() {
  // 390 × 844 = iPhone 15 frame from IOSDevice
  const W = 390, H = 844;
  return (
    <DesignCanvas
      title="grim"
      subtitle="memento mori — interactive prototype, faithful to the swift source"
    >
      <DCSection id="onboarding" title="onboarding">
        <DCArtboard id="ob-welcome" label="01 · welcome" width={W} height={H}>
          <Onboarding_Welcome />
        </DCArtboard>
        <DCArtboard id="ob-dob" label="02 · date of birth" width={W} height={H}>
          <Onboarding_DOB />
        </DCArtboard>
        <DCArtboard id="ob-life" label="03 · life expectancy" width={W} height={H}>
          <Onboarding_Life />
        </DCArtboard>
      </DCSection>

      <DCSection id="main" title="main · countdown" subtitle="swipe horizontally on the number to switch units · drag screens up via the prompt to open life list">
        <DCArtboard id="main-days" label="days · empty" width={W} height={H}>
          <MainCountdown initialUnit="days" />
        </DCArtboard>
        <DCArtboard id="main-prompt" label="days · with daily prompt" width={W} height={H}>
          <ScreenMainWithPrompt />
        </DCArtboard>
        <DCArtboard id="main-weeks" label="weeks" width={W} height={H}>
          <MainCountdown initialUnit="weeks" />
        </DCArtboard>
        <DCArtboard id="main-years" label="years" width={W} height={H}>
          <MainCountdown initialUnit="years" />
        </DCArtboard>
        <DCArtboard id="main-grid" label="bonus · 4,680 weeks of a life" width={W} height={H}>
          <WeekGridScreen />
        </DCArtboard>
      </DCSection>

      <DCSection id="sheets" title="sheets">
        <DCArtboard id="sheet-life-empty" label="life list · empty" width={W} height={H}>
          <ScreenLifeListEmpty />
        </DCArtboard>
        <DCArtboard id="sheet-life-filled" label="life list · with prompt" width={W} height={H}>
          <ScreenLifeListFilled />
        </DCArtboard>
        <DCArtboard id="sheet-day" label="day detail" width={W} height={H}>
          <ScreenDayDetail />
        </DCArtboard>
        <DCArtboard id="sheet-settings" label="settings" width={W} height={H}>
          <ScreenSettings />
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
