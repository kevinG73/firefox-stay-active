const tabStates = new Map();

class TabState {
    constructor(tabId, url) {
        this.tabId = tabId;
        this.url = url;
        this.isActive = false;
        this.startTime = null;
        this.elapsedSeconds = 0;
        this.intervalId = null;
        this.timerIntervalId = null;
    }

    start() {
        if (!this.isActive) {
            this.isActive = true;
            this.startTime = Date.now();
            this.intervalId = setInterval(() => this.simulateActivity(), 60000);
            this.timerIntervalId = setInterval(() => this.updateElapsedTime(), 1000);
        }
    }

    stop() {
        this.isActive = false;
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
        if (this.timerIntervalId) {
            clearInterval(this.timerIntervalId);
            this.timerIntervalId = null;
        }
        this.startTime = null;
        this.elapsedSeconds = 0;
    }

    simulateActivity() {
        browser.tabs.sendMessage(this.tabId, { command: "simulateActivity" });
    }

    updateElapsedTime() {
        if (this.startTime) {
            this.elapsedSeconds = Math.floor((Date.now() - this.startTime) / 1000);
        }
    }

    getState() {
        return {
            isActive: this.isActive,
            elapsedTime: this.elapsedSeconds
        };
    }
}

browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    const { command, tabId, url } = message;
    let tabState = tabStates.get(tabId);

    switch (command) {
        case "startActivity":
            if (!tabState) {
                tabState = new TabState(tabId, url);
                tabStates.set(tabId, tabState);
            }
            tabState.start();
            sendResponse(tabState.getState());
            break;

        case "reset":
            if (tabState) {
                tabState.stop();
                tabStates.delete(tabId);
            }
            sendResponse({ isActive: false, elapsedTime: 0 });
            break;

        case "getState":
            if (tabState) {
                sendResponse(tabState.getState());
            } else {
                sendResponse({ isActive: false, elapsedTime: 0 });
            }
            break;
    }
});

// Clean up when tabs are closed
browser.tabs.onRemoved.addListener((tabId) => {
    if (tabStates.has(tabId)) {
        const tabState = tabStates.get(tabId);
        tabState.stop();
        tabStates.delete(tabId);
    }
});

// Keep track of tab URL changes
browser.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.url && tabStates.has(tabId)) {
        const tabState = tabStates.get(tabId);
        tabState.stop();
        tabStates.delete(tabId);
    }
});