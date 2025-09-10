import React from 'react';
import ReactDOM from 'react-dom/client';
import './renderer.css';

const App: React.FC = () => {
  return (
    <div className="app">
      <div className="container">
        <div className="header">
          <h1 className="title">Glass Notification App</h1>
          <p className="subtitle">Sleek macOS-style notifications for text selection</p>
        </div>

        <div className="demo-area">
          <div className="demo-text">
            <strong>Try selecting any text on this page!</strong><br /><br />
            This is a demonstration of the glass notification system.
            Select any portion of this text to see the beautiful{' '}
            <span className="highlight">translucent notification</span> appear in the corner of your screen.
            The notification will automatically disappear after 3 seconds.
          </div>

          <div className="demo-text">
            You can also select text from:
            <ul style={{ margin: '10px 0', paddingLeft: '20px' }}>
              <li>This bullet point</li>
              <li>Or this other one</li>
              <li>And even this third option</li>
            </ul>
          </div>
        </div>

        <div className="instructions">
          <h3>How it works:</h3>
          <ul>
            <li>Text selection is detected automatically</li>
            <li>A glass translucent notification appears</li>
            <li>Notification shows a preview of selected text</li>
            <li>Automatically disappears after 3 seconds</li>
            <li>Works with any selectable text on the page</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

const root = ReactDOM.createRoot(document.getElementById('root')!);
root.render(<App />);
