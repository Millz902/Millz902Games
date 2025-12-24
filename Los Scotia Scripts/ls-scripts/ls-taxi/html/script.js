// LS Taxi Dispatch System - JavaScript Functions

// Global Variables
let currentTab = 'dispatch';
let drivers = [];
let vehicles = [];
let rides = [];
let callQueue = [];
let earnings = {};
let settings = {};

// Initialize the application
$(document).ready(function() {
    initializeApp();
    loadData();
    startRealTimeUpdates();
    updateClock();
    setupEventListeners();
});

// Application Initialization
function initializeApp() {
    console.log('Initializing LS Taxi Dispatch System...');
    
    // Set default tab
    showTab('dispatch');
    
    // Initialize tooltips and interactions
    initializeTooltips();
    
    // Setup keyboard shortcuts
    setupKeyboardShortcuts();
    
    // Load user preferences
    loadUserPreferences();
    
    console.log('Application initialized successfully');
}

// Load initial data
function loadData() {
    loadDrivers();
    loadVehicles();
    loadRides();
    loadEarnings();
    loadSettings();
    loadCallQueue();
}

// Tab Management
function showTab(tabName) {
    // Hide all tab contents
    $('.tab-content').removeClass('active');
    $('.nav-tab').removeClass('active');
    
    // Show selected tab
    $(`#${tabName}-tab`).addClass('active');
    $(`.nav-tab[data-tab="${tabName}"]`).addClass('active');
    
    currentTab = tabName;
    
    // Trigger tab-specific actions
    switch(tabName) {
        case 'dispatch':
            refreshDispatchView();
            break;
        case 'drivers':
            refreshDriversView();
            break;
        case 'vehicles':
            refreshVehiclesView();
            break;
        case 'rides':
            refreshRidesView();
            break;
        case 'earnings':
            refreshEarningsView();
            break;
        case 'settings':
            loadSettingsForm();
            break;
    }
    
    // Trigger FiveM event
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/tabChanged`, JSON.stringify({
            tab: tabName
        }));
    }
}

// Clock Update
function updateClock() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', { 
        hour12: false,
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
    $('#current-time').text(timeString);
    
    setTimeout(updateClock, 1000);
}

// Real-time Updates
function startRealTimeUpdates() {
    // Update dispatch stats every 30 seconds
    setInterval(updateDispatchStats, 30000);
    
    // Update driver locations every 10 seconds
    setInterval(updateDriverLocations, 10000);
    
    // Update call queue every 15 seconds
    setInterval(updateCallQueue, 15000);
    
    // Update earnings every 60 seconds
    setInterval(updateEarningsStats, 60000);
}

// Dispatch Functions
function refreshDispatchView() {
    updateDispatchStats();
    updateMapView();
    updateCallQueue();
}

function updateDispatchStats() {
    const activeCallsCount = callQueue.filter(call => call.status === 'active').length;
    const availableDriversCount = drivers.filter(driver => driver.status === 'online').length;
    const avgWaitTime = calculateAverageWaitTime();
    
    $('#active-calls').text(activeCallsCount);
    $('#available-drivers').text(availableDriversCount);
    $('#avg-wait-time').text(avgWaitTime.toFixed(1));
}

function updateMapView() {
    // Update driver markers on map
    $('.map-overlay .driver-marker').remove();
    
    drivers.forEach(driver => {
        if (driver.status !== 'offline' && driver.location) {
            const markerClass = driver.status === 'busy' ? 'busy' : 'active';
            const marker = $(`
                <div class="driver-marker ${markerClass}" style="top: ${driver.location.y}%; left: ${driver.location.x}%;">
                    <i class="fas fa-taxi"></i>
                    <span class="driver-info">Driver #${driver.id}</span>
                </div>
            `);
            $('.map-overlay').append(marker);
        }
    });
}

function updateCallQueue() {
    const queueContainer = $('#call-queue');
    queueContainer.empty();
    
    callQueue.forEach(call => {
        const callElement = createCallElement(call);
        queueContainer.append(callElement);
    });
    
    // Trigger FiveM event for call queue update
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/callQueueUpdated`, JSON.stringify({
            calls: callQueue
        }));
    }
}

function createCallElement(call) {
    const priorityClass = call.priority || 'normal';
    const timeString = new Date(call.requestTime).toLocaleTimeString('en-US', { 
        hour12: false,
        hour: '2-digit',
        minute: '2-digit'
    });
    
    return $(`
        <div class="call-item ${priorityClass}" data-call-id="${call.id}">
            <div class="call-priority">
                <i class="fas ${getPriorityIcon(call.priority)}"></i>
                <span>${call.priority.toUpperCase()}</span>
            </div>
            <div class="call-details">
                <div class="call-from">${call.pickupLocation}</div>
                <div class="call-to">${call.destination}</div>
                <div class="call-time">Requested: ${timeString}</div>
                <div class="call-customer">${call.customerName}</div>
            </div>
            <div class="call-actions">
                <button class="assign-btn" onclick="assignDriver('${call.id}')">
                    <i class="fas fa-user-plus"></i> Assign
                </button>
            </div>
        </div>
    `);
}

function getPriorityIcon(priority) {
    switch(priority) {
        case 'urgent': return 'fa-exclamation-triangle';
        case 'scheduled': return 'fa-calendar';
        default: return 'fa-clock';
    }
}

