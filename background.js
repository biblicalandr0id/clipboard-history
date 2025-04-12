// Background script for Local Clipboard History extension
let clipboardHistory = [];
let maxEntries = 100;
let maxAgeDays = 30;
let isMonitoringEnabled = true;
let pasteMenuItems = []; // To track existing paste menu items
let fileSystemAccessGranted = false;
let clipboardHistoryFileHandle = null;
let lastCopyTime = 0;
const copyInterval = 500; // Minimum time between copies in ms
let saveInProgress = false; // Lock for save operations
let lastSaveAttempt = 0;
const SAVE_DEBOUNCE = 1000; // Minimum time between saves in ms

// Initialize the extension
chrome.runtime.onInstalled.addListener(async () => {
  try {
    // Load existing settings
    const data = await chrome.storage.local.get([
      'maxEntries',
      'maxAgeDays',
      'isMonitoringEnabled',
      'fileSystemAccessGranted'
    ]);

    // Update settings while preserving limits
    maxEntries = Math.min(Math.max(data.maxEntries || 100, 10), 1000);
    maxAgeDays = data.maxAgeDays || 30;
    isMonitoringEnabled = data.isMonitoringEnabled !== undefined ? data.isMonitoringEnabled : true;
    fileSystemAccessGranted = data.fileSystemAccessGranted || false;

    // Request file system access if needed
    if (!fileSystemAccessGranted) {
      const success = await requestFileSystemAccess();
      if (success) {
        fileSystemAccessGranted = true;
        await chrome.storage.local.set({ fileSystemAccessGranted: true });
      }
    }

    // Load existing history
    if (fileSystemAccessGranted) {
      try {
        const fileData = await loadClipboardHistoryFromFile();
        if (fileData && fileData.length > 0) {
          clipboardHistory = fileData.slice(0, maxEntries);
        }
      } catch (error) {
        console.error('Error loading from file system:', error);
      }
    }

    // Create context menu items
    await setupContextMenus();
    
    // Start monitoring
    startClipboardMonitoring();
  } catch (error) {
    console.error('Error during initialization:', error);
    // Attempt recovery
    await recoveryProcedure();
  }
});

// New initialization function
async function initializeHistoryAndSettings() {
  try {
    // Load settings from storage
    const data = await chrome.storage.local.get([
      'clipboardHistory',
      'fileSystemAccessGranted',
      'maxEntries',
      'maxAgeDays',
      'isMonitoringEnabled'
    ]);

    // Update settings
    fileSystemAccessGranted = data.fileSystemAccessGranted || false;
    maxEntries = Math.min(Math.max(data.maxEntries || 100, 10), 1000);
    maxAgeDays = data.maxAgeDays || 30;
    isMonitoringEnabled = data.isMonitoringEnabled !== undefined ? data.isMonitoringEnabled : true;

    // First try to load from file system
    if (fileSystemAccessGranted) {
      try {
        const fileData = await loadClipboardHistoryFromFile();
        if (fileData && fileData.length > 0) {
          clipboardHistory = fileData.slice(0, maxEntries);
          // Backup to local storage
          await chrome.storage.local.set({ clipboardHistory });
          return;
        }
      } catch (error) {
        console.error('Error loading from file system:', error);
      }
    }

    // Fall back to storage if file system fails or is empty
    if (data.clipboardHistory && data.clipboardHistory.length > 0) {
      clipboardHistory = data.clipboardHistory.slice(0, maxEntries);
    }
  } catch (error) {
    console.error('Error in initialization:', error);
    throw error;
  }
}

// New recovery procedure
async function recoveryProcedure() {
  try {
    // Reset file system access
    fileSystemAccessGranted = false;
    await chrome.storage.local.set({ fileSystemAccessGranted: false });

    // Load from local storage backup
    const data = await chrome.storage.local.get(['clipboardHistory']);
    if (data.clipboardHistory) {
      clipboardHistory = data.clipboardHistory;
    }

    // Request new file system access
    await requestFileSystemAccess();
  } catch (error) {
    console.error('Recovery procedure failed:', error);
  }
}

