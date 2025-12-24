let currentTab = 'live';
let isLive = false;
let currentTrack = null;
let trackProgress = 0;
let listeners = 0;
let musicLibrary = [];
let queue = [];
let schedule = {};

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    initializeRadioData();
    updateBroadcastStatus();
});

// Set up event listeners
function setupEventListeners() {
    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeRadio);

    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            switchTab(this.dataset.tab);
        });
    });

    // Live tab controls
    document.getElementById('startBroadcastBtn').addEventListener('click', startBroadcast);
    document.getElementById('stopBroadcastBtn').addEventListener('click', stopBroadcast);
    document.getElementById('emergencyOffBtn').addEventListener('click', emergencyStop);
    document.getElementById('micToggleBtn').addEventListener('click', toggleMic);
    document.getElementById('micVolume').addEventListener('input', updateMicVolume);

    // Music tab controls
    document.getElementById('searchBtn').addEventListener('click', searchMusic);
    document.getElementById('musicSearch').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchMusic();
        }
    });
    document.getElementById('genreFilter').addEventListener('change', filterByGenre);
    document.getElementById('shuffleBtn').addEventListener('click', shuffleQueue);
    document.getElementById('clearQueueBtn').addEventListener('click', clearQueue);

    // Schedule tab controls
    document.getElementById('addShowBtn').addEventListener('click', addNewShow);
    document.getElementById('editScheduleBtn').addEventListener('click', editSchedule);

    // Management tab controls
    document.getElementById('addStaffBtn').addEventListener('click', addStaffMember);
    document.getElementById('saveSettingsBtn').addEventListener('click', saveStationSettings);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeRadio();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openRadio':
                openRadio();
                break;
            case 'closeRadio':
                closeRadio();
                break;
            case 'updateListeners':
                updateListenerCount(data.count);
                break;
            case 'updateTrack':
                updateCurrentTrack(data.track);
                break;
            case 'updateMusicLibrary':
                updateMusicLibrary(data.library);
                break;
            case 'updateSchedule':
                updateSchedule(data.schedule);
                break;
            case 'broadcastStatusChanged':
                handleBroadcastStatusChange(data.status);
                break;
        }
    });
}

// Tab switching
function switchTab(tabName) {
    currentTab = tabName;
    
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.tab === tabName) {
            btn.classList.add('active');
        }
    });
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');
    
    // Tab-specific initialization
    if (tabName === 'music') {
        loadMusicLibrary();
    } else if (tabName === 'schedule') {
        loadSchedule();
    } else if (tabName === 'management') {
        loadManagementData();
    }
}

// Open radio interface
function openRadio() {
    document.getElementById('container').classList.remove('hidden');
    sendCallback('radio:opened', {});
}

// Close radio interface
function closeRadio() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('radio:closed', {});
}

// Initialize radio data
function initializeRadioData() {
    musicLibrary = [
        { id: 1, title: "Sample Song 1", artist: "Sample Artist", duration: "3:45", genre: "pop" },
        { id: 2, title: "Rock Anthem", artist: "Rock Band", duration: "4:12", genre: "rock" },
        { id: 3, title: "Jazz Evening", artist: "Jazz Ensemble", duration: "5:30", genre: "jazz" },
        { id: 4, title: "Electronic Beats", artist: "DJ Producer", duration: "3:20", genre: "electronic" },
        { id: 5, title: "Country Road", artist: "Country Singer", duration: "3:55", genre: "country" }
    ];
    
    loadMusicLibrary();
}

// Broadcast controls
function startBroadcast() {
    isLive = true;
    updateBroadcastStatus();
    
    document.getElementById('startBroadcastBtn').disabled = true;
    document.getElementById('stopBroadcastBtn').disabled = false;
    
    sendCallback('radio:startBroadcast', {});
    showNotification('Broadcast started successfully!', 'success');
}