function newDispatchCall() {
    showModal('New Dispatch Call', `
        <div class="form-group">
            <label for="customer-name">Customer Name:</label>
            <input type="text" id="customer-name" placeholder="Enter customer name">
        </div>
        <div class="form-group">
            <label for="pickup-location">Pickup Location:</label>
            <input type="text" id="pickup-location" placeholder="Enter pickup address">
        </div>
        <div class="form-group">
            <label for="destination">Destination:</label>
            <input type="text" id="destination" placeholder="Enter destination">
        </div>
        <div class="form-group">
            <label for="call-priority">Priority:</label>
            <select id="call-priority">
                <option value="normal">Normal</option>
                <option value="urgent">Urgent</option>
                <option value="scheduled">Scheduled</option>
            </select>
        </div>
        <div class="form-group">
            <label for="customer-phone">Phone Number:</label>
            <input type="tel" id="customer-phone" placeholder="Enter phone number">
        </div>
        <div class="form-group">
            <label for="special-instructions">Special Instructions:</label>
            <textarea id="special-instructions" placeholder="Any special requests or notes"></textarea>
        </div>
    `, function() {
        createNewCall();
    });
}

function createNewCall() {
    const newCall = {
        id: 'CALL-' + Date.now(),
        customerName: $('#customer-name').val(),
        pickupLocation: $('#pickup-location').val(),
        destination: $('#destination').val(),
        priority: $('#call-priority').val(),
        phone: $('#customer-phone').val(),
        instructions: $('#special-instructions').val(),
        requestTime: new Date(),
        status: 'pending'
    };
    
    callQueue.push(newCall);
    updateCallQueue();
    
    // Trigger FiveM event
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/newCallCreated`, JSON.stringify({
            call: newCall
        }));
    }
    
    showNotification('New call added to queue', 'success');
}

function assignDriver(callId) {
    const call = callQueue.find(c => c.id === callId);
    const availableDrivers = drivers.filter(d => d.status === 'online');
    
    if (availableDrivers.length === 0) {
        showNotification('No drivers available', 'error');
        return;
    }
    
    let driverOptions = availableDrivers.map(driver => 
        `<option value="${driver.id}">${driver.name} - Vehicle ${driver.vehicleId}</option>`
    ).join('');
    
    showModal('Assign Driver', `
        <div class="form-group">
            <label for="assign-driver-select">Select Driver:</label>
            <select id="assign-driver-select">
                <option value="">Choose a driver...</option>
                ${driverOptions}
            </select>
        </div>
        <div class="call-summary">
            <h4>Call Details:</h4>
            <p><strong>Customer:</strong> ${call.customerName}</p>
            <p><strong>From:</strong> ${call.pickupLocation}</p>
            <p><strong>To:</strong> ${call.destination}</p>
            <p><strong>Priority:</strong> ${call.priority}</p>
        </div>
    `, function() {
        const driverId = $('#assign-driver-select').val();
        if (driverId) {
            performDriverAssignment(callId, driverId);
        }
    });
}

function performDriverAssignment(callId, driverId) {
    const call = callQueue.find(c => c.id === callId);
    const driver = drivers.find(d => d.id === driverId);
    
    if (call && driver) {
        call.assignedDriver = driverId;
        call.status = 'assigned';
        driver.status = 'busy';
        driver.currentCall = callId;
        
        // Create ride record
        const ride = {
            id: 'R-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + String(rides.length + 1).padStart(3, '0'),
            callId: callId,
            driverId: driverId,
            customerName: call.customerName,
            pickupLocation: call.pickupLocation,
            destination: call.destination,
            startTime: new Date(),
            status: 'in-progress',
            fare: 0
        };
        
        rides.push(ride);
        
        // Remove from call queue
        callQueue = callQueue.filter(c => c.id !== callId);
        
        updateCallQueue();
        updateDispatchStats();
        
        // Trigger FiveM event
        if (typeof GetParentResourceName !== 'undefined') {
            $.post(`https://${GetParentResourceName()}/driverAssigned`, JSON.stringify({
                call: call,
                driver: driver,
                ride: ride
            }));
        }
        
        showNotification(`Driver ${driver.name} assigned to call`, 'success');
    }
}

// Driver Management Functions
function refreshDriversView() {
    filterDrivers();
}

function loadDrivers() {
    // Sample driver data - in real implementation, this would come from server
    drivers = [
        {
            id: '042',
            name: 'Marcus Rodriguez',
            status: 'online',
            vehicleId: '7',
            todayRides: 12,
            todayEarnings: 245.60,
            rating: 4.8,
            location: { x: 25, y: 30 },
            shift: 'day',
            joinDate: '2023-01-15'
        },
        {
            id: '018',
            name: 'Jennifer Chen',
            status: 'busy',
            vehicleId: '3',
            todayRides: 8,
            todayEarnings: 189.25,
            rating: 4.9,
            location: { x: 70, y: 60 },
            shift: 'day',
            currentCall: 'CALL-002'
        },
        {
            id: '025',
            name: 'David Thompson',
            status: 'offline',
            vehicleId: '12',
            todayRides: 0,
            todayEarnings: 0,
            rating: 4.7,
            shift: 'night',
            lastShift: 'Yesterday'
        }
    ];
}

function filterDrivers() {
    const statusFilter = $('#status-filter').val();
    const shiftFilter = $('#shift-filter').val();
    const searchTerm = $('#driver-search').val().toLowerCase();
    
    let filteredDrivers = drivers;
    
    if (statusFilter !== 'all') {
        filteredDrivers = filteredDrivers.filter(driver => driver.status === statusFilter);
    }
    
    if (shiftFilter !== 'all') {
        filteredDrivers = filteredDrivers.filter(driver => driver.shift === shiftFilter);
    }
    
    if (searchTerm) {
        filteredDrivers = filteredDrivers.filter(driver => 
            driver.name.toLowerCase().includes(searchTerm) ||
            driver.id.includes(searchTerm)
        );
    }
    
    displayDrivers(filteredDrivers);
}

function searchDrivers() {
    filterDrivers();
}