// Ensure clipboard history is loaded on startup
chrome.runtime.onStartup.addListener(async () => {
  try {
    // First check local storage
    const data = await chrome.storage.local.get(['clipboardHistory', 'fileSystemAccessGranted', 'maxEntries', 'maxAgeDays', 'isMonitoringEnabled']);
    clipboardHistory = data.clipboardHistory || [];
    fileSystemAccessGranted = data.fileSystemAccessGranted || false;
    maxEntries = Math.min(Math.max(data.maxEntries || 100, 10), 1000);
    maxAgeDays = data.maxAgeDays || 30;
    isMonitoringEnabled = data.isMonitoringEnabled !== undefined ? data.isMonitoringEnabled : true;

    // Then check file storage if available
    if (fileSystemAccessGranted) {
      try {
        const fileData = await loadClipboardHistoryFromFile();
        if (fileData && fileData.length > 0) {
          clipboardHistory = fileData.slice(0, maxEntries);
        }
      } catch (error) {
        console.error('Error loading clipboard history from file:', error);
      }
    }

    updatePasteMenuItems(); // Update context menu with loaded history
  } catch (error) {
    console.error('Error loading clipboard history on startup:', error);
  }
});

// Listen for context menu clicks
chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "copyToClipboard" && info.selectionText) {
    addToClipboardHistory(info.selectionText);
  } else if (info.menuItemId.startsWith("paste_")) {
    const itemIndex = parseInt(info.menuItemId.split("_")[1], 10);
    if (!isNaN(itemIndex) && itemIndex >= 0 && itemIndex < clipboardHistory.length) {
      pasteTextInActiveElement(tab.id, clipboardHistory[itemIndex].text);
    }
  }
});

// File System Access API functions
async function requestFileSystemAccess() {
  // Check if the code is running in a secure context
  if (location.protocol !== 'https:') {
    console.warn('File system access requires a secure context (HTTPS).');
    return false;
  }

  try {
    // Show file picker and get handle
    const filePickerOptions = {
      suggestedName: 'clipboard_history.json',
      types: [{
        description: 'JSON File',
        accept: {'application/json': ['.json']}
      }]
    };
    
    // Use existing handle if available and valid
    if (!clipboardHistoryFileHandle) {
      clipboardHistoryFileHandle = await window.showSaveFilePicker(filePickerOptions);
    }
    
    // Check if handle is still valid
    if (!clipboardHistoryFileHandle) {
      console.warn('File system access was not granted or handle is invalid.');
      fileSystemAccessGranted = false;
      await chrome.storage.local.set({ fileSystemAccessGranted: false });
      return false;
    }
    
    // Save flag that permission was granted
    fileSystemAccessGranted = true;
    await chrome.storage.local.set({ fileSystemAccessGranted });
    return true;
  } catch (error) {
    console.error('Error getting file permission:', error);
    fileSystemAccessGranted = false;
    await chrome.storage.local.set({ fileSystemAccessGranted: false });
    return false;
  }
}

async function saveClipboardHistoryToFile() {
  if (saveInProgress || !fileSystemAccessGranted) {
    return false;
  }

  const now = Date.now();
  if (now - lastSaveAttempt < SAVE_DEBOUNCE) {
    return false;
  }

  saveInProgress = true;
  lastSaveAttempt = now;

  try {
    // Always backup to local storage first
    await chrome.storage.local.set({ clipboardHistory });

    // Then try file system
    if (!clipboardHistoryFileHandle) {
      const success = await requestFileSystemAccess();
      if (!success) {
        saveInProgress = false;
        return false;
      }
    }

    const writable = await clipboardHistoryFileHandle.createWritable();
    await writable.write(JSON.stringify(clipboardHistory.slice(0, maxEntries)));
    await writable.close();
    console.log('Clipboard history saved successfully');
    return true;
  } catch (error) {
    console.error('Error in save operation:', error);
    // Attempt recovery
    await recoveryProcedure();
    return false;
  } finally {
    saveInProgress = false;
  }
}

