class ClipboardFallback {
    static async clearHistory() {
        try {
            await chrome.storage.local.set({ clipboardHistory: [] });
            return true;
        } catch (error) {
            console.error('Failed to clear clipboard history:', error);
            return false;
        }
    }

    static async deleteEntry(id) {
        try {
            const { clipboardHistory } = await chrome.storage.local.get('clipboardHistory');
            const updatedHistory = clipboardHistory.filter(entry => entry.id !== id);
            await chrome.storage.local.set({ clipboardHistory: updatedHistory });
            return true;
        } catch (error) {
            console.error('Failed to delete clipboard entry:', error);
            return false;
        }
    }

    static async init() {
        // Add event listeners for clear and delete operations
        chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
            if (request.action === 'clearHistory') {
                this.clearHistory().then(sendResponse);
                return true;
            }
            if (request.action === 'deleteEntry') {
                this.deleteEntry(request.id).then(sendResponse);
                return true;
            }
        });
    }
}

// Initialize the fallback handler
ClipboardFallback.init();
