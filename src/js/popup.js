document.addEventListener('DOMContentLoaded', async function() {
    const toggleButton = document.getElementById('toggleButton');
    const resetButton = document.getElementById('resetButton');
    const statusDot = document.getElementById('statusDot');
    const statusText = document.getElementById('statusText');
    const timeDisplay = document.getElementById('timeDisplay');
    const tabInfo = document.getElementById('tabInfo');

    // Get current tab
    const tabs = await browser.tabs.query({active: true, currentWindow: true});
    const currentTab = tabs[0];

    tabInfo.textContent = `Current tab: ${currentTab.title}`;

    function formatTime(seconds) {
        const hrs = Math.floor(seconds / 3600);
        const mins = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        return `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    }

    function updateUI(active, elapsedSeconds = 0) {
        if (active) {
            toggleButton.disabled = true;
            resetButton.classList.remove('hidden');
            statusDot.classList.add('active');
            statusText.textContent = 'Active';
            timeDisplay.textContent = formatTime(elapsedSeconds);
        } else {
            toggleButton.disabled = false;
            resetButton.classList.add('hidden');
            statusDot.classList.remove('active');
            statusText.textContent = 'Inactive';
            timeDisplay.textContent = '00:00:00';
        }
    }

    // Check initial state for current tab
    browser.runtime.sendMessage({
        command: "getState",
        tabId: currentTab.id
    }).then(response => {
        updateUI(response.isActive, response.elapsedTime);
    });

    // Update timer display every second
    setInterval(() => {
        browser.runtime.sendMessage({
            command: "getState",
            tabId: currentTab.id
        }).then(response => {
            if (response.isActive) {
                updateUI(true, response.elapsedTime);
            }
        });
    }, 1000);

    toggleButton.addEventListener('click', function() {
        browser.runtime.sendMessage({
            command: "startActivity",
            tabId: currentTab.id,
            url: currentTab.url
        }).then(response => {
            updateUI(response.isActive, response.elapsedTime);
        });
    });

    resetButton.addEventListener('click', function() {
        browser.runtime.sendMessage({
            command: "reset",
            tabId: currentTab.id
        }).then(response => {
            updateUI(false);
        });
    });
});