async function loadClipboardHistoryFromFile() {
  if (!fileSystemAccessGranted) {
    return null;
  }

  // Check if the file handle is valid; if not, request access again
  if (!clipboardHistoryFileHandle) {
    const success = await requestFileSystemAccess();
    if (!success) return null;
  }

  try {
    const file = await clipboardHistoryFileHandle.getFile();
    const contents = await file.text();
    let parsedData;
    try {
      parsedData = JSON.parse(contents);
    } catch (e) {
      console.error("Error parsing JSON from file:", e);
      return []; // Return empty array if JSON is invalid
    }

    // Ensure each item has the isPinned property
    if (Array.isArray(parsedData)) {
      return parsedData.map(item => ({
        ...item,
        isPinned: item.isPinned === undefined ? false : item.isPinned // Default to false if undefined
      }));
    } else {
      console.warn("Loaded data is not an array, returning empty history.");
      return [];
    }
  } catch (error) {
    console.error('Error reading clipboard history file:', error);

    // If an error occurs, it might be because the file handle is invalid.
    // Attempt to re-request file system access and retry loading.
    console.log('Attempting to re-request file system access...');
    const success = await requestFileSystemAccess();
    if (success) {
      try {
        const file = await clipboardHistoryFileHandle.getFile();
        const contents = await file.text();
        let parsedData;
        try {
          parsedData = JSON.parse(contents);
        } catch (e) {
          console.error("Error parsing JSON from file:", e);
          return []; // Return empty array if JSON is invalid
        }

        // Ensure each item has the isPinned property
        if (Array.isArray(parsedData)) {
          return parsedData.map(item => ({
            ...item,
            isPinned: item.isPinned === undefined ? false : item.isPinned // Default to false if undefined
          }));
        } else {
          console.warn("Loaded data is not an array, returning empty history.");
          return [];
        }
      } catch (retryError) {
        console.error('Error reading clipboard history file after re-request:', retryError);
        return null;
      }
    } else {
      console.error('Failed to re-request file system access.');
      return null;
    }
  }
}

// Update the paste menu items based on clipboard history
async function updatePasteMenuItems() {
  // First remove all existing paste menu items that we've tracked
  for (const itemId of pasteMenuItems) {
    try {
      await chrome.contextMenus.remove(itemId);
    } catch (error) {
      console.error(`Error removing menu item ${itemId}:`, error);
    }
  }

  // Clear the tracking array
  pasteMenuItems = [];

  // Add new paste menu items (limited to 10 items to avoid cluttering)
  const displayLimit = Math.min(clipboardHistory.length, 10);
  for (let i = 0; i < displayLimit; i++) {
    const item = clipboardHistory[i];
    // Truncate text for display in menu
    let displayText = item.text.substring(0, 50).replace(/\n/g, ' ');
    if (item.text.length > 50) displayText += "...";

    const menuId = `paste_${i}`;
    try {
      chrome.contextMenus.create({
        id: menuId,
        parentId: "pasteFromClipboard",
        title: displayText,
        contexts: ["editable"]
      });
      pasteMenuItems.push(menuId);
    } catch (error) {
      console.error(`Error creating menu item ${menuId}:`, error);
    }
  }
}

// Monitor clipboard changes
async function startClipboardMonitoring() {
  // Listen for copy events from content script
  console.log("Clipboard monitoring started");

  // Check if the content script is already registered
  const registeredScripts = await chrome.scripting.getRegisteredContentScripts({
    ids: ['clipboard-monitor']
  });

  if (!registeredScripts || registeredScripts.length === 0) {
    // Inject content script to listen for copy events on all pages
    chrome.scripting.registerContentScripts([{
      id: 'clipboard-monitor',
      matches: ['<all_urls>'],
      js: ['clipboard-monitor.js'],
      runAt: 'document_start'
    }]);
  }
}

