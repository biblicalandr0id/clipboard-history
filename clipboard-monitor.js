// Content script to monitor clipboard operations

// Listen for copy events
document.addEventListener('copy', function(event) {
  // Get the selection
  const selection = window.getSelection().toString();
  if (selection) {
    // Send the selected text to the background script
    chrome.runtime.sendMessage({
      action: 'capturedCopyEvent',
      text: selection
    });
  }
}, true);

// Listen for keyboard shortcuts
document.addEventListener('keydown', function(event) {
  // Check for Ctrl+C (or Command+C on Mac)
  if ((event.ctrlKey || event.metaKey) && event.key === 'c') {
    const selection = window.getSelection().toString();
    if (selection) {
      // Wait a small amount of time to ensure the copy operation completes
      setTimeout(() => {
        chrome.runtime.sendMessage({
          action: 'capturedCopyEvent',
          text: selection
        });
      }, 100);
    }
  }
}, true);

// Listen for cut events (also adds to clipboard)
document.addEventListener('cut', function(event) {
  const selection = window.getSelection().toString();
  if (selection) {
    chrome.runtime.sendMessage({
      action: 'capturedCopyEvent',
      text: selection
    });
  }
}, true);

// Listen for right-click context menu on editable elements
document.addEventListener('contextmenu', function(event) {
  // Note: We don't need to do anything here since Chrome handles
  // showing the appropriate context menu based on the target element
}, true);
