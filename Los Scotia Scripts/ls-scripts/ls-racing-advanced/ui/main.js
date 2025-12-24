let currentRaces = [];
let leaderboard = [];
let playerStats = {
    totalRaces: 0,
    wins: 0,
    bestTime: '--:--',
    ranking: '#--'
};

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadRacingData();
});

// Set up event listeners
function setupEventListeners() {
    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeRacing);

    // Create race button
    document.getElementById('createRaceBtn').addEventListener('click', createRace);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeRacing();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openRacing':
                openRacing();
                break;
            case 'closeRacing':
                closeRacing();
                break;
            case 'updateRaces':
                updateRaces(data.races);
                break;
            case 'updateStats':
                updatePlayerStats(data.stats);
                break;
            case 'updateLeaderboard':
                updateLeaderboard(data.leaderboard);
                break;
        }
    });
}

// Open racing interface
function openRacing() {
    document.getElementById('container').classList.remove('hidden');
    sendCallback('racing:opened', {});
}

// Close racing interface
function closeRacing() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('racing:closed', {});
}

// Load racing data
function loadRacingData() {
    sendCallback('racing:requestData', {});
}

// Update races list
function updateRaces(races) {
    currentRaces = races || [];
    renderRaces();
}

// Render races
function renderRaces() {
    const racesList = document.getElementById('racesList');
    
    if (currentRaces.length === 0) {
        racesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 20px;">No active races</p>';
        return;
    }
    
    let html = '';
    currentRaces.forEach(race => {
        html += `
            <div class="race-item" onclick="joinRace('${race.id}')">
                <h4>${race.name}</h4>
                <div class="race-info">
                    <span class="label">Type:</span>
                    <span class="value">${race.type}</span>
                </div>
                <div class="race-info">
                    <span class="label">Racers:</span>
                    <span class="value">${race.participants}/${race.maxRacers}</span>
                </div>
                <div class="race-info">
                    <span class="label">Entry Fee:</span>
                    <span class="value">$${race.entryFee}</span>
                </div>
                <div class="race-info">
                    <span class="label">Status:</span>
                    <span class="value">${race.status}</span>
                </div>
                <button class="join-btn" onclick="event.stopPropagation(); joinRace('${race.id}')">
                    ${race.status === 'waiting' ? 'Join Race' : 'Spectate'}
                </button>
            </div>
        `;
    });
    
    racesList.innerHTML = html;
}

// Join race
function joinRace(raceId) {
    const race = currentRaces.find(r => r.id === raceId);
    if (race) {
        sendCallback('racing:joinRace', { raceId: raceId, raceName: race.name });
        showNotification(`Joining race: ${race.name}`, 'info');
    }
}

// Create race
function createRace() {
    const raceName = document.getElementById('raceName').value;
    const raceType = document.getElementById('raceType').value;
    const maxRacers = parseInt(document.getElementById('maxRacers').value);
    const entryFee = parseInt(document.getElementById('entryFee').value);
    
    if (!raceName.trim()) {
        showNotification('Please enter a race name', 'error');
        return;
    }
    
    const raceData = {
        name: raceName,
        type: raceType,
        maxRacers: maxRacers,
        entryFee: entryFee,
        id: generateRaceId()
    };
    
    sendCallback('racing:createRace', raceData);
    
    // Clear form
    document.getElementById('raceName').value = '';
    document.getElementById('raceType').value = 'circuit';
    document.getElementById('maxRacers').value = '8';
    document.getElementById('entryFee').value = '500';
    
    showNotification('Race created successfully!', 'success');
}

// Generate race ID
function generateRaceId() {
    return 'RACE-' + Date.now().toString().slice(-6);
}

// Update player stats
function updatePlayerStats(stats) {
    playerStats = stats || playerStats;
    
    document.getElementById('totalRaces').textContent = playerStats.totalRaces;
    document.getElementById('wins').textContent = playerStats.wins;
    document.getElementById('bestTime').textContent = playerStats.bestTime;
    document.getElementById('ranking').textContent = playerStats.ranking;
}

// Update leaderboard
function updateLeaderboard(data) {
    leaderboard = data || [];
    renderLeaderboard();
}

// Render leaderboard
function renderLeaderboard() {
    const leaderboardList = document.getElementById('leaderboardList');
    
    if (leaderboard.length === 0) {
        leaderboardList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 20px;">No leaderboard data</p>';
        return;
    }
    
    let html = '';
    leaderboard.forEach((player, index) => {
        html += `
            <div class="leaderboard-item">
                <div class="position">#${index + 1}</div>
                <div class="player">${player.name}</div>
                <div class="stats">
                    <div class="wins">${player.wins} wins</div>
                    <div>Best: ${player.bestTime}</div>
                </div>
            </div>
        `;
    });
    
    leaderboardList.innerHTML = html;
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#2ecc71' : type === 'error' ? '#e74c3c' : '#ff6b35'};
        color: white;
        padding: 15px 20px;
        border-radius: 5px;
        font-size: 14px;
        font-weight: 500;
        z-index: 10000;
        animation: slideInRight 0.3s ease-out;
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