// Function to paste text in the active element
function pasteTextInActiveElement(tabId, text) {
  chrome.scripting.executeScript({
    target: { tabId: tabId },
    func: (textToPaste) => {
      const activeElement = document.activeElement;
      if (activeElement && 
          (activeElement.tagName === 'INPUT' || 
           activeElement.tagName === 'TEXTAREA' || 
           activeElement.isContentEditable)) {
        
        // For input and textarea elements
        if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
          const start = activeElement.selectionStart || 0;
          const end = activeElement.selectionEnd || 0;
          const beforeText = activeElement.value.substring(0, start);
          const afterText = activeElement.value.substring(end);
          
          activeElement.value = beforeText + textToPaste + afterText;
          
          // Set cursor position after the pasted text
          const newPosition = start + textToPaste.length;
          activeElement.setSelectionRange(newPosition, newPosition);
          
          // Trigger input event
          const inputEvent = new Event('input', { bubbles: true });
          activeElement.dispatchEvent(inputEvent);
        } 
        // For contentEditable elements
        else if (activeElement.isContentEditable) {
          const selection = window.getSelection();
          if (selection.rangeCount > 0) {
            const range = selection.getRangeAt(0);
            range.deleteContents();
            range.insertNode(document.createTextNode(textToPaste));
            
            // Move cursor after the pasted text
            range.collapse(false);
            selection.removeAllRanges();
            selection.addRange(range);
            
            // Trigger input event
            const inputEvent = new Event('input', { bubbles: true });
            activeElement.dispatchEvent(inputEvent);
          }
        }
      }
    },
    args: [text]
  });
}

/**
 * Adds text to the clipboard history.
 * @param {string} text - The text to add to the clipboard history.
 */
async function addToClipboardHistory(text) {
  const currentTime = Date.now();
  if (currentTime - lastCopyTime < copyInterval) {
    console.log("Rate limited clipboard write");
    return;
  }
  lastCopyTime = currentTime;
  // Check if text is already in history
  const existingIndex = clipboardHistory.findIndex(item => item.text === text);

  if (existingIndex !== -1) {
    // If item is pinned, keep it pinned
    const isPinned = clipboardHistory[existingIndex].isPinned;
    // Remove the existing entry
    clipboardHistory.splice(existingIndex, 1);
    // Add it back with the same pinned status but updated timestamp
    clipboardHistory.unshift({
      text: text,
      timestamp: Date.now(),
      isPinned: isPinned
    });
  } else {
    // Add new entry to the beginning
    clipboardHistory.unshift({
      text: text,
      timestamp: Date.now(),
      isPinned: false
    });
  }

  // Trim history if needed
  if (clipboardHistory.length > maxEntries) {
    // Keep pinned items
    const pinnedItems = clipboardHistory.filter(item => item.isPinned);
    const unpinnedItems = clipboardHistory.filter(item => !item.isPinned);

    // Remove oldest unpinned items until we're under maxEntries
    while (pinnedItems.length + unpinnedItems.length > maxEntries) {
      unpinnedItems.pop();
    }

    // Reconstruct the history with pinned items first
    clipboardHistory = [...pinnedItems, ...unpinnedItems];
  } else {
    // Ensure pinned items are at the top
    clipboardHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
  }

  // Persist to storage immediately
  try {
    // Ensure pinned items are at the top before saving
    clipboardHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));

    // Then try to save to file if we have permission
    if (fileSystemAccessGranted) {
      const saveSuccess = await saveClipboardHistoryToFile();
      if (!saveSuccess) {
        console.error('Failed to save clipboard history to file.');
      }
    }

    // Update context menu after successful storage
    updatePasteMenuItems();
  } catch (error) {
    console.error('Error saving clipboard history:', error);
  }
}

// Cleanup old entries based on age
async function cleanupOldEntries() {
  const now = Date.now();
  const maxAge = maxAgeDays * 24 * 60 * 60 * 1000; // Convert days to milliseconds

  // Keep pinned items and items within max age
  const filteredHistory = clipboardHistory.filter(item =>
    item.isPinned || (now - item.timestamp) <= maxAge
  );

  if (filteredHistory.length !== clipboardHistory.length) {
    clipboardHistory = filteredHistory;
    // Ensure pinned items are at the top
    clipboardHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
    // Persist changes
    try {
      // Save to Chrome storage
      // await chrome.storage.local.set({ clipboardHistory }); // Remove local storage

      // Save to file if we have permission
      if (fileSystemAccessGranted) {
        await saveClipboardHistoryToFile();
      }

      updatePasteMenuItems();
    } catch (error) {
      console.error('Error saving cleaned clipboard history:', error);
    }
  }
    // Ensure pinned items are at the top before saving
    clipboardHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
}