function displayDrivers(driverList) {
    const grid = $('#drivers-grid');
    grid.empty();
    
    driverList.forEach(driver => {
        const driverCard = createDriverCard(driver);
        grid.append(driverCard);
    });
}

function createDriverCard(driver) {
    const statusClass = driver.status;
    const statusText = driver.status.charAt(0).toUpperCase() + driver.status.slice(1);
    
    return $(`
        <div class="driver-card ${statusClass}">
            <div class="driver-header">
                <div class="driver-avatar">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="driver-info">
                    <h4>${driver.name}</h4>
                    <span class="driver-id">#LS-${driver.id}</span>
                </div>
                <div class="driver-status ${statusClass}">
                    <i class="fas fa-circle"></i>
                    <span>${statusText}</span>
                </div>
            </div>
            <div class="driver-stats">
                <div class="stat-item">
                    <span class="stat-label">Today's Rides:</span>
                    <span class="stat-value">${driver.todayRides}</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Earnings:</span>
                    <span class="stat-value">$${driver.todayEarnings.toFixed(2)}</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Rating:</span>
                    <span class="stat-value">${driver.rating} ⭐</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Vehicle:</span>
                    <span class="stat-value">Taxi #${driver.vehicleId}</span>
                </div>
            </div>
            <div class="driver-actions">
                <button class="action-btn small" onclick="viewDriver('${driver.id}')">
                    <i class="fas fa-eye"></i> View
                </button>
                <button class="action-btn small" onclick="contactDriver('${driver.id}')">
                    <i class="fas fa-phone"></i> Call
                </button>
                ${driver.status === 'online' ? 
                    `<button class="action-btn small warning" onclick="suspendDriver('${driver.id}')">
                        <i class="fas fa-pause"></i> Suspend
                    </button>` :
                    `<button class="action-btn small" onclick="activateDriver('${driver.id}')">
                        <i class="fas fa-play"></i> Activate
                    </button>`
                }
            </div>
        </div>
    `);
}

function addDriver() {
    showModal('Add New Driver', `
        <div class="form-group">
            <label for="new-driver-name">Full Name:</label>
            <input type="text" id="new-driver-name" placeholder="Enter driver name">
        </div>
        <div class="form-group">
            <label for="new-driver-license">License Number:</label>
            <input type="text" id="new-driver-license" placeholder="Enter license number">
        </div>
        <div class="form-group">
            <label for="new-driver-phone">Phone Number:</label>
            <input type="tel" id="new-driver-phone" placeholder="Enter phone number">
        </div>
        <div class="form-group">
            <label for="new-driver-shift">Preferred Shift:</label>
            <select id="new-driver-shift">
                <option value="day">Day Shift</option>
                <option value="night">Night Shift</option>
            </select>
        </div>
        <div class="form-group">
            <label for="new-driver-vehicle">Assign Vehicle:</label>
            <select id="new-driver-vehicle">
                <option value="">Select vehicle...</option>
                ${getAvailableVehicles().map(v => `<option value="${v.id}">${v.name}</option>`).join('')}
            </select>
        </div>
    `, function() {
        createNewDriver();
    });
}

function createNewDriver() {
    const newDriver = {
        id: String(Math.floor(Math.random() * 900) + 100),
        name: $('#new-driver-name').val(),
        license: $('#new-driver-license').val(),
        phone: $('#new-driver-phone').val(),
        shift: $('#new-driver-shift').val(),
        vehicleId: $('#new-driver-vehicle').val(),
        status: 'offline',
        todayRides: 0,
        todayEarnings: 0,
        rating: 5.0,
        joinDate: new Date().toISOString().slice(0, 10)
    };
    
    drivers.push(newDriver);
    refreshDriversView();
    
    // Trigger FiveM event
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/driverAdded`, JSON.stringify({
            driver: newDriver
        }));
    }
    
    showNotification('New driver added successfully', 'success');
}

function viewDriver(driverId) {
    const driver = drivers.find(d => d.id === driverId);
    if (!driver) return;
    
    showModal(`Driver Details - ${driver.name}`, `
        <div class="driver-details">
            <div class="detail-section">
                <h4>Personal Information</h4>
                <p><strong>Name:</strong> ${driver.name}</p>
                <p><strong>ID:</strong> #LS-${driver.id}</p>
                <p><strong>License:</strong> ${driver.license || 'N/A'}</p>
                <p><strong>Phone:</strong> ${driver.phone || 'N/A'}</p>
                <p><strong>Join Date:</strong> ${driver.joinDate}</p>
            </div>
            <div class="detail-section">
                <h4>Work Information</h4>
                <p><strong>Status:</strong> ${driver.status}</p>
                <p><strong>Shift:</strong> ${driver.shift}</p>
                <p><strong>Vehicle:</strong> Taxi #${driver.vehicleId}</p>
                <p><strong>Rating:</strong> ${driver.rating} ⭐</p>
            </div>
            <div class="detail-section">
                <h4>Today's Performance</h4>
                <p><strong>Rides Completed:</strong> ${driver.todayRides}</p>
                <p><strong>Earnings:</strong> $${driver.todayEarnings.toFixed(2)}</p>
                <p><strong>Average per Ride:</strong> $${driver.todayRides > 0 ? (driver.todayEarnings / driver.todayRides).toFixed(2) : '0.00'}</p>
            </div>
        </div>
    `);
}

function contactDriver(driverId) {
    const driver = drivers.find(d => d.id === driverId);
    if (!driver) return;
    
    // Trigger FiveM event to contact driver
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/contactDriver`, JSON.stringify({
            driverId: driverId,
            driverName: driver.name
        }));
    }
    
    showNotification(`Contacting ${driver.name}...`, 'info');
}

