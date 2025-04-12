// DOM Elements
const maxEntriesInput = document.getElementById('maxEntries');
const maxAgeDaysInput = document.getElementById('maxAgeDays');
const isMonitoringEnabledInput = document.getElementById('isMonitoringEnabled');
const exportBtn = document.getElementById('exportBtn');
const importBtn = document.getElementById('importBtn');
const importFile = document.getElementById('importFile');
const clearBtn = document.getElementById('clearBtn');
const saveBtn = document.getElementById('saveBtn');
const resetBtn = document.getElementById('resetBtn');
const statusMessage = document.getElementById('statusMessage');

// Function to display status messages
function showStatusMessage(message, type = 'success') {
  statusMessage.textContent = message;
  statusMessage.className = `status-message ${type}`;
  setTimeout(() => {
    statusMessage.textContent = '';
    statusMessage.className = 'status-message';
  }, 3000);
}

// Variables
let defaultOptions = {
  maxEntries: 100,
  maxAgeDays: 30,
  isMonitoringEnabled: true
};

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  // Load settings
  await loadOptions();
  
  // Set up event listeners
  setupEventListeners();
});

// Load options from storage
async function loadOptions() {
  try {
    const options = await chrome.storage.local.get([
      // 'maxEntries', // Remove local storage
      // 'maxAgeDays', // Remove local storage
      'isMonitoringEnabled'
    ]);

    maxEntriesInput.value = options.maxEntries || defaultOptions.maxEntries;
    maxAgeDaysInput.value = options.maxAgeDays || defaultOptions.maxAgeDays;
    isMonitoringEnabledInput.checked = options.isMonitoringEnabled !== undefined ?
      options.isMonitoringEnabled : defaultOptions.isMonitoringEnabled;
  } catch (error) {
    console.error('Error loading options:', error);
    showStatusMessage('Error loading options', 'error');
  }
}

// Set up event listeners
function setupEventListeners() {
  // Save button
  saveBtn.addEventListener('click', saveOptions);
  
  // Reset button
  resetBtn.addEventListener('click', resetOptions);
  
  // Export button
  exportBtn.addEventListener('click', exportHistory);
  
  // Import button and file input
  importBtn.addEventListener('click', () => {
    importFile.click();
  });
  
  importFile.addEventListener('change', importHistory);
  
  // Clear button
  clearBtn.addEventListener('click', clearHistory);
}

// Save options
async function saveOptions() {
  const maxEntriesValue = parseInt(maxEntriesInput.value, 10);
  const maxAgeDaysValue = parseInt(maxAgeDaysInput.value, 10);

  if (isNaN(maxEntriesValue) || maxEntriesValue < 10 || maxEntriesValue > 1000) {
    showStatusMessage('Maximum entries must be a number between 10 and 1000', 'error');
    return;
  }

  if (isNaN(maxAgeDaysValue) || maxAgeDaysValue < 1 || maxAgeDaysValue > 365) {
    showStatusMessage('Maximum age must be a number between 1 and 365 days', 'error');
    return;
  }

  if (maxEntriesValue === 0) {
    showStatusMessage('Maximum entries cannot be zero', 'error');
    return;
  }

  if (maxAgeDaysValue === 0) {
    showStatusMessage('Maximum age cannot be zero', 'error');
    return;
  }
  
  try {
    // Save options to storage
    await chrome.storage.local.set({
      maxEntries: maxEntriesValue,
      maxAgeDays: maxAgeDaysValue,
      isMonitoringEnabled: isMonitoringEnabledInput.checked
    });
    
    // Update background script
    chrome.runtime.sendMessage({
      action: 'updateOptions',
      options: {
        maxEntries: maxEntriesValue,
        maxAgeDays: maxAgeDaysValue,
        isMonitoringEnabled: isMonitoringEnabledInput.checked
      }
    }, response => {
      if (response && response.success) {
        showStatusMessage('Options saved successfully');
      } else {
        showStatusMessage('Error saving options', 'error');
      }
    });
  } catch (error) {
    console.error('Error saving options:', error);
    showStatusMessage('Error saving options', 'error');
  }
}

// Reset options to defaults
function resetOptions() {
  if (confirm('Are you sure you want to reset all options to default?')) {
    // Reset options to default values
    maxEntriesInput.value = 100;
    maxAgeDaysInput.value = 30;
    isMonitoringEnabledInput.checked = true;

    saveOptions(); // Save the reset options
  }
}

// Export clipboard history
async function exportHistory() {
  try {
    const data = await chrome.storage.local.get(['clipboardHistory']);
    
    if (!data.clipboardHistory || data.clipboardHistory.length === 0) {
      showStatusMessage('No clipboard history to export', 'warning');
      return;
    }
    
    // Create JSON file
    const json = JSON.stringify(data.clipboardHistory, null, 2);
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    // Create download link
    const a = document.createElement('a');
    a.href = url;
    a.download = `clipboard-history-${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    
    // Clean up
    URL.revokeObjectURL(url);
    showStatusMessage('Clipboard history exported successfully');
  } catch (error) {
    console.error('Error exporting history:', error);
    showStatusMessage('Error exporting history', 'error');
  }
}

// Import clipboard history
function importHistory(event) {
  const file = event.target.files[0];
  if (!file) {
    return;
  }
  
  const reader = new FileReader();
  reader.onload = async (e) => {
    try {
      const json = e.target.result;
      let importedHistory;
      try {
        importedHistory = JSON.parse(json);
      } catch (e) {
        showStatusMessage('Invalid JSON format', 'error');
        return;
      }
      
      if (!Array.isArray(importedHistory)) {
        showStatusMessage('Invalid file format', 'error');
        return;
      }
      
      // Validate imported data
      const validHistory = importedHistory.filter(item => {
        return item && 
               typeof item === 'object' && 
               typeof item.text === 'string' && 
               typeof item.timestamp === 'number';
      });
      
      if (validHistory.length === 0) {
        showStatusMessage('No valid clipboard entries found', 'error');
        return;
      }
      
      if (confirm(`Import ${validHistory.length} clipboard entries?`)) {
        // Get current history
        const currentHistoryData = await chrome.storage.local.get(['clipboardHistory']);
        let currentHistory = currentHistoryData.clipboardHistory || [];
        
        // Merge histories (avoid duplicates by text)
        const mergedHistory = [...currentHistory];
        validHistory.forEach(validItem => {
          if (!mergedHistory.some(item => item.text === validItem.text)) {
            mergedHistory.push(validItem);
          }
        });

        // Sort by timestamp (newest first) and pinned status (pinned first)
        mergedHistory.sort((a, b) => {
          if (b.isPinned && !a.isPinned) return 1;
          if (!b.isPinned && a.isPinned) return -1;
          return b.timestamp - a.timestamp;
        });
        
        // Save merged history
        await chrome.storage.local.set({ clipboardHistory: mergedHistory });
        showStatusMessage(`Imported ${validHistory.length} clipboard entries`);
      }
    } catch (error) {
      console.error('Error parsing clipboard history:', error);
      showStatusMessage('Error parsing clipboard history. Invalid JSON format.', 'error');
      return;
    }
    
    // Reset file input
    importFile.value = '';
  };
  
  reader.readAsText(file);
}

// Clear clipboard history
function clearHistory() {
  if (confirm('Are you sure you want to clear all clipboard history?')) {
    chrome.runtime.sendMessage({ action: 'clearClipboardHistory' }, response => {
      if (response && response.success) {
        showStatusMessage('Clipboard history cleared');
      } else {
        showStatusMessage('Error clearing clipboard history', 'error');
      }
    });
  }
}
