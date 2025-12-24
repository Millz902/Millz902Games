let currentTab = 'dashboard';
let isOrganizerMode = false;
let playerStats = {};
let activeRaces = [];
let tournaments = [];
let vehicles = [];

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadRacingData();
    showTab('dashboard');
});

// Set up event listeners
function setupEventListeners() {
    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showTab(tabName);
        });
    });

    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeRacingPanel);

    // Filter and action buttons
    document.getElementById('refreshRaces')?.addEventListener('click', refreshRaces);
    document.getElementById('createEventBtn')?.addEventListener('click', createRacingEvent);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeRacingPanel();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openRacingAdvanced':
                openRacingPanel(data.mode || 'racer');
                break;
            case 'closeRacingAdvanced':
                closeRacingPanel();
                break;
            case 'updatePlayerStats':
                updatePlayerStats(data.stats);
                break;
            case 'updateActiveRaces':
                updateActiveRaces(data.races);
                break;
            case 'updateTournaments':
                updateTournaments(data.tournaments);
                break;
            case 'updateVehicles':
                updateVehicles(data.vehicles);
                break;
            case 'updateLeaderboard':
                updateLeaderboard(data.leaderboard);
                break;
            case 'updateActivity':
                updateActivity(data.activity);
                break;
        }
    });
}

// Show specific tab
function showTab(tabName) {
    // Update active tab button
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

    // Update active tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}Tab`).classList.add('active');

    currentTab = tabName;

    // Load tab-specific data
    switch(tabName) {
        case 'dashboard':
            loadDashboardData();
            break;
        case 'races':
            loadRacesData();
            break;
        case 'tournaments':
            loadTournamentsData();
            break;
        case 'garage':
            loadGarageData();
            break;
    }
}

// Open racing panel
function openRacingPanel(mode = 'racer') {
    isOrganizerMode = mode === 'organizer';
    document.getElementById('container').classList.remove('hidden');
    
    // Adjust interface based on mode
    adjustInterfaceForMode();
    
    // Notify FiveM
    sendCallback('racingAdvanced:opened', { mode: mode });
}

// Close racing panel
function closeRacingPanel() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('racingAdvanced:closed', {});
}

// Adjust interface based on user mode
function adjustInterfaceForMode() {
    const isOrganizer = isOrganizerMode;
    
    // Show/hide organizer-specific elements
    document.querySelectorAll('.organizer-only').forEach(element => {
        element.style.display = isOrganizer ? 'block' : 'none';
    });
}

// Load racing data
function loadRacingData() {
    sendCallback('racingAdvanced:requestData', { type: 'general' });
}

// Load dashboard data
function loadDashboardData() {
    sendCallback('racingAdvanced:requestData', { type: 'dashboard' });
}

// Update player stats
function updatePlayerStats(stats) {
    playerStats = stats || {
        championshipPoints: 0,
        totalRaces: 0,
        wins: 0,
        bestLap: '--:--'
    };
    
    document.getElementById('championshipPoints').textContent = playerStats.championshipPoints;
    document.getElementById('totalRaces').textContent = playerStats.totalRaces;
    document.getElementById('wins').textContent = playerStats.wins;
    document.getElementById('bestLap').textContent = playerStats.bestLap;
}

// Update activity list
function updateActivity(activity) {
    const activityList = document.getElementById('activityList');
    if (!activityList) return;
    
    if (!activity || activity.length === 0) {
        activityList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 20px;">No recent activity</p>';
        return;
    }
    
    let html = '';
    activity.forEach(item => {
        html += `
            <div class="activity-item">
                <div class="time">${item.time}</div>
                <div class="description">${item.description}</div>
            </div>
        `;
    });
    
    activityList.innerHTML = html;
}

// Update leaderboard
function updateLeaderboard(leaderboard) {
    const leaderboardContainer = document.getElementById('globalLeaderboard');
    if (!leaderboardContainer) return;
    
    if (!leaderboard || leaderboard.length === 0) {
        leaderboardContainer.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 20px;">No leaderboard data</p>';
        return;
    }
    
    let html = '';
    leaderboard.forEach((driver, index) => {
        const positionClass = index === 0 ? 'first' : index === 1 ? 'second' : index === 2 ? 'third' : '';
        html += `
            <div class="leaderboard-item">
                <div class="position ${positionClass}">#${index + 1}</div>
                <div class="driver-info">
                    <div class="driver-name">${driver.name}</div>
                    <div class="driver-stats">${driver.wins} wins • Best: ${driver.bestTime}</div>
                </div>
                <div class="points">${driver.points}</div>
            </div>
        `;
    });
    
    leaderboardContainer.innerHTML = html;
}