function suspendDriver(driverId) {
    const driver = drivers.find(d => d.id === driverId);
    if (!driver) return;
    
    showModal('Suspend Driver', `
        <p>Are you sure you want to suspend ${driver.name}?</p>
        <div class="form-group">
            <label for="suspend-reason">Reason for suspension:</label>
            <textarea id="suspend-reason" placeholder="Enter reason for suspension"></textarea>
        </div>
    `, function() {
        driver.status = 'suspended';
        driver.suspensionReason = $('#suspend-reason').val();
        refreshDriversView();
        
        // Trigger FiveM event
        if (typeof GetParentResourceName !== 'undefined') {
            $.post(`https://${GetParentResourceName()}/driverSuspended`, JSON.stringify({
                driverId: driverId,
                reason: driver.suspensionReason
            }));
        }
        
        showNotification(`${driver.name} has been suspended`, 'warning');
    });
}

// Vehicle Management Functions
function refreshVehiclesView() {
    loadVehicles();
    displayVehicles();
}

function loadVehicles() {
    // Sample vehicle data
    vehicles = [
        {
            id: '007',
            licensePlate: 'LST-0007',
            model: 'Crown Victoria',
            driver: 'Marcus Rodriguez',
            status: 'active',
            mileage: 124567,
            nextService: '2025-10-15',
            lastService: '2025-08-15'
        },
        {
            id: '003',
            licensePlate: 'LST-0003',
            model: 'Toyota Camry',
            driver: 'Jennifer Chen',
            status: 'active',
            mileage: 89234,
            nextService: '2025-10-22',
            lastService: '2025-08-22'
        },
        {
            id: '012',
            licensePlate: 'LST-0012',
            model: 'Honda Accord',
            driver: 'David Thompson',
            status: 'parked',
            mileage: 156789,
            nextService: '2025-10-05',
            lastService: '2025-07-05'
        },
        {
            id: '015',
            licensePlate: 'LST-0015',
            model: 'Nissan Altima',
            driver: 'Unassigned',
            status: 'maintenance',
            mileage: 98456,
            nextService: 'In Progress',
            lastService: '2025-09-15'
        }
    ];
}

function displayVehicles() {
    const tbody = $('#vehicles-tbody');
    tbody.empty();
    
    vehicles.forEach(vehicle => {
        const row = createVehicleRow(vehicle);
        tbody.append(row);
    });
}

function createVehicleRow(vehicle) {
    const statusBadge = `<span class="status-badge ${vehicle.status}">${vehicle.status.charAt(0).toUpperCase() + vehicle.status.slice(1)}</span>`;
    
    return $(`
        <tr data-vehicle-id="${vehicle.id}">
            <td>Taxi #${vehicle.id}</td>
            <td>${vehicle.licensePlate}</td>
            <td>${vehicle.model}</td>
            <td>${vehicle.driver}</td>
            <td>${statusBadge}</td>
            <td>${vehicle.mileage.toLocaleString()}</td>
            <td>${vehicle.nextService}</td>
            <td>
                <button class="action-btn small" onclick="viewVehicle('${vehicle.id}')">View</button>
                ${vehicle.status === 'active' ? 
                    `<button class="action-btn small" onclick="trackVehicle('${vehicle.id}')">Track</button>` :
                    `<button class="action-btn small warning" onclick="scheduleService('${vehicle.id}')">Service</button>`
                }
            </td>
        </tr>
    `);
}

function addVehicle() {
    showModal('Add New Vehicle', `
        <div class="form-group">
            <label for="new-vehicle-plate">License Plate:</label>
            <input type="text" id="new-vehicle-plate" placeholder="Enter license plate">
        </div>
        <div class="form-group">
            <label for="new-vehicle-model">Vehicle Model:</label>
            <input type="text" id="new-vehicle-model" placeholder="Enter vehicle model">
        </div>
        <div class="form-group">
            <label for="new-vehicle-year">Year:</label>
            <input type="number" id="new-vehicle-year" placeholder="Enter year" min="2000" max="2025">
        </div>
        <div class="form-group">
            <label for="new-vehicle-mileage">Current Mileage:</label>
            <input type="number" id="new-vehicle-mileage" placeholder="Enter mileage">
        </div>
    `, function() {
        createNewVehicle();
    });
}

function createNewVehicle() {
    const newVehicle = {
        id: String(Math.floor(Math.random() * 900) + 100),
        licensePlate: $('#new-vehicle-plate').val(),
        model: $('#new-vehicle-model').val(),
        year: $('#new-vehicle-year').val(),
        mileage: parseInt($('#new-vehicle-mileage').val()),
        driver: 'Unassigned',
        status: 'parked',
        nextService: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10)
    };
    
    vehicles.push(newVehicle);
    displayVehicles();
    
    // Trigger FiveM event
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/vehicleAdded`, JSON.stringify({
            vehicle: newVehicle
        }));
    }
    
    showNotification('New vehicle added successfully', 'success');
}

function viewVehicle(vehicleId) {
    const vehicle = vehicles.find(v => v.id === vehicleId);
    if (!vehicle) return;
    
    showModal(`Vehicle Details - Taxi #${vehicle.id}`, `
        <div class="vehicle-details">
            <div class="detail-section">
                <h4>Vehicle Information</h4>
                <p><strong>ID:</strong> Taxi #${vehicle.id}</p>
                <p><strong>License Plate:</strong> ${vehicle.licensePlate}</p>
                <p><strong>Model:</strong> ${vehicle.model}</p>
                <p><strong>Year:</strong> ${vehicle.year || 'N/A'}</p>
                <p><strong>Current Mileage:</strong> ${vehicle.mileage.toLocaleString()} miles</p>
            </div>
            <div class="detail-section">
                <h4>Assignment & Status</h4>
                <p><strong>Current Driver:</strong> ${vehicle.driver}</p>
                <p><strong>Status:</strong> ${vehicle.status}</p>
                <p><strong>Last Service:</strong> ${vehicle.lastService || 'N/A'}</p>
                <p><strong>Next Service:</strong> ${vehicle.nextService}</p>
            </div>
        </div>
    `);
}

function trackVehicle(vehicleId) {
    // Trigger FiveM event to track vehicle
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/trackVehicle`, JSON.stringify({
            vehicleId: vehicleId
        }));
    }
    
    showNotification(`Tracking Taxi #${vehicleId}...`, 'info');
}

