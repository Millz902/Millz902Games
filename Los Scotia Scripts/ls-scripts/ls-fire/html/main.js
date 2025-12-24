// Fire Department Management System - JavaScript
// Los Scotia RP - Fire Department Interface

let currentTab = 'dashboard';
let emergencyCallsData = [];
let apparatusData = [];
let stationsData = [];
let personnelData = [];
let equipmentData = [];
let incidentsData = [];

// Initialize the application
$(document).ready(function() {
    initializeFireDept();
    loadDefaultData();
    setupEventHandlers();
    setInterval(updateRealTimeData, 5000); // Update every 5 seconds
});

// Initialize Fire Department System
function initializeFireDept() {
    console.log('Los Scotia Fire Department System Initialized');
    showTab('dashboard');
    
    // Listen for NUI messages from Lua
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.type) {
            case 'openFireDept':
                openFirePanel();
                break;
            case 'closeFireDept':
                closeFirePanel();
                break;
            case 'updateIncidents':
                updateIncidents(data.incidents);
                break;
            case 'updateApparatus':
                updateApparatus(data.apparatus);
                break;
            case 'updatePersonnel':
                updatePersonnel(data.personnel);
                break;
            case 'newEmergencyCall':
                handleNewEmergencyCall(data.call);
                break;
            case 'updateStations':
                updateStations(data.stations);
                break;
            case 'updateEquipment':
                updateEquipment(data.equipment);
                break;
        }
    });
}

// Setup Event Handlers
function setupEventHandlers() {
    // Tab switching
    $('.tab-btn').click(function() {
        const tabName = $(this).data('tab');
        showTab(tabName);
    });
    
    // Close panel
    $('.close-btn').click(function() {
        closeFirePanel();
    });
    
    // Emergency call buttons
    $(document).on('click', '.respond-btn', function() {
        const incidentId = $(this).data('incident-id');
        respondToIncident(incidentId);
    });
    
    $(document).on('click', '.close-incident-btn', function() {
        const incidentId = $(this).data('incident-id');
        closeIncident(incidentId);
    });
    
    // Apparatus buttons
    $(document).on('click', '.deploy-btn', function() {
        const apparatusId = $(this).data('apparatus-id');
        deployApparatus(apparatusId);
    });
    
    $(document).on('click', '.recall-btn', function() {
        const apparatusId = $(this).data('apparatus-id');
        recallApparatus(apparatusId);
    });
    
    $(document).on('click', '.maintenance-btn', function() {
        const apparatusId = $(this).data('apparatus-id');
        toggleMaintenance(apparatusId);
    });
    
    // Station management buttons
    $(document).on('click', '.open-station-btn', function() {
        const stationId = $(this).data('station-id');
        openStation(stationId);
    });
    
    $(document).on('click', '.close-station-btn', function() {
        const stationId = $(this).data('station-id');
        closeStation(stationId);
    });
    
    // Personnel buttons
    $(document).on('click', '.on-duty-btn', function() {
        const personnelId = $(this).data('personnel-id');
        togglePersonnelDuty(personnelId, true);
    });
    
    $(document).on('click', '.off-duty-btn', function() {
        const personnelId = $(this).data('personnel-id');
        togglePersonnelDuty(personnelId, false);
    });
    
    // Equipment buttons
    $(document).on('click', '.check-out-btn', function() {
        const equipmentId = $(this).data('equipment-id');
        checkOutEquipment(equipmentId);
    });
    
    $(document).on('click', '.check-in-btn', function() {
        const equipmentId = $(this).data('equipment-id');
        checkInEquipment(equipmentId);
    });
    
    // Settings buttons
    $(document).on('click', '.save-settings-btn', function() {
        saveSettings();
    });
    
    $(document).on('click', '.reset-settings-btn', function() {
        resetSettings();
    });
    
    // Keyboard shortcuts
    $(document).keydown(function(e) {
        if (e.key === 'Escape') {
            closeFirePanel();
        }
    });
}

// Tab Management
function showTab(tabName) {
    currentTab = tabName;
    
    // Hide all tab contents
    $('.tab-content').removeClass('active');
    $('.tab-btn').removeClass('active');
    
    // Show selected tab
    $(`#${tabName}-tab`).addClass('active');
    $(`.tab-btn[data-tab="${tabName}"]`).addClass('active');
    
    // Load tab-specific data
    switch(tabName) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'incidents':
            loadIncidents();
            break;
        case 'apparatus':
            loadApparatus();
            break;
        case 'stations':
            loadStations();
            break;
        case 'personnel':
            loadPersonnel();
            break;
        case 'equipment':
            loadEquipment();
            break;
        case 'settings':
            loadSettings();
            break;
    }
}

