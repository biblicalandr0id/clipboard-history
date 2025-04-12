// DOM Elements
const clipboardList = document.getElementById('clipboardList');
const emptyState = document.getElementById('emptyState');
const searchInput = document.getElementById('searchInput');
const clearSearchBtn = document.getElementById('clearSearchBtn');
const clearAllBtn = document.getElementById('clearAllBtn');
const entryCount = document.getElementById('entryCount');
const optionsBtn = document.getElementById('optionsBtn');

// Variables
let clipboardHistory = [];
let filteredHistory = [];
let isPremium = false;

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  // Check premium status
  isPremium = await checkPremiumStatus();
  
  // Load clipboard history
  await loadClipboardHistory();
  
  // Set up event listeners
  setupEventListeners();
  
  // Update UI based on premium status
  updatePremiumUI();
});

// Load clipboard history
async function loadClipboardHistory() {
  try {
    const response = await chrome.runtime.sendMessage({ action: 'getClipboardHistory' });
    if (response && response.clipboardHistory) {
      clipboardHistory = response.clipboardHistory;
      filteredHistory = [...clipboardHistory];
      updateClipboardList();
    } else {
      console.error('Invalid response from background script');
      // Attempt direct storage access as fallback
      // const data = await chrome.storage.local.get(['clipboardHistory']); // Remove local storage
      // if (data.clipboardHistory) {
      //   clipboardHistory = data.clipboardHistory;
      //   filteredHistory = [...clipboardHistory];
      //   updateClipboardList();
      // }
    }
  } catch (error) {
    console.error('Error loading clipboard history:', error);
    // Show error state in UI
    emptyState.textContent = 'Error loading clipboard history. Please try reopening the popup.';
    emptyState.style.display = 'flex';
  }
}

// Update clipboard list in UI
function updateClipboardList() {
  // Sort filtered history with pinned items at the top
  filteredHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));

  // Update entry count
  entryCount.textContent = `${filteredHistory.length} entries`;

  // Show/hide empty state
  if (filteredHistory.length === 0) {
    emptyState.style.display = 'flex';
    clipboardList.innerHTML = '';
    return;
  } else {
    emptyState.style.display = 'none';
  }

  // Create HTML for clipboard items
  let fragment = document.createDocumentFragment(); // Use a document fragment for efficiency

  filteredHistory.forEach(item => {
    const pinnedClass = item.isPinned ? 'pinned' : '';
    const timeString = formatTime(item.timestamp);

    // Create elements
    let clipboardItem = document.createElement('div');
    clipboardItem.className = `clipboard-item ${pinnedClass}`;
    clipboardItem.dataset.text = escapeHtml(item.text);

    let clipboardActions = document.createElement('div');
    clipboardActions.className = 'clipboard-actions';

    let pinButton = document.createElement('button');
    pinButton.className = 'icon-button pin-button';
    pinButton.setAttribute('aria-label', item.isPinned ? 'Unpin' : 'Pin' + ' item');
    pinButton.textContent = item.isPinned ? '📌' : '📍';

    let deleteButton = document.createElement('button');
    deleteButton.className = 'icon-button delete-button';
    deleteButton.setAttribute('aria-label', 'Delete item');
    deleteButton.textContent = '🗑️';

    let clipboardContent = document.createElement('div');
    clipboardContent.className = 'clipboard-content';

    let clipboardText = document.createElement('div');
    clipboardText.className = 'clipboard-text';
    clipboardText.innerHTML = escapeHtml(item.text); // Set HTML content directly

    let clipboardTime = document.createElement('div');
    clipboardTime.className = 'clipboard-time';
    clipboardTime.textContent = timeString;

    // Append elements
    clipboardActions.appendChild(pinButton);
    clipboardActions.appendChild(deleteButton);

    clipboardContent.appendChild(clipboardText);
    clipboardContent.appendChild(clipboardTime);

    clipboardItem.appendChild(clipboardActions);
    clipboardItem.appendChild(clipboardContent);

    fragment.appendChild(clipboardItem);
  });

  clipboardList.innerHTML = ''; // Clear existing content
  clipboardList.appendChild(fragment); // Append the fragment to the list

  // Add event listeners to clipboard items
  const clipboardItems = clipboardList.querySelectorAll('.clipboard-item');
  clipboardItems.forEach(item => {
    // Click on item to copy
    item.addEventListener('click', event => {
      // Ignore clicks on buttons
      if (event.target.closest('.icon-button')) return;

      const text = item.dataset.text;
      copyToClipboard(text);
    });

    // Pin button click event
    const pinButton = item.querySelector('.pin-button');
    pinButton.addEventListener('click', event => {
      event.stopPropagation(); // Prevent item click
      const text = item.dataset.text;
      const clipboardItem = clipboardHistory.find(i => i.text === text);
      if (clipboardItem) {
        togglePinClipboardItem(text, !clipboardItem.isPinned);
      }
    });

    // Delete button click event
    const deleteButton = item.querySelector('.delete-button');
    deleteButton.addEventListener('click', event => {
      event.stopPropagation(); // Prevent item click
      const text = item.dataset.text;
      deleteClipboardItem(text);
    });
  });

  if (!isPremium && filteredHistory.length >= 5) {
    const limitMessage = document.createElement('div');
    limitMessage.className = 'empty-state';
    limitMessage.style.marginTop = '10px';
    limitMessage.style.color = '#f57c00';
    limitMessage.textContent = 'Upgrade to Pro for unlimited clipboard history!';
    clipboardList.appendChild(limitMessage);
  }
}