function scheduleService(vehicleId) {
    const vehicle = vehicles.find(v => v.id === vehicleId);
    if (!vehicle) return;
    
    showModal('Schedule Maintenance', `
        <p>Schedule maintenance for Taxi #${vehicle.id} (${vehicle.model})</p>
        <div class="form-group">
            <label for="service-date">Service Date:</label>
            <input type="date" id="service-date" min="${new Date().toISOString().slice(0, 10)}">
        </div>
        <div class="form-group">
            <label for="service-type">Service Type:</label>
            <select id="service-type">
                <option value="routine">Routine Maintenance</option>
                <option value="repair">Repair Work</option>
                <option value="inspection">Safety Inspection</option>
                <option value="deep-clean">Deep Cleaning</option>
            </select>
        </div>
        <div class="form-group">
            <label for="service-notes">Notes:</label>
            <textarea id="service-notes" placeholder="Enter service notes"></textarea>
        </div>
    `, function() {
        vehicle.status = 'maintenance';
        vehicle.serviceDate = $('#service-date').val();
        vehicle.serviceType = $('#service-type').val();
        vehicle.serviceNotes = $('#service-notes').val();
        
        displayVehicles();
        
        // Trigger FiveM event
        if (typeof GetParentResourceName !== 'undefined') {
            $.post(`https://${GetParentResourceName()}/serviceScheduled`, JSON.stringify({
                vehicle: vehicle
            }));
        }
        
        showNotification(`Maintenance scheduled for Taxi #${vehicle.id}`, 'success');
    });
}

// Rides Management Functions
function refreshRidesView() {
    displayRides();
    updateRideStats();
}

function loadRides() {
    // Sample ride data
    rides = [
        {
            id: 'R-240921-001',
            customerName: 'John Smith',
            driverName: 'Marcus Rodriguez',
            pickupLocation: 'Downtown Hospital',
            destination: 'Airport',
            distance: 12.4,
            fare: 28.50,
            status: 'completed',
            startTime: '14:23',
            endTime: '14:55'
        },
        {
            id: 'R-240921-002',
            customerName: 'Sarah Johnson',
            driverName: 'Jennifer Chen',
            pickupLocation: 'City Mall',
            destination: 'Main Street',
            distance: 3.2,
            fare: 12.75,
            status: 'in-progress',
            startTime: '14:45',
            endTime: null
        },
        {
            id: 'R-240921-003',
            customerName: 'Michael Brown',
            driverName: 'David Thompson',
            pickupLocation: 'Train Station',
            destination: 'Hotel District',
            distance: 8.7,
            fare: 19.25,
            status: 'completed',
            startTime: '13:15',
            endTime: '13:42'
        }
    ];
}

function displayRides() {
    const tbody = $('#rides-tbody');
    tbody.empty();
    
    rides.forEach(ride => {
        const row = createRideRow(ride);
        tbody.append(row);
    });
}

function createRideRow(ride) {
    const statusBadge = `<span class="status-badge ${ride.status}">${ride.status.charAt(0).toUpperCase() + ride.status.slice(1).replace('-', ' ')}</span>`;
    
    return $(`
        <tr data-ride-id="${ride.id}">
            <td>${ride.id}</td>
            <td>${ride.customerName}</td>
            <td>${ride.driverName}</td>
            <td>${ride.pickupLocation}</td>
            <td>${ride.destination}</td>
            <td>${ride.distance} mi</td>
            <td>$${ride.fare.toFixed(2)}</td>
            <td>${statusBadge}</td>
            <td>${ride.startTime}</td>
            <td>
                ${ride.status === 'in-progress' ?
                    `<button class="action-btn small" onclick="trackRide('${ride.id}')">Track</button>` :
                    `<button class="action-btn small" onclick="viewRide('${ride.id}')">View</button>`
                }
            </td>
        </tr>
    `);
}

function updateRideStats() {
    const todayRides = rides.length;
    const todayRevenue = rides.reduce((sum, ride) => sum + ride.fare, 0);
    const avgWaitTime = calculateAverageWaitTime();
    const avgRating = 4.7; // This would be calculated from customer feedback
    
    // Update stats in rides tab if it exists
    if ($('.ride-stats').length > 0) {
        $('.ride-stats .stat-card:nth-child(1) .stat-value').text(todayRides);
        $('.ride-stats .stat-card:nth-child(2) .stat-value').text(`$${todayRevenue.toFixed(2)}`);
        $('.ride-stats .stat-card:nth-child(3) .stat-value').text(avgWaitTime.toFixed(1));
        $('.ride-stats .stat-card:nth-child(4) .stat-value').text(avgRating);
    }
}

function filterRides() {
    const dateFrom = $('#date-from').val();
    const dateTo = $('#date-to').val();
    const status = $('#ride-status').val();
    
    // Filter logic would go here
    displayRides();
}

function searchRides() {
    const searchTerm = $('#ride-search').val().toLowerCase();
    
    let filteredRides = rides;
    if (searchTerm) {
        filteredRides = rides.filter(ride => 
            ride.id.toLowerCase().includes(searchTerm) ||
            ride.customerName.toLowerCase().includes(searchTerm) ||
            ride.driverName.toLowerCase().includes(searchTerm) ||
            ride.pickupLocation.toLowerCase().includes(searchTerm) ||
            ride.destination.toLowerCase().includes(searchTerm)
        );
    }
    
    displayFilteredRides(filteredRides);
}