// Run cleanup periodically (once per hour)
setInterval(cleanupOldEntries, 60 * 60 * 1000);

// Check payment status before performing premium operations
async function isPremiumUser() {
  const { isPaid } = await chrome.storage.sync.get(['isPaid']);
  return isPaid === true;
}

// Listen for messages from popup or options pages
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "getClipboardHistory") {
    handleGetClipboardHistory(sendResponse);
    return true;
  } else if (request.action === "copyToClipboard") {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(request.text)
        .then(() => {
          console.log("Text copied successfully:", request.text);
          sendResponse({ success: true });
        })
        .catch(err => {
          console.error("Failed to copy text using clipboard API:", err);
          sendResponse({ success: false, error: err.message });
        });
    } else {
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0]?.id && tabs[0].url && !tabs[0].url.startsWith("chrome://")) {
          chrome.tabs.sendMessage(tabs[0].id, { action: "fallbackCopyToClipboard", text: request.text }, (response) => {
            if (chrome.runtime.lastError) {
              console.error("Error communicating with content script:", chrome.runtime.lastError.message);
              sendResponse({ success: false, error: chrome.runtime.lastError.message });
            } else {
              sendResponse(response);
            }
          });
        } else {
          console.error("Cannot execute fallback copy in restricted context or no active tab found.");
          sendResponse({ success: false, error: "Cannot execute fallback copy in restricted context or no active tab found." });
        }
      });
    }
    return true; // Required for async response
  } else if (request.action === "checkPremiumStatus") {
    isPremiumUser().then(sendResponse);
    return true;
  } else if (request.action === "pinClipboardItem") {
    const index = clipboardHistory.findIndex(item => item.text === request.text);
    if (index !== -1) {
      clipboardHistory[index].isPinned = request.isPinned;
      Promise.all([
        fileSystemAccessGranted ? saveClipboardHistoryToFile() : Promise.resolve()
      ])
        .then(() => {
          updatePasteMenuItems();
          sendResponse({ success: true });
        })
        .catch(err => {
          console.error('Error saving pinned item:', err);
          sendResponse({ success: false, error: err.message });
        });
    } else {
      sendResponse({ success: false, error: "Item not found" });
    }
    return true; // Required for async response
  } else if (request.action === "deleteClipboardItem") {
    clipboardHistory = clipboardHistory.filter(item => item.text !== request.text);
    Promise.all([
      fileSystemAccessGranted ? saveClipboardHistoryToFile() : Promise.resolve()
    ])
      .then(() => {
        updatePasteMenuItems();
        sendResponse({ success: true });
      })
      .catch(err => {
        console.error('Error deleting clipboard item:', err);
        sendResponse({ success: false, error: err.message });
      });
    return true; // Required for async response
  } else if (request.action === "clearClipboardHistory") {
    clipboardHistory = [];
    Promise.all([
      fileSystemAccessGranted ? saveClipboardHistoryToFile() : Promise.resolve()
    ])
      .then(() => {
        updatePasteMenuItems();
        sendResponse({ success: true });
      })
      .catch(err => sendResponse({ success: false, error: err.message }));
    return true; // Required for async response
  } else if (request.action === "updateOptions") {
    chrome.storage.local.set({
      maxEntries: request.options.maxEntries || maxEntries,
      maxAgeDays: request.options.maxAgeDays || maxAgeDays,
      isMonitoringEnabled: request.options.isMonitoringEnabled
    })
      .then(() => {
        maxEntries = request.options.maxEntries || maxEntries;
        maxAgeDays = request.options.maxAgeDays || maxAgeDays;
        isMonitoringEnabled = request.options.isMonitoringEnabled;
        cleanupOldEntries();
        sendResponse({ success: true });
      })
      .catch(err => sendResponse({ success: false, error: err.message }));
    return true; // Required for async response
  } else if (request.action === "capturedCopyEvent") {
    if (isMonitoringEnabled && request.text) {
      addToClipboardHistory(request.text);
    }
    sendResponse({ success: true });
    return true;
  } else if (request.action === "requestFileSystemAccess") {
    requestFileSystemAccess()
      .then(success => {
        if (success && clipboardHistory.length > 0) {
          return saveClipboardHistoryToFile();
        }
        return success;
      })
      .then(success => sendResponse({ success }))
      .catch(err => sendResponse({ success: false, error: err.message }));
    return true; // Required for async response
  } else if (request.action === "checkFileSystemAccess") {
    sendResponse({ fileSystemAccessGranted });
    return false; // Synchronous response
  } else {
    sendResponse({ success: false, error: "Unhandled action" });
  }
});

