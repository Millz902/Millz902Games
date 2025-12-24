// Los Scotia Economy Management System
let isEconomyPanelOpen = false;

// Panel Management
function openPanel() {
    const container = document.getElementById('container');
    container.classList.remove('hidden');
    isEconomyPanelOpen = true;
    loadEconomyData();
}

function closePanel() {
    const container = document.getElementById('container');
    container.classList.add('hidden');
    isEconomyPanelOpen = false;
    
    // Send close message to Lua
    fetch(`https://${GetParentResourceName()}/closeEconomy`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

// Tab Management
function switchTab(tabName) {
    // Hide all tab contents
    const tabContents = document.querySelectorAll('.tab-content');
    tabContents.forEach(tab => tab.classList.remove('active'));
    
    // Remove active class from all tab buttons
    const tabButtons = document.querySelectorAll('.tab-btn');
    tabButtons.forEach(btn => btn.classList.remove('active'));
    
    // Show selected tab content
    const selectedTab = document.getElementById(`${tabName}-tab`);
    if (selectedTab) {
        selectedTab.classList.add('active');
    }
    
    // Add active class to clicked button
    event.target.classList.add('active');
    
    // Load specific data for the tab
    switch(tabName) {
        case 'overview':
            loadOverviewData();
            break;
        case 'markets':
            loadMarketData();
            break;
        case 'trade':
            loadTradeData();
            break;
        case 'jobs':
            loadJobsData();
            break;
        case 'settings':
            loadSettingsData();
            break;
    }
}

// Data Loading Functions
function loadEconomyData() {
    fetch(`https://${GetParentResourceName()}/getEconomyData`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        updateEconomyStats(data);
    })
    .catch(error => {
        console.error('Error loading economy data:', error);
        // Use default data if backend not available
        useDefaultData();
    });
}

function loadOverviewData() {
    // Update overview statistics
    document.getElementById('total-money').textContent = '$2,450,000,000';
    document.getElementById('active-businesses').textContent = '156';
    document.getElementById('daily-transactions').textContent = '8,234';
    document.getElementById('avg-wealth').textContent = '$125,000';
    document.getElementById('unemployment-rate').textContent = '3.2%';
    document.getElementById('market-stability').textContent = 'Stable';
}

function loadMarketData() {
    // Market data is loaded dynamically
    console.log('Loading market data...');
}

function loadTradeData() {
    // Update trade controls
    updateTradeControls();
}

function loadJobsData() {
    // Update job statistics
    document.getElementById('police-count').textContent = '12/20';
    document.getElementById('ems-count').textContent = '8/15';
    document.getElementById('gov-count').textContent = '3/8';
    document.getElementById('business-count').textContent = '25/50';
    document.getElementById('taxi-count').textContent = '15/30';
    document.getElementById('mechanic-count').textContent = '10/20';
}

function loadSettingsData() {
    // Load current settings
    console.log('Loading settings data...');
}

function updateEconomyStats(data) {
    if (data && data.stats) {
        // Update stats with real data from server
        const stats = data.stats;
        
        if (stats.totalMoney) document.getElementById('total-money').textContent = formatCurrency(stats.totalMoney);
        if (stats.activeBusinesses) document.getElementById('active-businesses').textContent = stats.activeBusinesses;
        if (stats.dailyTransactions) document.getElementById('daily-transactions').textContent = stats.dailyTransactions.toLocaleString();
        if (stats.avgWealth) document.getElementById('avg-wealth').textContent = formatCurrency(stats.avgWealth);
        if (stats.unemploymentRate) document.getElementById('unemployment-rate').textContent = stats.unemploymentRate + '%';
        if (stats.marketStability) document.getElementById('market-stability').textContent = stats.marketStability;
    }
}

function useDefaultData() {
    // Use default data when server data is not available
    loadOverviewData();
    loadJobsData();
}

// Market Functions
function updatePrices() {
    fetch(`https://${GetParentResourceName()}/updateMarketPrices`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Market prices updated successfully!', 'success');
            loadMarketData();
        } else {
            showNotification('Failed to update market prices', 'error');
        }
    });
}

function resetMarket() {
    if (confirm('Are you sure you want to reset the market? This will restore all prices to default values.')) {
        fetch(`https://${GetParentResourceName()}/resetMarket`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Market reset successfully!', 'success');
                loadMarketData();
            }
        });
    }
}