function displayFilteredRides(rideList) {
    const tbody = $('#rides-tbody');
    tbody.empty();
    
    rideList.forEach(ride => {
        const row = createRideRow(ride);
        tbody.append(row);
    });
}

function viewRide(rideId) {
    const ride = rides.find(r => r.id === rideId);
    if (!ride) return;
    
    showModal(`Ride Details - ${ride.id}`, `
        <div class="ride-details">
            <div class="detail-section">
                <h4>Trip Information</h4>
                <p><strong>Ride ID:</strong> ${ride.id}</p>
                <p><strong>Customer:</strong> ${ride.customerName}</p>
                <p><strong>Driver:</strong> ${ride.driverName}</p>
                <p><strong>Status:</strong> ${ride.status}</p>
            </div>
            <div class="detail-section">
                <h4>Route Details</h4>
                <p><strong>Pickup:</strong> ${ride.pickupLocation}</p>
                <p><strong>Destination:</strong> ${ride.destination}</p>
                <p><strong>Distance:</strong> ${ride.distance} miles</p>
                <p><strong>Fare:</strong> $${ride.fare.toFixed(2)}</p>
            </div>
            <div class="detail-section">
                <h4>Timing</h4>
                <p><strong>Start Time:</strong> ${ride.startTime}</p>
                <p><strong>End Time:</strong> ${ride.endTime || 'In Progress'}</p>
                <p><strong>Duration:</strong> ${ride.endTime ? calculateDuration(ride.startTime, ride.endTime) : 'Ongoing'}</p>
            </div>
        </div>
    `);
}

function trackRide(rideId) {
    // Trigger FiveM event to track ride
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/trackRide`, JSON.stringify({
            rideId: rideId
        }));
    }
    
    showNotification(`Tracking ride ${rideId}...`, 'info');
}

// Earnings Management Functions
function refreshEarningsView() {
    updateEarningsStats();
    updateEarningsChart();
    updateDriverEarnings();
}

function loadEarnings() {
    earnings = {
        todayRevenue: 18945.60,
        todayExpenses: 4236.80,
        todayProfit: 14708.80,
        weeklyData: [
            { day: 'Mon', revenue: 15245 },
            { day: 'Tue', revenue: 18890 },
            { day: 'Wed', revenue: 13675 },
            { day: 'Thu', revenue: 20125 },
            { day: 'Fri', revenue: 22450 },
            { day: 'Sat', revenue: 21250 },
            { day: 'Sun', revenue: 18946 }
        ]
    };
}

function updateEarningsStats() {
    const yesterdayRevenue = 16845.30; // This would come from database
    const revenueChange = ((earnings.todayRevenue - yesterdayRevenue) / yesterdayRevenue * 100);
    
    $('.summary-card.revenue .summary-amount').text(`$${earnings.todayRevenue.toLocaleString()}`);
    $('.summary-card.revenue .summary-change').text(`${revenueChange > 0 ? '+' : ''}${revenueChange.toFixed(1)}% from yesterday`);
    
    $('.summary-card.expenses .summary-amount').text(`$${earnings.todayExpenses.toLocaleString()}`);
    $('.summary-card.profit .summary-amount').text(`$${earnings.todayProfit.toLocaleString()}`);
}

function updateEarningsChart() {
    // Chart bars would be updated with real data
    earnings.weeklyData.forEach((data, index) => {
        const bar = $(`.chart-bar:eq(${index})`);
        const percentage = (data.revenue / 25000) * 100; // Max scale of $25,000
        bar.css('height', `${percentage}%`);
        bar.find('.bar-value').text(`$${data.revenue.toLocaleString()}`);
    });
}

function updateDriverEarnings() {
    // This would update the top earners list with real data
    // Implementation would fetch driver earnings and update the display
}

function generateFinancialReport() {
    // Trigger FiveM event to generate report
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/generateFinancialReport`, JSON.stringify({
            dateRange: 'today',
            includeDrivers: true,
            includeVehicles: true
        }));
    }
    
    showNotification('Generating financial report...', 'info');
}

function exportRides() {
    // Trigger FiveM event to export rides data
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/exportRidesData`, JSON.stringify({
            format: 'csv',
            dateRange: 'today'
        }));
    }
    
    showNotification('Exporting rides data...', 'info');
}

// Settings Management Functions
function loadSettingsForm() {
    // Load current settings into form
    if (settings.autoAssign !== undefined) {
        $('#auto-assign').prop('checked', settings.autoAssign);
    }
    if (settings.maxWaitTime) {
        $('#max-wait-time').val(settings.maxWaitTime);
    }
    if (settings.baseFare) {
        $('#base-fare').val(settings.baseFare);
    }
    if (settings.perMileRate) {
        $('#per-mile-rate').val(settings.perMileRate);
    }
    if (settings.driverCommission) {
        $('#driver-commission').val(settings.driverCommission);
    }
}

function loadSettings() {
    // Load settings from server/storage
    settings = {
        autoAssign: true,
        maxWaitTime: 10,
        baseFare: 3.50,
        perMileRate: 2.25,
        surgeMultiplier: 1.5,
        driverCommission: 75,
        emailNotifications: true,
        smsAlerts: false,
        backupFrequency: 6,
        logRetention: 30,
        maintenanceMode: false
    };
}

function saveSettings() {
    // Collect settings from form
    const newSettings = {
        autoAssign: $('#auto-assign').is(':checked'),
        maxWaitTime: parseInt($('#max-wait-time').val()),
        baseFare: parseFloat($('#base-fare').val()),
        perMileRate: parseFloat($('#per-mile-rate').val()),
        surgeMultiplier: parseFloat($('#surge-multiplier').val()),
        driverCommission: parseInt($('#driver-commission').val()),
        emailNotifications: $('#email-notifications').is(':checked'),
        smsAlerts: $('#sms-alerts').is(':checked'),
        backupFrequency: parseInt($('#backup-frequency').val()),
        logRetention: parseInt($('#log-retention').val()),
        maintenanceMode: $('#maintenance-mode').is(':checked')
    };
    
    settings = { ...settings, ...newSettings };
    
    // Trigger FiveM event to save settings
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/saveSettings`, JSON.stringify({
            settings: settings
        }));
    }
    
    showNotification('Settings saved successfully', 'success');
}

