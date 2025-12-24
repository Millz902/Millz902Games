document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('container');
    const closeBtn = document.getElementById('close-btn');
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    // Tab switching functionality
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Remove active class from all tabs and contents
            tabBtns.forEach(tb => tb.classList.remove('active'));
            tabContents.forEach(tc => tc.classList.remove('active'));
            
            // Add active class to clicked tab and corresponding content
            this.classList.add('active');
            document.getElementById(targetTab).classList.add('active');
        });
    });

    // Close button functionality
    closeBtn.addEventListener('click', function() {
        container.classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Race action handlers
    document.getElementById('create-race').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/createRace`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('join-race').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/joinRace`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('quick-race').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/quickRace`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Garage action handlers
    document.getElementById('tune-vehicle').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/tuneVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('customize-vehicle').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/customizeVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('vehicle-stats').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/viewVehicleStats`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Filter handlers
    document.getElementById('race-type-filter').addEventListener('change', function() {
        const selectedType = this.value;
        fetch(`https://${GetParentResourceName()}/filterRaces`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                type: selectedType,
                difficulty: document.getElementById('difficulty-filter').value
            })
        });
    });

    document.getElementById('difficulty-filter').addEventListener('change', function() {
        const selectedDifficulty = this.value;
        fetch(`https://${GetParentResourceName()}/filterRaces`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                type: document.getElementById('race-type-filter').value,
                difficulty: selectedDifficulty
            })
        });
    });

    // Leaderboard filter handlers
    document.getElementById('leaderboard-type').addEventListener('change', function() {
        const selectedType = this.value;
        const trackSelect = document.getElementById('track-select');
        
        if(selectedType === 'track-specific') {
            trackSelect.classList.remove('hidden');
        } else {
            trackSelect.classList.add('hidden');
        }
        
        fetch(`https://${GetParentResourceName()}/updateLeaderboard`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                type: selectedType,
                track: trackSelect.value
            })
        });
    });

    document.getElementById('track-select').addEventListener('change', function() {
        fetch(`https://${GetParentResourceName()}/updateLeaderboard`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                type: document.getElementById('leaderboard-type').value,
                track: this.value
            })
        });
    });

    // Listen for messages from the client
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'show':
                container.classList.remove('hidden');
                if(data.racingData) {
                    updateRacingData(data.racingData);
                }
                break;
                
            case 'hide':
                container.classList.add('hidden');
                break;
                
            case 'updateStats':
                if(data.stats) {
                    updateOverviewStats(data.stats);
                }
                break;
                
            case 'updateRaces':
                if(data.races) {
                    updateRaceList(data.races);
                }
                break;
                
            case 'updateLeaderboard':
                if(data.leaderboard) {
                    updateLeaderboardTable(data.leaderboard);
                }
                break;
                
            case 'updateVehicles':
                if(data.vehicles) {
                    updateVehicleGrid(data.vehicles);
                }
                break;
                
            case 'updateVehicleStats':
                if(data.vehicleStats) {
                    updateVehicleStats(data.vehicleStats);
                }
                break;
                
            case 'updateActivity':
                if(data.activity) {
                    updateRecentActivity(data.activity);
                }
                break;
        }
    });

    // Update racing data
    function updateRacingData(racingData) {
        if(racingData.stats) {
            updateOverviewStats(racingData.stats);
        }
        if(racingData.races) {
            updateRaceList(racingData.races);
        }
        if(racingData.leaderboard) {
            updateLeaderboardTable(racingData.leaderboard);
        }
        if(racingData.vehicles) {
            updateVehicleGrid(racingData.vehicles);
        }
        if(racingData.activity) {
            updateRecentActivity(racingData.activity);
        }
    }

    // Update overview stats
    function updateOverviewStats(stats) {
        document.getElementById('races-won').textContent = stats.racesWon || 0;
        document.getElementById('total-races').textContent = stats.totalRaces || 0;
        document.getElementById('best-time').textContent = stats.bestTime || '--:--';
        document.getElementById('racing-credits').textContent = '$' + (stats.credits || 0).toLocaleString();
    }

    // Update recent activity
    function updateRecentActivity(activity) {
        const activityList = document.querySelector('.activity-list');
        activityList.innerHTML = '';
        
        if(activity && activity.length > 0) {
            activity.forEach(item => {
                const activityDiv = document.createElement('div');
                activityDiv.className = 'activity-item';
                activityDiv.innerHTML = `
                    <div>
                        <span style="font-weight: bold;">${item.type}</span>
                        <br>
                        <span style="font-size: 12px; color: rgba(255,255,255,0.7);">${item.description}</span>
                    </div>
                    <span style="font-size: 12px; color: rgba(255,255,255,0.7);">${item.time}</span>
                `;
                activityList.appendChild(activityDiv);
            });
        } else {
            activityList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No recent activity</p>';
        }
    }

    // Update race list
    function updateRaceList(races) {
        const raceList = document.querySelector('.race-list');
        raceList.innerHTML = '';
        
        if(races && races.length > 0) {
            races.forEach(race => {
                const raceDiv = document.createElement('div');
                raceDiv.className = 'race-item';
                raceDiv.innerHTML = `
                    <div class="race-header">
                        <span class="race-title">${race.name}</span>
                        <span class="race-type">${race.type}</span>
                    </div>
                    <div class="race-details">
                        <div class="race-detail">
                            <strong>Distance:</strong> ${race.distance}
                        </div>
                        <div class="race-detail">
                            <strong>Laps:</strong> ${race.laps}
                        </div>
                        <div class="race-detail">
                            <strong>Buy-in:</strong> $${race.buyIn}
                        </div>
                        <div class="race-detail">
                            <strong>Players:</strong> ${race.currentPlayers}/${race.maxPlayers}
                        </div>
                    </div>
                    <div class="race-actions">
                        <button onclick="joinSpecificRace(${race.id})" class="action-btn primary">Join Race</button>
                        <button onclick="viewRaceDetails(${race.id})" class="action-btn">View Details</button>
                    </div>
                `;
                raceList.appendChild(raceDiv);
            });
        } else {
            raceList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No races available</p>';
        }
    }

    // Update leaderboard table
    function updateLeaderboardTable(leaderboard) {
        const tableBody = document.querySelector('.table-body');
        tableBody.innerHTML = '';
        
        if(leaderboard && leaderboard.length > 0) {
            leaderboard.forEach((entry, index) => {
                const entryDiv = document.createElement('div');
                entryDiv.className = 'leaderboard-entry';
                
                let rankClass = '';
                if(index === 0) rankClass = 'first';
                else if(index === 1) rankClass = 'second';
                else if(index === 2) rankClass = 'third';
                
                entryDiv.innerHTML = `
                    <span class="rank ${rankClass}">${index + 1}</span>
                    <span>${entry.racer}</span>
                    <span>${entry.time}</span>
                    <span>${entry.vehicle}</span>
                    <span>${entry.points}</span>
                `;
                tableBody.appendChild(entryDiv);
            });
        } else {
            tableBody.innerHTML = '<p style="color: #a0a0a0; text-align: center; grid-column: 1 / -1; padding: 20px;">No leaderboard data available</p>';
        }
    }

    // Update vehicle grid
    function updateVehicleGrid(vehicles) {
        const vehicleGrid = document.querySelector('.vehicle-grid');
        vehicleGrid.innerHTML = '';
        
        if(vehicles && vehicles.length > 0) {
            vehicles.forEach(vehicle => {
                const vehicleDiv = document.createElement('div');
                vehicleDiv.className = 'vehicle-card';
                vehicleDiv.setAttribute('data-vehicle-id', vehicle.id);
                vehicleDiv.innerHTML = `
                    <div class="vehicle-name">${vehicle.name}</div>
                    <div class="vehicle-class">${vehicle.class}</div>
                `;
                
                vehicleDiv.addEventListener('click', function() {
                    // Remove selected class from all vehicles
                    document.querySelectorAll('.vehicle-card').forEach(card => {
                        card.classList.remove('selected');
                    });
                    
                    // Add selected class to clicked vehicle
                    this.classList.add('selected');
                    
                    // Update vehicle stats
                    updateVehicleStats(vehicle.stats);
                    
                    // Notify backend of vehicle selection
                    fetch(`https://${GetParentResourceName()}/selectVehicle`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: JSON.stringify({ vehicleId: vehicle.id })
                    });
                });
                
                vehicleGrid.appendChild(vehicleDiv);
            });
        } else {
            vehicleGrid.innerHTML = '<p style="color: #a0a0a0; text-align: center; grid-column: 1 / -1;">No vehicles available</p>';
        }
    }

    // Update vehicle stats
    function updateVehicleStats(stats) {
        if(!stats) return;
        
        document.getElementById('speed-bar').style.width = (stats.speed || 0) + '%';
        document.getElementById('speed-value').textContent = stats.speed || 0;
        
        document.getElementById('acceleration-bar').style.width = (stats.acceleration || 0) + '%';
        document.getElementById('acceleration-value').textContent = stats.acceleration || 0;
        
        document.getElementById('handling-bar').style.width = (stats.handling || 0) + '%';
        document.getElementById('handling-value').textContent = stats.handling || 0;
        
        document.getElementById('braking-bar').style.width = (stats.braking || 0) + '%';
        document.getElementById('braking-value').textContent = stats.braking || 0;
    }

    // Global functions for race actions
    window.joinSpecificRace = function(raceId) {
        fetch(`https://${GetParentResourceName()}/joinSpecificRace`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ raceId: raceId })
        });
    };

    window.viewRaceDetails = function(raceId) {
        fetch(`https://${GetParentResourceName()}/viewRaceDetails`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ raceId: raceId })
        });
    };

    // Escape key handler
    document.addEventListener('keydown', function(event) {
        if(event.key === 'Escape') {
            container.classList.add('hidden');
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });
});