// Set up event listeners
function setupEventListeners() {
  // Search input
  searchInput.addEventListener('input', () => {
    const query = searchInput.value.trim().toLowerCase();
    clearSearchBtn.style.display = query ? 'block' : 'none'; // Show clear button if there is a query
    filteredHistory = clipboardHistory.filter(item =>
      item.text.toLowerCase().includes(query)
    ); // Filter history based on search query
    updateClipboardList();
  });

  // Clear search button
  clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    clearSearchBtn.style.display = 'none';
    filteredHistory = [...clipboardHistory]; // Reset to full history
    updateClipboardList();
  });

  // Clear all button
  clearAllBtn.addEventListener('click', () => {
    if (confirm('Are you sure you want to clear all clipboard history?')) {
      chrome.runtime.sendMessage({ action: 'clearClipboardHistory' }, response => {
        if (response.success) {
          clipboardHistory = [];
          filteredHistory = [];
          updateClipboardList();
        } else {
          console.error('Failed to clear clipboard history:', response.error);
          alert('Failed to clear clipboard history. Please try again.');
        }
      });
    }
  });

  // Options button
  optionsBtn.addEventListener('click', () => {
    chrome.runtime.openOptionsPage().catch(error => {
      console.error('Error opening options page:', error);
      alert('Could not open options page. Please try again.');
    });
  });
}

// Copy text to clipboard
function copyToClipboard(text) {
  chrome.runtime.sendMessage(
    { action: 'copyToClipboard', text: text },
    response => {
      if (chrome.runtime.lastError) {
        console.error("Could not copy text: ", chrome.runtime.lastError.message);
        alert("Failed to copy text. Please try again.");
      }
    }
  );
}

// Toggle pin status of clipboard item
function togglePinClipboardItem(text, isPinned) {
  chrome.runtime.sendMessage(
    { action: 'pinClipboardItem', text, isPinned },
    response => {
      if (response.success) {
        // Update local data
        const index = clipboardHistory.findIndex(item => item.text === text);
        if (index !== -1) {
          clipboardHistory[index].isPinned = isPinned;
        }

        // Update filtered history if needed
        const filteredIndex = filteredHistory.findIndex(item => item.text === text);
        if (filteredIndex !== -1) {
          filteredHistory[filteredIndex].isPinned = isPinned;
        }

        // Re-sort both clipboardHistory and filteredHistory to reflect the pin change
        clipboardHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
        filteredHistory.sort((a, b) => (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0));
        updateClipboardList();
      } else {
        console.error('Error pinning/unpinning item:', response.error);
        alert('Failed to pin/unpin item. Please try again.');
        // Optionally, revert the UI state if the operation failed
        loadClipboardHistory(); // Reload to ensure data consistency
      }
    }
  );
}

// Delete clipboard item
async function deleteClipboardItem(text) {
  try {
    const response = await chrome.runtime.sendMessage({ action: 'deleteClipboardItem', text });
    if (response.success) {
      // Update local dataardItem(text) {
      clipboardHistory = clipboardHistory.filter(item => item.text !== text);
      filteredHistory = filteredHistory.filter(item => item.text !== text);
      updateClipboardList();
    } else {
      throw new Error('Delete operation failed');
    }
  } catch (error) {
    console.error('Error deleting clipboard item:', error);
    // Reload the entire history to ensure consistency
    await loadClipboardHistory();
  }
}

// Helper function to format timestamp
function formatTime(timestamp) {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now - date;
  const diffSecs = Math.floor(diffMs / 1000);
  const diffMins = Math.floor(diffSecs / 60);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);
  if (diffDays > 0) {
    return `${diffDays}d ago`;
  } else if (diffHours > 0) {
    return `${diffHours}h ago`;
  } else if (diffMins > 0) {
    return `${diffMins}m ago`;
  } else {
    return 'Just now';
  }
}

// Helper function to escape HTML
function escapeHtml(text) {
  const div = document.createElement('div');  div.textContent = text;  return div.innerHTML;
}

// Add premium status check function
async function checkPremiumStatus() {
  try {
    return await chrome.runtime.sendMessage({ action: 'checkPremiumStatus' });
  } catch (error) {
    console.error('Error checking premium status:', error);
    return false;
  }
}

// Add premium UI update function
function updatePremiumUI() {
  const premiumBanner = document.createElement('div');
  premiumBanner.id = 'premiumBanner';
  premiumBanner.style.padding = '10px';
  premiumBanner.style.textAlign = 'center';
  premiumBanner.style.backgroundColor = isPremium ? '#e8f5e9' : '#fff3e0';
  premiumBanner.style.marginBottom = '10px';
  
  if (!isPremium) {
    premiumBanner.innerHTML = `
      <p style="margin: 0 0 10px 0">You're using the free version (limited to 5 items)</p>
      <button id="upgradeToPro" style="background: #4CAF50; color: white; border: none; padding: 5px 15px; border-radius: 4px; cursor: pointer">
        Upgrade to Pro
      </button>
    `;
  } else {
    premiumBanner.innerHTML = '<p style="margin: 0">Pro Version - Unlimited History</p>';
  }
  
  const container = document.querySelector('.container');
  container.insertBefore(premiumBanner, container.firstChild);
  
  if (!isPremium) {
    document.getElementById('upgradeToPro').addEventListener('click', () => {
      chrome.windows.create({
        url: chrome.runtime.getURL('payment/payment.html'),
        type: 'popup',
        width: 400,
        height: 600
      });
    });
  }
}