function resetSettings() {
    showModal('Reset Settings', 'Are you sure you want to reset all settings to default values?', function() {
        loadSettings(); // Reload default settings
        loadSettingsForm(); // Update form
        showNotification('Settings reset to defaults', 'info');
    });
}

// Utility Functions
function calculateAverageWaitTime() {
    // This would calculate based on actual wait times
    return Math.random() * 10 + 2; // Simulated value between 2-12 minutes
}

function calculateDuration(startTime, endTime) {
    // Simple duration calculation - in real implementation would be more sophisticated
    const start = new Date(`2000-01-01 ${startTime}`);
    const end = new Date(`2000-01-01 ${endTime}`);
    const diff = (end - start) / (1000 * 60); // Minutes
    return `${Math.floor(diff)} minutes`;
}

function getAvailableVehicles() {
    return vehicles.filter(v => v.driver === 'Unassigned').map(v => ({
        id: v.id,
        name: `Taxi #${v.id} (${v.model})`
    }));
}

function updateDriverLocations() {
    // Simulate driver movement
    drivers.forEach(driver => {
        if (driver.status === 'online' || driver.status === 'busy') {
            if (!driver.location) {
                driver.location = { x: Math.random() * 100, y: Math.random() * 100 };
            } else {
                // Small random movement
                driver.location.x += (Math.random() - 0.5) * 5;
                driver.location.y += (Math.random() - 0.5) * 5;
                
                // Keep within bounds
                driver.location.x = Math.max(0, Math.min(100, driver.location.x));
                driver.location.y = Math.max(0, Math.min(100, driver.location.y));
            }
        }
    });
    
    if (currentTab === 'dispatch') {
        updateMapView();
    }
}

function loadCallQueue() {
    callQueue = [
        {
            id: 'CALL-001',
            customerName: 'Medical Transport',
            pickupLocation: 'Downtown Hospital',
            destination: 'Los Scotia Airport',
            priority: 'urgent',
            requestTime: new Date(Date.now() - 5 * 60 * 1000), // 5 minutes ago
            status: 'pending'
        },
        {
            id: 'CALL-002',
            customerName: 'John Smith',
            pickupLocation: '123 Main Street',
            destination: 'City Mall',
            priority: 'normal',
            requestTime: new Date(Date.now() - 3 * 60 * 1000), // 3 minutes ago
            status: 'pending'
        },
        {
            id: 'CALL-003',
            customerName: 'Sarah Johnson',
            pickupLocation: '456 Oak Avenue',
            destination: 'Train Station',
            priority: 'scheduled',
            requestTime: new Date(Date.now() + 30 * 60 * 1000), // 30 minutes from now
            status: 'scheduled'
        }
    ];
}

// Modal Functions
function showModal(title, content, confirmCallback = null) {
    $('#modal-title').text(title);
    $('#modal-body').html(content);
    
    if (confirmCallback) {
        $('#modal-confirm').show().off('click').on('click', function() {
            confirmCallback();
            closeModal();
        });
    } else {
        $('#modal-confirm').hide();
    }
    
    $('#modal-overlay').removeClass('hidden');
}

function closeModal() {
    $('#modal-overlay').addClass('hidden');
}

function confirmModal() {
    // This will be overridden by specific modal confirmCallback
}

// Notification Functions
function showNotification(message, type = 'info', duration = 3000) {
    const notification = $(`
        <div class="notification ${type}">
            <div class="notification-content">
                <i class="fas ${getNotificationIcon(type)}"></i>
                <span>${message}</span>
            </div>
            <button class="notification-close" onclick="closeNotification(this)">×</button>
        </div>
    `);
    
    $('body').append(notification);
    
    // Auto-remove after duration
    setTimeout(() => {
        notification.fadeOut(300, function() {
            $(this).remove();
        });
    }, duration);
}

function getNotificationIcon(type) {
    switch(type) {
        case 'success': return 'fa-check-circle';
        case 'error': return 'fa-exclamation-circle';
        case 'warning': return 'fa-exclamation-triangle';
        default: return 'fa-info-circle';
    }
}

function closeNotification(element) {
    $(element).parent().fadeOut(300, function() {
        $(this).remove();
    });
}

// Event Listeners
function setupEventListeners() {
    // Listen for FiveM events
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'updateDriverStatus':
                updateDriverStatus(data.driverId, data.status);
                break;
            case 'newRideRequest':
                addNewRideRequest(data.ride);
                break;
            case 'updateRideStatus':
                updateRideStatus(data.rideId, data.status);
                break;
            case 'updateEarnings':
                updateDriverEarnings(data.driverId, data.amount);
                break;
            case 'emergencyAlert':
                handleEmergencyAlert(data.alert);
                break;
        }
    });
    
    // Close modal when clicking outside
    $('#modal-overlay').on('click', function(e) {
        if (e.target === this) {
            closeModal();
        }
    });
}

