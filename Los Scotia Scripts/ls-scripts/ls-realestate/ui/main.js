let currentView = 'properties';
let selectedProperty = null;
let properties = [];
let ownedProperties = [];

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadRealEstateData();
});

// Set up event listeners
function setupEventListeners() {
    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeRealEstate);

    // Search button
    document.getElementById('searchBtn').addEventListener('click', searchProperties);

    // Back button
    document.getElementById('backToListBtn').addEventListener('click', showPropertiesList);

    // Property action buttons
    document.getElementById('scheduleViewingBtn').addEventListener('click', scheduleViewing);
    document.getElementById('purchasePropertyBtn').addEventListener('click', purchaseProperty);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeRealEstate();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openRealEstate':
                openRealEstate();
                break;
            case 'closeRealEstate':
                closeRealEstate();
                break;
            case 'updateProperties':
                updatePropertiesList(data.properties);
                break;
            case 'updateOwnedProperties':
                updateOwnedProperties(data.ownedProperties);
                break;
            case 'showPropertyDetails':
                showPropertyDetails(data.property);
                break;
        }
    });
}

// Open real estate interface
function openRealEstate() {
    document.getElementById('container').classList.remove('hidden');
    sendCallback('realestate:opened', {});
}

// Close real estate interface
function closeRealEstate() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('realestate:closed', {});
}

// Load real estate data
function loadRealEstateData() {
    sendCallback('realestate:requestData', {});
}

// Update properties list
function updatePropertiesList(propertyData) {
    properties = propertyData || [];
    renderPropertiesList();
}

// Render properties list
function renderPropertiesList() {
    const propertiesList = document.getElementById('propertiesList');
    
    if (properties.length === 0) {
        propertiesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No properties available</p>';
        return;
    }
    
    let html = '';
    properties.forEach(property => {
        html += `
            <div class="property-card" onclick="selectProperty('${property.id}')">
                <h4>${property.name}</h4>
                <div class="type">${property.type}</div>
                <div class="location">${property.location}</div>
                <div class="price">$${property.price.toLocaleString()}</div>
                <div class="property-features">
                    <div class="feature-item">
                        <span class="label">Bedrooms:</span>
                        <span class="value">${property.bedrooms}</span>
                    </div>
                    <div class="feature-item">
                        <span class="label">Bathrooms:</span>
                        <span class="value">${property.bathrooms}</span>
                    </div>
                    <div class="feature-item">
                        <span class="label">Size:</span>
                        <span class="value">${property.size} sqft</span>
                    </div>
                    <div class="feature-item">
                        <span class="label">Parking:</span>
                        <span class="value">${property.parking}</span>
                    </div>
                </div>
                <button class="view-property-btn" onclick="event.stopPropagation(); selectProperty('${property.id}')">View Details</button>
            </div>
        `;
    });
    
    propertiesList.innerHTML = html;
}

// Search properties
function searchProperties() {
    const propertyType = document.getElementById('propertyType').value;
    const priceRange = document.getElementById('priceRange').value;
    const location = document.getElementById('location').value;
    
    const searchData = {
        type: propertyType,
        priceRange: priceRange,
        location: location
    };
    
    sendCallback('realestate:searchProperties', searchData);
    showNotification('Searching properties...', 'info');
}

// Select property
function selectProperty(propertyId) {
    const property = properties.find(p => p.id === propertyId);
    if (property) {
        selectedProperty = property;
        showPropertyDetails(property);
        sendCallback('realestate:selectProperty', { propertyId: propertyId });
    }
}

// Show property details
function showPropertyDetails(property) {
    document.querySelector('.property-search').classList.add('hidden');
    document.querySelector('.properties-list').classList.add('hidden');
    document.querySelector('.my-properties').classList.add('hidden');
    document.getElementById('propertyDetails').classList.remove('hidden');
    
    // Update property details
    document.getElementById('propertyName').textContent = property.name;
    document.getElementById('propertyPrice').textContent = `$${property.price.toLocaleString()}`;
    document.getElementById('propertyType').textContent = property.type;
    document.getElementById('propertyLocation').textContent = property.location;
    document.getElementById('propertySize').textContent = `${property.size} sqft`;
    document.getElementById('propertyBedrooms').textContent = property.bedrooms;
    document.getElementById('propertyBathrooms').textContent = property.bathrooms;
    document.getElementById('propertyDesc').textContent = property.description || 'No description available.';
    
    currentView = 'details';
}

// Show properties list
function showPropertiesList() {
    document.getElementById('propertyDetails').classList.add('hidden');
    document.querySelector('.property-search').classList.remove('hidden');
    document.querySelector('.properties-list').classList.remove('hidden');
    document.querySelector('.my-properties').classList.remove('hidden');
    
    currentView = 'properties';
}

// Schedule viewing
function scheduleViewing() {
    if (!selectedProperty) {
        showNotification('No property selected', 'error');
        return;
    }
    
    sendCallback('realestate:scheduleViewing', { 
        propertyId: selectedProperty.id,
        propertyName: selectedProperty.name 
    });
    showNotification(`Viewing scheduled for: ${selectedProperty.name}`, 'success');
}

// Purchase property
function purchaseProperty() {
    if (!selectedProperty) {
        showNotification('No property selected', 'error');
        return;
    }
    
    sendCallback('realestate:purchaseProperty', { 
        propertyId: selectedProperty.id,
        propertyName: selectedProperty.name,
        price: selectedProperty.price 
    });
    showNotification(`Purchase initiated: ${selectedProperty.name}`, 'info');
}

// Update owned properties
function updateOwnedProperties(ownedData) {
    ownedProperties = ownedData || [];
    renderOwnedProperties();
}

// Render owned properties
function renderOwnedProperties() {
    const ownedList = document.getElementById('myPropertiesList');
    
    if (ownedProperties.length === 0) {
        ownedList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 20px;">No properties owned</p>';
        return;
    }
    
    let html = '';
    ownedProperties.forEach(property => {
        html += `
            <div class="owned-property-card">
                <h5>${property.name}</h5>
                <div class="value">Value: $${property.value.toLocaleString()}</div>
                <div class="rent-income">Monthly Income: $${property.rentIncome}</div>
                <button class="manage-property-btn" onclick="manageProperty('${property.id}')">Manage</button>
            </div>
        `;
    });
    
    ownedList.innerHTML = html;
}

// Manage property
function manageProperty(propertyId) {
    sendCallback('realestate:manageProperty', { propertyId: propertyId });
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