function stopBroadcast() {
    isLive = false;
    updateBroadcastStatus();
    
    document.getElementById('startBroadcastBtn').disabled = false;
    document.getElementById('stopBroadcastBtn').disabled = true;
    
    sendCallback('radio:stopBroadcast', {});
    showNotification('Broadcast stopped', 'info');
}

function emergencyStop() {
    isLive = false;
    updateBroadcastStatus();
    
    document.getElementById('startBroadcastBtn').disabled = false;
    document.getElementById('stopBroadcastBtn').disabled = true;
    
    sendCallback('radio:emergencyStop', {});
    showNotification('Emergency stop activated!', 'error');
}

function toggleMic() {
    const micBtn = document.getElementById('micToggleBtn');
    const micText = micBtn.querySelector('.mic-text');
    
    if (micBtn.classList.contains('active')) {
        micBtn.classList.remove('active');
        micText.textContent = 'Go Live';
        sendCallback('radio:micOff', {});
        showNotification('Microphone off', 'info');
    } else {
        micBtn.classList.add('active');
        micText.textContent = 'On Air';
        sendCallback('radio:micOn', {});
        showNotification('You are now on air!', 'success');
    }
}

function updateMicVolume() {
    const volume = document.getElementById('micVolume').value;
    document.getElementById('micVolumeValue').textContent = volume + '%';
    sendCallback('radio:micVolume', { volume: volume });
}

// Update broadcast status
function updateBroadcastStatus() {
    const statusDot = document.querySelector('.status-dot');
    const statusText = document.querySelector('.status-text');
    
    if (isLive) {
        statusDot.classList.remove('offline');
        statusDot.classList.add('online');
        statusText.textContent = 'LIVE';
    } else {
        statusDot.classList.remove('online');
        statusDot.classList.add('offline');
        statusText.textContent = 'OFFLINE';
    }
}

// Update listener count
function updateListenerCount(count) {
    listeners = count;
    document.getElementById('listenerCount').textContent = count;
}

// Update current track
function updateCurrentTrack(track) {
    currentTrack = track;
    document.getElementById('currentTrack').textContent = track.title || 'No track selected';
    document.getElementById('currentArtist').textContent = track.artist || '-';
    document.getElementById('currentTime').textContent = track.currentTime || '0:00';
    document.getElementById('totalTime').textContent = track.duration || '0:00';
    
    if (track.progress) {
        document.getElementById('trackProgress').style.width = track.progress + '%';
    }
}

// Music library functions
function loadMusicLibrary() {
    renderMusicLibrary(musicLibrary);
}

function renderMusicLibrary(tracks) {
    const libraryElement = document.getElementById('musicLibrary');
    
    if (tracks.length === 0) {
        libraryElement.innerHTML = '<p style="text-align: center; color: #bdc3c7; padding: 40px;">No tracks found</p>';
        return;
    }
    
    let html = '';
    tracks.forEach(track => {
        html += `
            <div class="track-item">
                <div class="track-details">
                    <div class="track-name">${track.title}</div>
                    <div class="track-artist">${track.artist}</div>
                    <div class="track-duration">${track.duration}</div>
                </div>
                <div class="track-actions">
                    <button class="play-btn" onclick="playTrack('${track.id}')">▶</button>
                    <button class="queue-btn" onclick="addToQueue('${track.id}')">Add to Queue</button>
                </div>
            </div>
        `;
    });
    
    libraryElement.innerHTML = html;
}

function searchMusic() {
    const searchTerm = document.getElementById('musicSearch').value.toLowerCase();
    const filteredTracks = musicLibrary.filter(track => 
        track.title.toLowerCase().includes(searchTerm) ||
        track.artist.toLowerCase().includes(searchTerm)
    );
    renderMusicLibrary(filteredTracks);
}

function filterByGenre() {
    const selectedGenre = document.getElementById('genreFilter').value;
    let filteredTracks = musicLibrary;
    
    if (selectedGenre) {
        filteredTracks = musicLibrary.filter(track => track.genre === selectedGenre);
    }
    
    renderMusicLibrary(filteredTracks);
}

