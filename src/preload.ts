import { contextBridge, ipcRenderer } from 'electron';

declare global {
  interface Window {
    electronAPI: {
      showNotification: (text: string) => void;
    };
  }
}

contextBridge.exposeInMainWorld('electronAPI', {
  showNotification: (text: string) => {
    ipcRenderer.send('show-notification', text);
  },
});

// Global text selection detection
let lastSelection = '';

function checkTextSelection() {
  const selection = window.getSelection();
  if (selection && selection.toString().trim()) {
    const selectedText = selection.toString().trim();
    if (selectedText !== lastSelection && selectedText.length > 0) {
      lastSelection = selectedText;
      window.electronAPI.showNotification(selectedText);
    }
  } else {
    lastSelection = '';
  }
}

// Listen for mouse up and key up events to detect text selection
document.addEventListener('mouseup', () => {
  setTimeout(checkTextSelection, 10); // Small delay to ensure selection is complete
});

document.addEventListener('keyup', (event) => {
  // Only check on arrow keys, space, or enter (common selection modifiers)
  if (['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', ' ', 'Enter'].includes(event.key)) {
    setTimeout(checkTextSelection, 10);
  }
});

// Also check periodically in case of programmatic selections
setInterval(checkTextSelection, 500);