// Panel Management
function openFirePanel() {
    $('#container').removeClass('hidden');
    $('body').css('overflow', 'hidden');
    loadDashboard();
}

function closeFirePanel() {
    $('#container').addClass('hidden');
    $('body').css('overflow', 'auto');
    
    // Send close message to Lua
    $.post('http://ls-fire/closePanel', JSON.stringify({}));
}

// Dashboard Functions
function loadDashboard() {
    updateDashboardStats();
    updateActiveIncidents();
    updateUnitDeployment();
}

function updateDashboardStats() {
    // This would be populated with real data from the server
    $('#active-incidents-count').text(incidentsData.filter(i => i.status === 'active').length);
    $('#units-deployed-count').text(apparatusData.filter(a => a.status === 'deployed').length);
    $('#personnel-on-duty-count').text(personnelData.filter(p => p.onDuty).length);
    $('#stations-open-count').text(stationsData.filter(s => s.status === 'open').length);
}

function updateActiveIncidents() {
    const activeIncidents = incidentsData.filter(i => i.status === 'active');
    const incidentsList = $('#active-incidents-list');
    incidentsList.empty();
    
    if (activeIncidents.length === 0) {
        incidentsList.append(`
            <div class="incident-item">
                <div class="incident-info">
                    <div class="incident-location">No Active Incidents</div>
                    <div class="incident-type">All clear in Los Scotia</div>
                </div>
            </div>
        `);
        return;
    }
    
    activeIncidents.forEach(incident => {
        const priorityClass = incident.priority.toLowerCase();
        incidentsList.append(`
            <div class="incident-item ${priorityClass}-priority">
                <div class="incident-info">
                    <div class="incident-id">#${incident.id}</div>
                    <div class="incident-location">${incident.location}</div>
                    <div class="incident-type">${incident.type}</div>
                    <div class="incident-time">${incident.time}</div>
                </div>
                <div class="incident-status">
                    <span class="priority ${priorityClass}">${incident.priority}</span>
                    <span class="assigned">${incident.assigned} Units</span>
                    <span class="alarm-level">Alarm ${incident.alarmLevel}</span>
                </div>
            </div>
        `);
    });
}

function updateUnitDeployment() {
    const deploymentGrid = $('#unit-deployment-grid');
    deploymentGrid.empty();
    
    apparatusData.forEach(unit => {
        const statusClass = unit.status.toLowerCase().replace(' ', '-');
        deploymentGrid.append(`
            <div class="unit-status-card ${statusClass}">
                <div class="unit-id">${unit.callsign} - ${unit.type}</div>
                <div class="unit-location">Location: ${unit.location}</div>
                <div class="unit-crew">Crew: ${unit.crew.join(', ')}</div>
                <div class="unit-status">Status: ${unit.status}</div>
                ${unit.eta ? `<div class="eta">ETA: ${unit.eta}</div>` : ''}
            </div>
        `);
    });
}

// Incident Management
function loadIncidents() {
    const incidentsContainer = $('#incidents-container');
    incidentsContainer.empty();
    
    incidentsData.forEach(incident => {
        const priorityClass = incident.priority.toLowerCase();
        const statusClass = incident.status.toLowerCase();
        
        incidentsContainer.append(`
            <div class="incident-card ${priorityClass}-priority ${statusClass}">
                <div class="incident-header">
                    <div class="incident-id">#${incident.id}</div>
                    <div class="incident-priority">
                        <span class="priority ${priorityClass}">${incident.priority}</span>
                    </div>
                </div>
                <div class="incident-details">
                    <div class="incident-location">${incident.location}</div>
                    <div class="incident-type">${incident.type}</div>
                    <div class="incident-description">${incident.description}</div>
                    <div class="incident-time">Reported: ${incident.time}</div>
                    <div class="incident-units">Units: ${incident.assignedUnits.join(', ')}</div>
                </div>
                <div class="incident-actions">
                    ${incident.status === 'active' ? 
                        `<button class="action-btn respond-btn" data-incident-id="${incident.id}">Deploy Units</button>
                         <button class="action-btn close-incident-btn" data-incident-id="${incident.id}">Close Incident</button>` :
                        `<button class="action-btn disabled">Incident Closed</button>`
                    }
                </div>
            </div>
        `);
    });
}