function playTrack(trackId) {
    const track = musicLibrary.find(t => t.id == trackId);
    if (track) {
        updateCurrentTrack(track);
        sendCallback('radio:playTrack', { track: track });
        showNotification(`Now playing: ${track.title}`, 'success');
    }
}

function addToQueue(trackId) {
    const track = musicLibrary.find(t => t.id == trackId);
    if (track) {
        queue.push(track);
        updateQueueDisplay();
        sendCallback('radio:addToQueue', { track: track });
        showNotification(`Added to queue: ${track.title}`, 'info');
    }
}

function updateQueueDisplay() {
    const queueList = document.getElementById('queueList');
    
    if (queue.length === 0) {
        queueList.innerHTML = '<p class="empty-queue">Queue is empty</p>';
        return;
    }
    
    let html = '';
    queue.forEach((track, index) => {
        html += `
            <div class="track-item">
                <div class="track-details">
                    <div class="track-name">${track.title}</div>
                    <div class="track-artist">${track.artist}</div>
                </div>
                <button class="remove-btn" onclick="removeFromQueue(${index})">Remove</button>
            </div>
        `;
    });
    
    queueList.innerHTML = html;
}

function removeFromQueue(index) {
    queue.splice(index, 1);
    updateQueueDisplay();
    sendCallback('radio:updateQueue', { queue: queue });
}

function shuffleQueue() {
    for (let i = queue.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [queue[i], queue[j]] = [queue[j], queue[i]];
    }
    updateQueueDisplay();
    sendCallback('radio:shuffleQueue', { queue: queue });
    showNotification('Queue shuffled!', 'info');
}

function clearQueue() {
    queue = [];
    updateQueueDisplay();
    sendCallback('radio:clearQueue', {});
    showNotification('Queue cleared', 'info');
}

// Schedule functions
function loadSchedule() {
    // Schedule loading logic would go here
}

function addNewShow() {
    sendCallback('radio:addShow', {});
    showNotification('Add show dialog opened', 'info');
}

function editSchedule() {
    sendCallback('radio:editSchedule', {});
    showNotification('Schedule editor opened', 'info');
}

// Management functions
function loadManagementData() {
    // Update analytics with example data
    document.getElementById('todayListeners').textContent = '1,247';
    document.getElementById('peakListeners').textContent = '89';
    document.getElementById('broadcastTime').textContent = '18h 32m';
    document.getElementById('songsPlayed').textContent = '156';
}

function addStaffMember() {
    sendCallback('radio:addStaff', {});
    showNotification('Add staff dialog opened', 'info');
}

function saveStationSettings() {
    const settings = {
        stationName: document.getElementById('stationName').value,
        frequency: document.getElementById('stationFreq').value,
        maxListeners: document.getElementById('maxListeners').value,
        autoDJ: document.getElementById('autoDJ').value
    };
    
    sendCallback('radio:saveSettings', { settings: settings });
    showNotification('Station settings saved!', 'success');
}

// Update functions from FiveM
function updateMusicLibrary(library) {
    musicLibrary = library;
    if (currentTab === 'music') {
        loadMusicLibrary();
    }
}

function updateSchedule(scheduleData) {
    schedule = scheduleData;
    if (currentTab === 'schedule') {
        loadSchedule();
    }
}

function handleBroadcastStatusChange(status) {
    isLive = status.isLive;
    updateBroadcastStatus();
    updateListenerCount(status.listeners || 0);
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#2ecc71' : type === 'error' ? '#e74c3c' : '#3498db'};
        color: white;
        padding: 15px 25px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 500;
        z-index: 10001;
        animation: slideInRight 0.3s ease-out;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Send callback to FiveM
function sendCallback(event, data) {
    if (window.invokeNative) {
        fetch(`https://${GetParentResourceName()}/${event}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).catch(err => console.error('Callback error:', err));
    }
}

// Add slide animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);