function crashMarket() {
    if (confirm('WARNING: This will trigger an economic recession. Are you absolutely sure?')) {
        fetch(`https://${GetParentResourceName()}/crashMarket`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Economic recession triggered!', 'warning');
                loadOverviewData();
            }
        });
    }
}

// Trade Functions
function updateTradeControls() {
    const importTax = document.getElementById('import-tax');
    const exportBonus = document.getElementById('export-bonus');
    
    // Update display values
    document.getElementById('import-tax-value').textContent = importTax.value + '%';
    document.getElementById('export-bonus-value').textContent = exportBonus.value + '%';
    
    // Add event listeners
    importTax.addEventListener('input', function() {
        document.getElementById('import-tax-value').textContent = this.value + '%';
        updateTradeSettings();
    });
    
    exportBonus.addEventListener('input', function() {
        document.getElementById('export-bonus-value').textContent = this.value + '%';
        updateTradeSettings();
    });
}

function updateTradeSettings() {
    const importTax = document.getElementById('import-tax').value;
    const exportBonus = document.getElementById('export-bonus').value;
    const tradeLimit = document.getElementById('trade-limit').value;
    
    fetch(`https://${GetParentResourceName()}/updateTradeSettings`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            importTax: parseFloat(importTax),
            exportBonus: parseFloat(exportBonus),
            tradeLimit: parseInt(tradeLimit)
        })
    });
}

// Job Functions
function createJobFair() {
    fetch(`https://${GetParentResourceName()}/createJobFair`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Job fair created! Players will be notified.', 'success');
        }
    });
}

function adjustWages() {
    const newWage = prompt('Enter new base wage (per week):', '1500');
    if (newWage && !isNaN(newWage)) {
        fetch(`https://${GetParentResourceName()}/adjustWages`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                wage: parseInt(newWage)
            })
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification(`Base wage adjusted to $${newWage}/week`, 'success');
                loadJobsData();
            }
        });
    }
}

function unemploymentBenefit() {
    fetch(`https://${GetParentResourceName()}/toggleUnemploymentBenefit`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            const status = data.enabled ? 'enabled' : 'disabled';
            showNotification(`Unemployment benefits ${status}`, 'info');
        }
    });
}

// Settings Functions
function saveSettings() {
    const settings = {
        interestRate: document.getElementById('interest-rate').value,
        taxRate: document.getElementById('tax-rate').value,
        minWage: document.getElementById('min-wage').value,
        priceControls: document.getElementById('price-controls').checked,
        monopolyPrevention: document.getElementById('monopoly-prevention').checked,
        marketVolatility: document.getElementById('market-volatility').checked
    };
    
    fetch(`https://${GetParentResourceName()}/saveEconomySettings`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(settings)
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Economy settings saved successfully!', 'success');
        } else {
            showNotification('Failed to save settings', 'error');
        }
    });
}

function resetEconomy() {
    if (confirm('WARNING: This will reset the entire economy system. All data will be lost. Continue?')) {
        fetch(`https://${GetParentResourceName()}/resetEconomy`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Economy system reset successfully!', 'success');
                loadEconomyData();
            }
        });
    }
}

function economicEmergency() {
    if (confirm('Activate emergency economic controls? This will freeze all transactions.')) {
        fetch(`https://${GetParentResourceName()}/economicEmergency`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Emergency economic controls activated!', 'warning');
            }
        });
    }
}

// Utility Functions
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    // Style the notification
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        border-radius: 5px;
        color: white;
        font-weight: bold;
        z-index: 10000;
        opacity: 0;
        transform: translateX(100%);
        transition: all 0.3s;
    `;
    
    // Set background color based on type
    switch(type) {
        case 'success':
            notification.style.background = 'rgba(16, 185, 129, 0.9)';
            break;
        case 'error':
            notification.style.background = 'rgba(239, 68, 68, 0.9)';
            break;
        case 'warning':
            notification.style.background = 'rgba(245, 158, 11, 0.9)';
            break;
        default:
            notification.style.background = 'rgba(59, 130, 246, 0.9)';
    }
    
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.opacity = '1';
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Event Listeners
document.addEventListener('DOMContentLoaded', function() {
    // Initialize default data
    useDefaultData();
    updateTradeControls();
});

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openEconomy':
            openPanel();
            break;
        case 'closeEconomy':
            closePanel();
            break;
        case 'updateData':
            updateEconomyStats(data.data);
            break;
    }
});

// Keyboard Events
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && isEconomyPanelOpen) {
        closePanel();
    }
});