// Apparatus Management
function loadApparatus() {
    const apparatusContainer = $('#apparatus-container');
    apparatusContainer.empty();
    
    apparatusData.forEach(apparatus => {
        const statusClass = apparatus.status.toLowerCase().replace(' ', '-');
        
        apparatusContainer.append(`
            <div class="apparatus-card ${statusClass}">
                <div class="apparatus-header">
                    <div class="apparatus-callsign">${apparatus.callsign}</div>
                    <div class="apparatus-status">
                        <span class="status-badge ${statusClass}">${apparatus.status}</span>
                    </div>
                </div>
                <div class="apparatus-details">
                    <div class="apparatus-type">${apparatus.type}</div>
                    <div class="apparatus-station">Station: ${apparatus.station}</div>
                    <div class="apparatus-location">Location: ${apparatus.location}</div>
                    <div class="apparatus-crew">Crew: ${apparatus.crew.join(', ')}</div>
                    <div class="apparatus-fuel">Fuel: ${apparatus.fuel}%</div>
                    <div class="apparatus-maintenance">Next Service: ${apparatus.nextMaintenance}</div>
                </div>
                <div class="apparatus-actions">
                    ${apparatus.status === 'Available' ? 
                        `<button class="action-btn deploy-btn" data-apparatus-id="${apparatus.id}">Deploy</button>` :
                        `<button class="action-btn recall-btn" data-apparatus-id="${apparatus.id}">Recall</button>`
                    }
                    <button class="action-btn maintenance-btn" data-apparatus-id="${apparatus.id}">
                        ${apparatus.status === 'Maintenance' ? 'End Maintenance' : 'Start Maintenance'}
                    </button>
                </div>
            </div>
        `);
    });
}

// Station Management
function loadStations() {
    const stationsContainer = $('#stations-container');
    stationsContainer.empty();
    
    stationsData.forEach(station => {
        const statusClass = station.status.toLowerCase();
        
        stationsContainer.append(`
            <div class="station-card ${statusClass}">
                <div class="station-header">
                    <div class="station-name">${station.name}</div>
                    <div class="station-status">
                        <span class="status-badge ${statusClass}">${station.status}</span>
                    </div>
                </div>
                <div class="station-details">
                    <div class="station-address">${station.address}</div>
                    <div class="station-personnel">Personnel: ${station.personnel}</div>
                    <div class="station-apparatus">Apparatus: ${station.apparatus.join(', ')}</div>
                    <div class="station-response-area">Response Area: ${station.responseArea}</div>
                </div>
                <div class="station-actions">
                    ${station.status === 'Open' ? 
                        `<button class="action-btn close-station-btn" data-station-id="${station.id}">Close Station</button>` :
                        `<button class="action-btn open-station-btn" data-station-id="${station.id}">Open Station</button>`
                    }
                    <button class="action-btn">View Details</button>
                </div>
            </div>
        `);
    });
}

// Personnel Management
function loadPersonnel() {
    const personnelContainer = $('#personnel-container');
    personnelContainer.empty();
    
    personnelData.forEach(person => {
        const dutyClass = person.onDuty ? 'on-duty' : 'off-duty';
        
        personnelContainer.append(`
            <div class="personnel-card ${dutyClass}">
                <div class="personnel-header">
                    <div class="personnel-name">${person.name}</div>
                    <div class="personnel-badge">#${person.badge}</div>
                </div>
                <div class="personnel-details">
                    <div class="personnel-rank">${person.rank}</div>
                    <div class="personnel-station">Station: ${person.station}</div>
                    <div class="personnel-assignment">Assignment: ${person.assignment}</div>
                    <div class="personnel-status">Status: ${person.onDuty ? 'On Duty' : 'Off Duty'}</div>
                    <div class="personnel-hours">Hours This Week: ${person.hoursThisWeek}</div>
                </div>
                <div class="personnel-actions">
                    ${person.onDuty ? 
                        `<button class="action-btn off-duty-btn" data-personnel-id="${person.id}">Clock Out</button>` :
                        `<button class="action-btn on-duty-btn" data-personnel-id="${person.id}">Clock In</button>`
                    }
                    <button class="action-btn">View Profile</button>
                </div>
            </div>
        `);
    });
}