// Modify clipboard operations to respect premium limits
async function handleGetClipboardHistory(sendResponse) {
  try {
    const isPremium = await isPremiumUser();
    const { clipboardHistory = [] } = await chrome.storage.local.get(['clipboardHistory']);
    
    // If not premium, limit to last 5 items
    const limitedHistory = isPremium ? clipboardHistory : clipboardHistory.slice(0, 5);
    sendResponse({ clipboardHistory: limitedHistory });
  } catch (error) {
    console.error('Error in handleGetClipboardHistory:', error);
    sendResponse({ error: 'Failed to get clipboard history' });
  }
}

async function handleAddToClipboard(text, sendResponse) {
  try {
    const isPremium = await isPremiumUser();
    const { clipboardHistory = [] } = await chrome.storage.local.get(['clipboardHistory']);
    
    // Remove duplicates
    const newHistory = clipboardHistory.filter(item => item.text !== text);
    
    // Add new item at the beginning
    newHistory.unshift({
      text,
      timestamp: Date.now(),
      isPinned: false
    });
    
    // If not premium, limit to 5 items
    if (!isPremium) {
      newHistory.splice(5);
    }
    
    await chrome.storage.local.set({ clipboardHistory: newHistory });
    sendResponse({ success: true });
  } catch (error) {
    console.error('Error in handleAddToClipboard:', error);
    sendResponse({ error: 'Failed to add to clipboard' });
  }
}

// Prevent unintentional history wipes by saving to the file system on tab switches and window focus changes
chrome.tabs.onActivated.addListener(() => {
  if (fileSystemAccessGranted) {
    saveClipboardHistoryToFile().catch(err => {
      console.error("Error saving clipboard history to file on tab switch:", err);
    });
  }
});

chrome.windows.onFocusChanged.addListener(() => {
  if (fileSystemAccessGranted) {
    saveClipboardHistoryToFile().catch(err => {
      console.error("Error saving clipboard history to file on window focus change:", err);
    });
  }
});

// Load clipboard history from the file system or local storage on startup
chrome.runtime.onStartup.addListener(() => {
  if (fileSystemAccessGranted) {
    loadClipboardHistoryFromFile().then(data => {
      if (data) {
        clipboardHistory = data.slice(0, maxEntries);
      }
    }).catch(err => {
      console.error("Error loading clipboard history from file on startup:", err);
    });
  } else {
    chrome.storage.local.get("clipboardHistory").then(data => {
      if (data.clipboardHistory) {
        clipboardHistory = data.clipboardHistory.slice(0, maxEntries);
      }
    }).catch(err => {
      console.error("Error loading clipboard history from local storage on startup:", err);
    });
  }
});

// Ensure history is saved on important events
window.addEventListener('beforeunload', () => {
  if (fileSystemAccessGranted) {
    saveClipboardHistoryToFile();
  }
});

chrome.runtime.onSuspend.addListener(() => {
  if (fileSystemAccessGranted && clipboardHistory.length > 0) {
    saveClipboardHistoryToFile();
  }
});