// Load races data
function loadRacesData() {
    sendCallback('racingAdvanced:requestData', { type: 'races' });
}

// Update active races
function updateActiveRaces(races) {
    activeRaces = races || [];
    renderActiveRaces();
}

// Render active races
function renderActiveRaces() {
    const racesList = document.getElementById('activeRacesList');
    if (!racesList) return;
    
    if (activeRaces.length === 0) {
        racesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px; grid-column: 1 / -1;">No active races</p>';
        return;
    }
    
    let html = '';
    activeRaces.forEach(race => {
        html += `
            <div class="race-card" onclick="joinRace('${race.id}')">
                <h4>${race.name}</h4>
                <div class="race-info">
                    <div class="race-info-item">
                        <span class="label">Type:</span>
                        <span class="value">${race.type}</span>
                    </div>
                    <div class="race-info-item">
                        <span class="label">Difficulty:</span>
                        <span class="value">${race.difficulty}</span>
                    </div>
                    <div class="race-info-item">
                        <span class="label">Participants:</span>
                        <span class="value">${race.participants}/${race.maxParticipants}</span>
                    </div>
                    <div class="race-info-item">
                        <span class="label">Entry Fee:</span>
                        <span class="value">$${race.entryFee}</span>
                    </div>
                    <div class="race-info-item">
                        <span class="label">Prize Pool:</span>
                        <span class="value">$${race.prizePool}</span>
                    </div>
                    <div class="race-info-item">
                        <span class="label">Status:</span>
                        <span class="value">${race.status}</span>
                    </div>
                </div>
                <button class="join-race-btn" onclick="event.stopPropagation(); joinRace('${race.id}')">
                    ${race.status === 'waiting' ? 'Join Race' : 'Spectate'}
                </button>
            </div>
        `;
    });
    
    racesList.innerHTML = html;
}

// Refresh races
function refreshRaces() {
    const typeFilter = document.getElementById('raceTypeFilter').value;
    const difficultyFilter = document.getElementById('difficultyFilter').value;
    
    sendCallback('racingAdvanced:refreshRaces', {
        typeFilter: typeFilter,
        difficultyFilter: difficultyFilter
    });
    
    showNotification('Races refreshed', 'info');
}

// Join race
function joinRace(raceId) {
    const race = activeRaces.find(r => r.id === raceId);
    if (race) {
        sendCallback('racingAdvanced:joinRace', { 
            raceId: raceId,
            raceName: race.name 
        });
        showNotification(`Joining race: ${race.name}`, 'success');
    }
}

// Create racing event
function createRacingEvent() {
    if (!isOrganizerMode) {
        showNotification('Access denied: Organizer only', 'error');
        return;
    }
    
    const eventName = document.getElementById('eventName').value;
    const eventType = document.getElementById('eventType').value;
    const maxParticipants = parseInt(document.getElementById('maxParticipants').value);
    const entryFee = parseInt(document.getElementById('entryFee').value);
    const prizeMoney = parseInt(document.getElementById('prizeMoney').value);
    const difficulty = document.getElementById('difficulty').value;
    
    if (!eventName.trim()) {
        showNotification('Please enter an event name', 'error');
        return;
    }
    
    const eventData = {
        name: eventName,
        type: eventType,
        maxParticipants: maxParticipants,
        entryFee: entryFee,
        prizeMoney: prizeMoney,
        difficulty: difficulty,
        id: generateEventId()
    };
    
    sendCallback('racingAdvanced:createEvent', eventData);
    
    // Clear form
    document.getElementById('eventName').value = '';
    document.getElementById('eventType').value = 'circuit';
    document.getElementById('maxParticipants').value = '16';
    document.getElementById('entryFee').value = '1000';
    document.getElementById('prizeMoney').value = '5000';
    document.getElementById('difficulty').value = 'amateur';
    
    showNotification('Racing event created successfully!', 'success');
}

// Generate event ID
function generateEventId() {
    return 'EVENT-' + Date.now().toString().slice(-6);
}

// Load tournaments data
function loadTournamentsData() {
    sendCallback('racingAdvanced:requestData', { type: 'tournaments' });
}

