let currentVehicleData = null;
let currentFinanceQuote = null;
let currentTradeInValue = 0;
let allVehicles = [];

// Event listeners
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openDealership':
            openDealership(data);
            break;
        case 'closeDealership':
            closeDealership();
            break;
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (!document.getElementById('vehicle-modal').classList.contains('hidden')) {
            closeModal();
        } else {
            closeDealership();
        }
    }
});

// Main functions
function openDealership(data) {
    const container = document.getElementById('dealership-container');
    const dealershipName = document.getElementById('dealership-name');
    
    dealershipName.textContent = data.dealership.name;
    allVehicles = data.vehicles;
    
    updatePlayerMoney(data.playerMoney);
    populateVehicles(data.vehicles);
    
    container.classList.remove('hidden');
}

function closeDealership() {
    const container = document.getElementById('dealership-container');
    container.classList.add('hidden');
    
    // Reset UI
    showTab('browse');
    closeModal();
    
    fetch('https://ls-dealership/closeDealership', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
}

function updatePlayerMoney(totalMoney) {
    // For simplicity, assume split between cash and bank
    const cash = Math.floor(totalMoney * 0.1);
    const bank = totalMoney - cash;
    
    document.getElementById('player-cash').textContent = formatMoney(cash);
    document.getElementById('player-bank').textContent = formatMoney(bank);
}

function populateVehicles(vehicles) {
    const grid = document.getElementById('vehicles-grid');
    grid.innerHTML = '';
    
    vehicles.forEach((vehicle, index) => {
        const card = createVehicleCard(vehicle, index);
        grid.appendChild(card);
    });
}

function createVehicleCard(vehicle, index) {
    const card = document.createElement('div');
    card.className = 'vehicle-card';
    card.onclick = () => openVehicleModal(vehicle);
    
    card.innerHTML = `
        <div class="vehicle-name">${vehicle.name}</div>
        <div class="vehicle-price">$${formatMoney(vehicle.price)}</div>
        <div class="vehicle-category">${vehicle.category}</div>
    `;
    
    return card;
}

function openVehicleModal(vehicle) {
    currentVehicleData = vehicle;
    
    document.getElementById('modal-vehicle-name').textContent = vehicle.name;
    document.getElementById('modal-vehicle-price').textContent = '$' + formatMoney(vehicle.price);
    document.getElementById('modal-vehicle-category').textContent = vehicle.category;
    
    // Reset purchase options
    document.getElementById('purchase-options').classList.add('hidden');
    document.getElementById('use-tradein').checked = false;
    
    document.getElementById('vehicle-modal').classList.remove('hidden');
}

function closeModal() {
    document.getElementById('vehicle-modal').classList.add('hidden');
    currentVehicleData = null;
}

function showTab(tabName) {
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Remove active class from all buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Show selected tab
    document.getElementById(tabName + '-tab').classList.add('active');
    
    // Add active class to clicked button
    event.target.classList.add('active');
}

function startTestDrive() {
    if (!currentVehicleData) return;
    
    fetch('https://ls-dealership/startTestDrive', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            model: currentVehicleData.model
        })
    }).then(response => response.json())
    .then(data => {
        if (data.success) {
            closeModal();
            closeDealership();
        } else {
            showNotification(data.message || 'Test drive failed', 'error');
        }
    });
}

function showPurchaseOptions() {
    document.getElementById('purchase-options').classList.toggle('hidden');
}

function purchaseVehicle(paymentMethod) {
    if (!currentVehicleData) return;
    
    let purchaseData = {
        model: currentVehicleData.model,
        price: currentVehicleData.price,
        paymentMethod: paymentMethod
    };
    
    // Add trade-in data if selected
    if (document.getElementById('use-tradein').checked && currentTradeInValue > 0) {
        purchaseData.tradeIn = {
            plate: document.getElementById('tradein-plate').value,
            value: currentTradeInValue
        };
    }
    
    // Add finance data if financing
    if (paymentMethod === 'finance' && currentFinanceQuote) {
        purchaseData.financeData = {
            downPayment: currentFinanceQuote.downPayment,
            loanTerm: currentFinanceQuote.loanTerm
        };
    }
    
    fetch('https://ls-dealership/purchaseVehicle', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(purchaseData)
    });
}

function calculateFinance() {
    const price = parseInt(document.getElementById('finance-price').value);
    const downPayment = parseInt(document.getElementById('finance-down').value);
    const loanTerm = parseInt(document.getElementById('finance-term').value);
    
    if (!price || !downPayment || downPayment < price * 0.1) {
        showNotification('Please enter valid amounts (minimum 10% down payment)', 'error');
        return;
    }
    
    fetch('https://ls-dealership/getFinanceQuote', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            vehiclePrice: price,
            downPayment: downPayment,
            loanTerm: loanTerm
        })
    }).then(response => response.json())
    .then(data => {
        if (data.approved) {
            currentFinanceQuote = {
                downPayment: downPayment,
                loanTerm: loanTerm,
                ...data
            };
            
            document.getElementById('monthly-payment').textContent = '$' + formatMoney(data.monthlyPayment);
            document.getElementById('total-cost').textContent = '$' + formatMoney(data.totalCost);
            document.getElementById('interest-rate').textContent = (data.interestRate * 100).toFixed(2) + '%';
            document.getElementById('credit-score').textContent = data.creditScore;
            
            document.getElementById('finance-results').classList.remove('hidden');
        } else {
            showNotification('Financing denied: ' + data.reason, 'error');
            document.getElementById('finance-results').classList.add('hidden');
        }
    });
}

function getTradeInValue() {
    const plate = document.getElementById('tradein-plate').value.trim();
    
    if (!plate) {
        showNotification('Please enter a license plate', 'error');
        return;
    }
    
    fetch('https://ls-dealership/getTradeInValue', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            plate: plate
        })
    }).then(response => response.json())
    .then(data => {
        currentTradeInValue = data.value;
        document.getElementById('tradein-value').textContent = '$' + formatMoney(data.value);
        document.getElementById('tradein-results').classList.remove('hidden');
        
        if (data.value > 0) {
            showNotification('Trade-in value calculated successfully', 'success');
        } else {
            showNotification('No eligible vehicle found for trade-in', 'error');
        }
    });
}

// Filter functions
document.getElementById('category-filter').addEventListener('change', function() {
    filterVehicles();
});

document.getElementById('price-filter').addEventListener('change', function() {
    filterVehicles();
});

function filterVehicles() {
    const categoryFilter = document.getElementById('category-filter').value;
    const priceFilter = document.getElementById('price-filter').value;
    
    let filteredVehicles = allVehicles;
    
    // Filter by category
    if (categoryFilter) {
        filteredVehicles = filteredVehicles.filter(vehicle => vehicle.category === categoryFilter);
    }
    
    // Filter by price
    if (priceFilter) {
        const [minPrice, maxPrice] = priceFilter.split('-').map(Number);
        filteredVehicles = filteredVehicles.filter(vehicle => {
            return vehicle.price >= minPrice && vehicle.price <= maxPrice;
        });
    }
    
    populateVehicles(filteredVehicles);
}

// Utility functions
function formatMoney(amount) {
    return amount.toLocaleString();
}

function showNotification(message, type) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 8px;
        color: white;
        font-weight: 500;
        z-index: 9999;
        animation: slideIn 0.3s ease;
        ${type === 'success' ? 'background: linear-gradient(135deg, #4CAF50, #45a049);' : 'background: linear-gradient(135deg, #f44336, #da190b);'}
    `;
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease forwards';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);