// Equipment Management
function loadEquipment() {
    const equipmentContainer = $('#equipment-container');
    equipmentContainer.empty();
    
    equipmentData.forEach(equipment => {
        const statusClass = equipment.status.toLowerCase().replace(' ', '-');
        
        equipmentContainer.append(`
            <div class="equipment-card ${statusClass}">
                <div class="equipment-header">
                    <div class="equipment-name">${equipment.name}</div>
                    <div class="equipment-id">ID: ${equipment.id}</div>
                </div>
                <div class="equipment-details">
                    <div class="equipment-type">${equipment.type}</div>
                    <div class="equipment-location">Location: ${equipment.location}</div>
                    <div class="equipment-status">Status: ${equipment.status}</div>
                    <div class="equipment-last-service">Last Service: ${equipment.lastService}</div>
                    ${equipment.checkedOutBy ? `<div class="equipment-checked-out">Checked Out By: ${equipment.checkedOutBy}</div>` : ''}
                </div>
                <div class="equipment-actions">
                    ${equipment.status === 'Available' ? 
                        `<button class="action-btn check-out-btn" data-equipment-id="${equipment.id}">Check Out</button>` :
                        `<button class="action-btn check-in-btn" data-equipment-id="${equipment.id}">Check In</button>`
                    }
                    <button class="action-btn">Service History</button>
                </div>
            </div>
        `);
    });
}

// Settings Management
function loadSettings() {
    // Load current settings from server or local storage
    // This would be implemented based on specific needs
}

// Action Handlers
function respondToIncident(incidentId) {
    $.post('http://ls-fire/respondToIncident', JSON.stringify({
        incidentId: incidentId
    }));
}

function closeIncident(incidentId) {
    $.post('http://ls-fire/closeIncident', JSON.stringify({
        incidentId: incidentId
    }));
}

function deployApparatus(apparatusId) {
    $.post('http://ls-fire/deployApparatus', JSON.stringify({
        apparatusId: apparatusId
    }));
}

function recallApparatus(apparatusId) {
    $.post('http://ls-fire/recallApparatus', JSON.stringify({
        apparatusId: apparatusId
    }));
}

function toggleMaintenance(apparatusId) {
    $.post('http://ls-fire/toggleMaintenance', JSON.stringify({
        apparatusId: apparatusId
    }));
}

function openStation(stationId) {
    $.post('http://ls-fire/openStation', JSON.stringify({
        stationId: stationId
    }));
}

function closeStation(stationId) {
    $.post('http://ls-fire/closeStation', JSON.stringify({
        stationId: stationId
    }));
}

function togglePersonnelDuty(personnelId, onDuty) {
    $.post('http://ls-fire/togglePersonnelDuty', JSON.stringify({
        personnelId: personnelId,
        onDuty: onDuty
    }));
}

function checkOutEquipment(equipmentId) {
    $.post('http://ls-fire/checkOutEquipment', JSON.stringify({
        equipmentId: equipmentId
    }));
}

function checkInEquipment(equipmentId) {
    $.post('http://ls-fire/checkInEquipment', JSON.stringify({
        equipmentId: equipmentId
    }));
}

function saveSettings() {
    const settings = {
        autoDispatch: $('#auto-dispatch').is(':checked'),
        soundAlerts: $('#sound-alerts').is(':checked'),
        responseTimer: $('#response-timer').val(),
        defaultAlarmLevel: $('#default-alarm-level').val()
    };
    
    $.post('http://ls-fire/saveSettings', JSON.stringify(settings));
}

function resetSettings() {
    if (confirm('Are you sure you want to reset all settings to default?')) {
        $.post('http://ls-fire/resetSettings', JSON.stringify({}));
    }
}

// Real-time Updates
function updateRealTimeData() {
    if ($('#container').hasClass('hidden')) return;
    
    $.post('http://ls-fire/requestUpdate', JSON.stringify({
        type: 'all'
    }));
}

function handleNewEmergencyCall(callData) {
    // Add blinking notification for new emergency call
    showNotification('New Emergency Call', `${callData.type} at ${callData.location}`, 'danger');
    
    // Add to incidents data
    incidentsData.unshift(callData);
    
    // Update displays if on relevant tabs
    if (currentTab === 'dashboard') {
        updateActiveIncidents();
        updateDashboardStats();
    } else if (currentTab === 'incidents') {
        loadIncidents();
    }
}