function updateDriverStatus(driverId, status) {
    const driver = drivers.find(d => d.id === driverId);
    if (driver) {
        driver.status = status;
        if (currentTab === 'drivers') {
            refreshDriversView();
        }
        if (currentTab === 'dispatch') {
            updateDispatchStats();
            updateMapView();
        }
    }
}

function addNewRideRequest(ride) {
    callQueue.push(ride);
    if (currentTab === 'dispatch') {
        updateCallQueue();
        updateDispatchStats();
    }
    showNotification('New ride request received', 'info');
}

function updateRideStatus(rideId, status) {
    const ride = rides.find(r => r.id === rideId);
    if (ride) {
        ride.status = status;
        if (currentTab === 'rides') {
            refreshRidesView();
        }
    }
}

function handleEmergencyAlert(alert) {
    showNotification(`EMERGENCY: ${alert.message}`, 'error', 10000);
    
    // Show emergency modal
    showModal('Emergency Alert', `
        <div class="emergency-alert">
            <i class="fas fa-exclamation-triangle" style="color: #ff4444; font-size: 2rem;"></i>
            <h3 style="color: #ff4444; margin: 1rem 0;">Emergency Situation</h3>
            <p><strong>Driver:</strong> ${alert.driverName}</p>
            <p><strong>Vehicle:</strong> ${alert.vehicleId}</p>
            <p><strong>Location:</strong> ${alert.location}</p>
            <p><strong>Details:</strong> ${alert.details}</p>
            <p><strong>Time:</strong> ${new Date(alert.timestamp).toLocaleString()}</p>
        </div>
    `, function() {
        // Handle emergency response
        if (typeof GetParentResourceName !== 'undefined') {
            $.post(`https://${GetParentResourceName()}/emergencyResponse`, JSON.stringify({
                alertId: alert.id,
                response: 'acknowledged'
            }));
        }
    });
}

// Keyboard Shortcuts
function setupKeyboardShortcuts() {
    $(document).on('keydown', function(e) {
        // Ctrl/Cmd + number keys for tab switching
        if ((e.ctrlKey || e.metaKey) && e.key >= '1' && e.key <= '6') {
            e.preventDefault();
            const tabs = ['dispatch', 'drivers', 'vehicles', 'rides', 'earnings', 'settings'];
            const tabIndex = parseInt(e.key) - 1;
            if (tabs[tabIndex]) {
                showTab(tabs[tabIndex]);
            }
        }
        
        // Escape key to close modal
        if (e.key === 'Escape') {
            closeModal();
        }
        
        // Ctrl/Cmd + N for new call
        if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
            e.preventDefault();
            if (currentTab === 'dispatch') {
                newDispatchCall();
            }
        }
    });
}

// Tooltips and UI Enhancements
function initializeTooltips() {
    // Add tooltips to buttons and interactive elements
    $('[data-tooltip]').each(function() {
        $(this).on('mouseenter', function() {
            const tooltip = $('<div class="tooltip"></div>').text($(this).data('tooltip'));
            $('body').append(tooltip);
            
            const rect = this.getBoundingClientRect();
            tooltip.css({
                top: rect.top - tooltip.outerHeight() - 5,
                left: rect.left + (rect.width / 2) - (tooltip.outerWidth() / 2)
            });
        }).on('mouseleave', function() {
            $('.tooltip').remove();
        });
    });
}

// User Preferences
function loadUserPreferences() {
    const preferences = localStorage.getItem('taxiDispatchPreferences');
    if (preferences) {
        const prefs = JSON.parse(preferences);
        // Apply user preferences
        if (prefs.theme) {
            document.body.className = prefs.theme;
        }
    }
}

function saveUserPreferences() {
    const preferences = {
        theme: document.body.className,
        lastTab: currentTab
    };
    localStorage.setItem('taxiDispatchPreferences', JSON.stringify(preferences));
}

// Cleanup and logout
function logout() {
    saveUserPreferences();
    
    // Trigger FiveM event
    if (typeof GetParentResourceName !== 'undefined') {
        $.post(`https://${GetParentResourceName()}/logout`, JSON.stringify({}));
    }
    
    showNotification('Logging out...', 'info');
}

// Map utility functions
function centerMap() {
    // Center map on all active drivers
    updateMapView();
    showNotification('Map centered', 'info');
}

function refreshMap() {
    updateMapView();
    showNotification('Map refreshed', 'info');
}

// Additional utility functions for FiveM integration
function getDispatcherInfo() {
    return {
        name: $('#dispatcher-name').text(),
        shiftStatus: $('#shift-status .status-indicator').hasClass('online') ? 'online' : 'offline',
        currentTab: currentTab
    };
}

function updateDispatcherStatus(status) {
    const indicator = $('#shift-status .status-indicator');
    const text = $('#shift-status span:last-child');
    
    if (status === 'online') {
        indicator.removeClass('offline').addClass('online');
        text.text('Online');
    } else {
        indicator.removeClass('online').addClass('offline');
        text.text('Offline');
    }
}

// Initialize notification system
function initializeNotificationSystem() {
    // Check if notifications are supported
    if ('Notification' in window) {
        if (Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }
}

// Send desktop notification
function sendDesktopNotification(title, message, type = 'info') {
    if ('Notification' in window && Notification.permission === 'granted') {
        const notification = new Notification(title, {
            body: message,
            icon: '/html/assets/taxi-icon.png', // You'd need to add this icon
            badge: '/html/assets/taxi-badge.png'
        });
        
        notification.onclick = function() {
            window.focus();
            notification.close();
        };
        
        setTimeout(() => notification.close(), 5000);
    }
}

// Export functions for external use
window.TaxiDispatch = {
    showTab,
    updateDriverStatus,
    addNewRideRequest,
    updateRideStatus,
    handleEmergencyAlert,
    getDispatcherInfo,
    updateDispatcherStatus,
    showNotification,
    sendDesktopNotification
};