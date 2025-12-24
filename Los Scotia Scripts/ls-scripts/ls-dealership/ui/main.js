let currentView = 'vehicles';
let selectedVehicle = null;
let vehicles = [];
let ownedVehicles = [];

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadDealershipData();
});

// Set up event listeners
function setupEventListeners() {
    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeDealership);

    // Filter buttons
    document.getElementById('applyFilters').addEventListener('click', applyFilters);

    // Back button
    document.getElementById('backBtn').addEventListener('click', showVehiclesList);

    // Purchase and test drive buttons
    document.getElementById('testDriveBtn').addEventListener('click', testDriveVehicle);
    document.getElementById('purchaseBtn').addEventListener('click', purchaseVehicle);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeDealership();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openDealership':
                openDealership();
                break;
            case 'closeDealership':
                closeDealership();
                break;
            case 'updateVehicles':
                updateVehiclesList(data.vehicles);
                break;
            case 'updateOwnedVehicles':
                updateOwnedVehicles(data.ownedVehicles);
                break;
            case 'showVehicleDetails':
                showVehicleDetails(data.vehicle);
                break;
        }
    });
}

// Open dealership interface
function openDealership() {
    document.getElementById('container').classList.remove('hidden');
    sendCallback('dealership:opened', {});
}

// Close dealership interface
function closeDealership() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('dealership:closed', {});
}

// Load dealership data
function loadDealershipData() {
    sendCallback('dealership:requestData', {});
}

// Update vehicles list
function updateVehiclesList(vehicleData) {
    vehicles = vehicleData || [];
    renderVehiclesList();
}

// Render vehicles list
function renderVehiclesList() {
    const vehiclesList = document.getElementById('vehiclesList');
    
    if (vehicles.length === 0) {
        vehiclesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No vehicles available</p>';
        return;
    }
    
    let html = '';
    vehicles.forEach(vehicle => {
        html += `
            <div class="vehicle-card" onclick="selectVehicle('${vehicle.model}')">
                <h4>${vehicle.name}</h4>
                <div class="category">${vehicle.category}</div>
                <div class="price">$${vehicle.price.toLocaleString()}</div>
                <div class="stats">
                    <div class="stat-item">
                        <span class="label">Speed:</span>
                        <span class="value">${vehicle.speed}/10</span>
                    </div>
                    <div class="stat-item">
                        <span class="label">Accel:</span>
                        <span class="value">${vehicle.acceleration}/10</span>
                    </div>
                    <div class="stat-item">
                        <span class="label">Brake:</span>
                        <span class="value">${vehicle.braking}/10</span>
                    </div>
                    <div class="stat-item">
                        <span class="label">Handle:</span>
                        <span class="value">${vehicle.handling}/10</span>
                    </div>
                </div>
                <button class="view-btn" onclick="event.stopPropagation(); selectVehicle('${vehicle.model}')">View Details</button>
            </div>
        `;
    });
    
    vehiclesList.innerHTML = html;
}

// Apply filters
function applyFilters() {
    const category = document.getElementById('categoryFilter').value;
    const priceRange = document.getElementById('priceFilter').value;
    
    const filterData = {
        category: category,
        priceRange: priceRange
    };
    
    sendCallback('dealership:applyFilters', filterData);
    showNotification('Filters applied', 'info');
}

// Select vehicle
function selectVehicle(model) {
    const vehicle = vehicles.find(v => v.model === model);
    if (vehicle) {
        selectedVehicle = vehicle;
        showVehicleDetails(vehicle);
        sendCallback('dealership:selectVehicle', { model: model });
    }
}

// Show vehicle details
function showVehicleDetails(vehicle) {
    document.querySelector('.vehicles-section').classList.add('hidden');
    document.querySelector('.owned-vehicles-section').classList.add('hidden');
    document.getElementById('vehicleDetails').classList.remove('hidden');
    
    // Update vehicle details
    document.getElementById('vehicleName').textContent = vehicle.name;
    document.getElementById('vehiclePrice').textContent = `$${vehicle.price.toLocaleString()}`;
    document.getElementById('vehicleCategory').textContent = vehicle.category;
    document.getElementById('vehicleSpeed').textContent = `${vehicle.speed}/10`;
    document.getElementById('vehicleAccel').textContent = `${vehicle.acceleration}/10`;
    document.getElementById('vehicleBraking').textContent = `${vehicle.braking}/10`;
    document.getElementById('vehicleHandling').textContent = `${vehicle.handling}/10`;
    
    currentView = 'details';
}

// Show vehicles list
function showVehiclesList() {
    document.getElementById('vehicleDetails').classList.add('hidden');
    document.querySelector('.vehicles-section').classList.remove('hidden');
    document.querySelector('.owned-vehicles-section').classList.remove('hidden');
    
    currentView = 'vehicles';
}

// Test drive vehicle
function testDriveVehicle() {
    if (!selectedVehicle) {
        showNotification('No vehicle selected', 'error');
        return;
    }
    
    sendCallback('dealership:testDrive', { 
        model: selectedVehicle.model,
        name: selectedVehicle.name 
    });
    showNotification(`Starting test drive: ${selectedVehicle.name}`, 'success');
}

// Purchase vehicle
function purchaseVehicle() {
    if (!selectedVehicle) {
        showNotification('No vehicle selected', 'error');
        return;
    }
    
    sendCallback('dealership:purchase', { 
        model: selectedVehicle.model,
        name: selectedVehicle.name,
        price: selectedVehicle.price 
    });
    showNotification(`Purchasing: ${selectedVehicle.name}`, 'info');
}

// Update owned vehicles
function updateOwnedVehicles(ownedData) {
    ownedVehicles = ownedData || [];
    renderOwnedVehicles();
}

// Render owned vehicles
function renderOwnedVehicles() {
    const ownedList = document.getElementById('ownedVehiclesList');
    
    if (ownedVehicles.length === 0) {
        ownedList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 20px;">No vehicles owned</p>';
        return;
    }
    
    let html = '';
    ownedVehicles.forEach(vehicle => {
        html += `
            <div class="owned-vehicle-card">
                <h5>${vehicle.name}</h5>
                <div class="plate">Plate: ${vehicle.plate}</div>
                <div class="location">Location: ${vehicle.location}</div>
                <button class="manage-btn" onclick="manageVehicle('${vehicle.plate}')">Manage</button>
            </div>
        `;
    });
    
    ownedList.innerHTML = html;
}

// Manage vehicle
function manageVehicle(plate) {
    sendCallback('dealership:manageVehicle', { plate: plate });
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#2ecc71' : type === 'error' ? '#e74c3c' : '#f39c12'};
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