// Utility Functions
function showNotification(title, message, type = 'info') {
    const notification = $(`
        <div class="notification ${type}">
            <div class="notification-title">${title}</div>
            <div class="notification-message">${message}</div>
        </div>
    `);
    
    $('body').append(notification);
    
    setTimeout(() => {
        notification.fadeOut(() => {
            notification.remove();
        });
    }, 5000);
}

function formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString();
}

function formatDuration(minutes) {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
}

// Load default data for demonstration
function loadDefaultData() {
    incidentsData = [
        {
            id: 'INC001',
            type: 'Structure Fire',
            location: '123 Main Street',
            description: 'Residential structure fire, second floor',
            priority: 'High',
            status: 'active',
            time: '14:23',
            assigned: 3,
            alarmLevel: 2,
            assignedUnits: ['E1', 'L1', 'R1']
        },
        {
            id: 'INC002',
            type: 'Medical Emergency',
            location: '456 Oak Avenue',
            description: 'Chest pain, 65 year old male',
            priority: 'Medium',
            status: 'active',
            time: '14:45',
            assigned: 1,
            alarmLevel: 1,
            assignedUnits: ['R2']
        }
    ];
    
    apparatusData = [
        {
            id: 'e1',
            callsign: 'E1',
            type: 'Engine',
            station: 'Station 1',
            location: '123 Main Street',
            status: 'Responding',
            crew: ['Smith', 'Johnson', 'Wilson'],
            fuel: 85,
            nextMaintenance: '2024-02-15',
            eta: '3 min'
        },
        {
            id: 'l1',
            callsign: 'L1',
            type: 'Ladder',
            station: 'Station 1',
            location: 'Station 1',
            status: 'Available',
            crew: ['Davis', 'Brown'],
            fuel: 92,
            nextMaintenance: '2024-02-20'
        },
        {
            id: 'r1',
            callsign: 'R1',
            type: 'Rescue',
            station: 'Station 2',
            location: '456 Oak Avenue',
            status: 'On Scene',
            crew: ['Miller', 'Garcia'],
            fuel: 78,
            nextMaintenance: '2024-02-12'
        }
    ];
    
    stationsData = [
        {
            id: 'station1',
            name: 'Station 1',
            address: '100 Fire Station Road',
            status: 'Open',
            personnel: 8,
            apparatus: ['E1', 'L1', 'C1'],
            responseArea: 'Downtown District'
        },
        {
            id: 'station2',
            name: 'Station 2',
            address: '200 Rescue Drive',
            status: 'Open',
            personnel: 6,
            apparatus: ['E2', 'R1'],
            responseArea: 'North End'
        }
    ];
    
    personnelData = [
        {
            id: 'p1',
            name: 'Captain John Smith',
            badge: '001',
            rank: 'Captain',
            station: 'Station 1',
            assignment: 'Engine 1',
            onDuty: true,
            hoursThisWeek: 42
        },
        {
            id: 'p2',
            name: 'Lieutenant Sarah Johnson',
            badge: '002',
            rank: 'Lieutenant',
            station: 'Station 1',
            assignment: 'Ladder 1',
            onDuty: false,
            hoursThisWeek: 38
        }
    ];
    
    equipmentData = [
        {
            id: 'eq1',
            name: 'SCBA Unit #1',
            type: 'Breathing Apparatus',
            location: 'Engine 1',
            status: 'In Use',
            lastService: '2024-01-15',
            checkedOutBy: 'Smith, J.'
        },
        {
            id: 'eq2',
            name: 'Halligan Bar #3',
            type: 'Forcible Entry',
            location: 'Station 1',
            status: 'Available',
            lastService: '2024-01-10'
        }
    ];
}

// Update functions for real-time data
function updateIncidents(incidents) {
    incidentsData = incidents;
    if (currentTab === 'dashboard' || currentTab === 'incidents') {
        loadDashboard();
    }
}

function updateApparatus(apparatus) {
    apparatusData = apparatus;
    if (currentTab === 'dashboard' || currentTab === 'apparatus') {
        loadDashboard();
    }
}

function updatePersonnel(personnel) {
    personnelData = personnel;
    if (currentTab === 'personnel') {
        loadPersonnel();
    }
}

function updateStations(stations) {
    stationsData = stations;
    if (currentTab === 'stations') {
        loadStations();
    }
}

function updateEquipment(equipment) {
    equipmentData = equipment;
    if (currentTab === 'equipment') {
        loadEquipment();
    }
}