// Update tournaments
function updateTournaments(tournamentsData) {
    tournaments = tournamentsData || [];
    renderTournaments();
}

// Render tournaments
function renderTournaments() {
    const tournamentsList = document.getElementById('tournamentsList');
    if (!tournamentsList) return;
    
    if (tournaments.length === 0) {
        tournamentsList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px; grid-column: 1 / -1;">No active tournaments</p>';
        return;
    }
    
    let html = '';
    tournaments.forEach(tournament => {
        html += `
            <div class="tournament-card" onclick="joinTournament('${tournament.id}')">
                <h4>${tournament.name}</h4>
                <div class="tournament-prize">$${tournament.prizePool.toLocaleString()}</div>
                <div class="tournament-info">
                    <div>Entry Fee: $${tournament.entryFee}</div>
                    <div>Participants: ${tournament.participants}/${tournament.maxParticipants}</div>
                    <div>Start Date: ${tournament.startDate}</div>
                </div>
                <button class="join-tournament-btn" onclick="event.stopPropagation(); joinTournament('${tournament.id}')">
                    ${tournament.status === 'open' ? 'Join Tournament' : 'View Tournament'}
                </button>
            </div>
        `;
    });
    
    tournamentsList.innerHTML = html;
}

// Join tournament
function joinTournament(tournamentId) {
    const tournament = tournaments.find(t => t.id === tournamentId);
    if (tournament) {
        sendCallback('racingAdvanced:joinTournament', { 
            tournamentId: tournamentId,
            tournamentName: tournament.name 
        });
        showNotification(`Joining tournament: ${tournament.name}`, 'success');
    }
}

// Load garage data
function loadGarageData() {
    sendCallback('racingAdvanced:requestData', { type: 'garage' });
}

// Update vehicles
function updateVehicles(vehiclesData) {
    vehicles = vehiclesData || [];
    renderVehicles();
}

// Render vehicles
function renderVehicles() {
    const vehiclesList = document.getElementById('vehiclesList');
    if (!vehiclesList) return;
    
    if (vehicles.length === 0) {
        vehiclesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px; grid-column: 1 / -1;">No racing vehicles</p>';
        return;
    }
    
    let html = '';
    vehicles.forEach(vehicle => {
        html += `
            <div class="vehicle-card" onclick="selectVehicle('${vehicle.id}')">
                <h5>${vehicle.name}</h5>
                <div class="vehicle-stats">
                    <div class="vehicle-stat">
                        <div class="stat-name">Speed</div>
                        <div class="stat-value">${vehicle.speed}/10</div>
                    </div>
                    <div class="vehicle-stat">
                        <div class="stat-name">Accel</div>
                        <div class="stat-value">${vehicle.acceleration}/10</div>
                    </div>
                    <div class="vehicle-stat">
                        <div class="stat-name">Handling</div>
                        <div class="stat-value">${vehicle.handling}/10</div>
                    </div>
                    <div class="vehicle-stat">
                        <div class="stat-name">Braking</div>
                        <div class="stat-value">${vehicle.braking}/10</div>
                    </div>
                </div>
                <button class="tune-btn" onclick="event.stopPropagation(); tuneVehicle('${vehicle.id}')">Tune Vehicle</button>
            </div>
        `;
    });
    
    vehiclesList.innerHTML = html;
}

// Select vehicle
function selectVehicle(vehicleId) {
    const vehicle = vehicles.find(v => v.id === vehicleId);
    if (vehicle) {
        sendCallback('racingAdvanced:selectVehicle', { vehicleId: vehicleId });
        showNotification(`Selected: ${vehicle.name}`, 'info');
    }
}

// Tune vehicle
function tuneVehicle(vehicleId) {
    const vehicle = vehicles.find(v => v.id === vehicleId);
    if (vehicle) {
        sendCallback('racingAdvanced:tuneVehicle', { vehicleId: vehicleId });
        showNotification(`Opening tuning for: ${vehicle.name}`, 'info');
    }
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#2ecc71' : type === 'error' ? '#e74c3c' : '#ff6b35'};
        color: white;
        padding: 15px 25px;
        border-radius: 10px;
        font-size: 16px;
        font-weight: 600;
        z-index: 10000;
        animation: slideInRight 0.3s ease-out;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
        border: 2px solid rgba(255, 255, 255, 0.2);
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Remove after 4 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 4000);
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

// Add required CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.05);
        }
    }
`;
document.head.appendChild(style);