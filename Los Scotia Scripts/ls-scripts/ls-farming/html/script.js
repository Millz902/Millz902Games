// Los Scotia Farming Management System
let isFarmingPanelOpen = false;

// Panel Management
function openPanel() {
    const container = document.getElementById('container');
    container.classList.remove('hidden');
    isFarmingPanelOpen = true;
    loadFarmingData();
}

function closePanel() {
    const container = document.getElementById('container');
    container.classList.add('hidden');
    isFarmingPanelOpen = false;
    
    // Send close message to Lua
    fetch(`https://${GetParentResourceName()}/closeFarming`, {
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
        case 'crops':
            loadCropData();
            break;
        case 'livestock':
            loadLivestockData();
            break;
        case 'weather':
            loadWeatherData();
            break;
        case 'market':
            loadMarketData();
            break;
        case 'settings':
            loadSettingsData();
            break;
    }
}

// Data Loading Functions
function loadFarmingData() {
    fetch(`https://${GetParentResourceName()}/getFarmingData`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        updateFarmingStats(data);
    })
    .catch(error => {
        console.error('Error loading farming data:', error);
        useDefaultData();
    });
}

function loadOverviewData() {
    // Update overview statistics
    document.getElementById('total-farmland').textContent = '2,450 acres';
    document.getElementById('active-farms').textContent = '23';
    document.getElementById('crop-yield').textContent = '85%';
    document.getElementById('monthly-revenue').textContent = '$450,000';
    document.getElementById('water-usage').textContent = '75%';
    document.getElementById('farmer-count').textContent = '45';
    
    // Update seasonal info
    document.getElementById('current-season').textContent = getCurrentSeason();
    document.getElementById('days-remaining').textContent = '12 days';
    document.getElementById('optimal-crops').textContent = 'Corn, Wheat, Soybeans';
}

function loadCropData() {
    // Crop data is already displayed in HTML
    console.log('Loading crop data...');
}

function loadLivestockData() {
    // Livestock data is already displayed in HTML
    console.log('Loading livestock data...');
}

function loadWeatherData() {
    // Update weather controls
    updateWeatherSliders();
}

function loadMarketData() {
    // Market data is already displayed
    console.log('Loading market data...');
}

function loadSettingsData() {
    // Load current settings
    updateSettingsSliders();
}

function updateFarmingStats(data) {
    if (data && data.stats) {
        const stats = data.stats;
        
        if (stats.totalFarmland) document.getElementById('total-farmland').textContent = stats.totalFarmland + ' acres';
        if (stats.activeFarms) document.getElementById('active-farms').textContent = stats.activeFarms;
        if (stats.cropYield) document.getElementById('crop-yield').textContent = stats.cropYield + '%';
        if (stats.monthlyRevenue) document.getElementById('monthly-revenue').textContent = formatCurrency(stats.monthlyRevenue);
        if (stats.waterUsage) document.getElementById('water-usage').textContent = stats.waterUsage + '%';
        if (stats.farmerCount) document.getElementById('farmer-count').textContent = stats.farmerCount;
    }
}

function useDefaultData() {
    loadOverviewData();
}

// Crop Management Functions
function plantCrops() {
    const cropType = prompt('Enter crop type to plant:', 'Wheat');
    const quantity = prompt('Enter quantity (kg):', '500');
    
    if (cropType && quantity && !isNaN(quantity)) {
        fetch(`https://${GetParentResourceName()}/plantCrops`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                cropType: cropType,
                quantity: parseInt(quantity)
            })
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification(`Successfully planted ${quantity}kg of ${cropType}!`, 'success');
                loadCropData();
            } else {
                showNotification('Failed to plant crops', 'error');
            }
        });
    }
}

function harvestCrops() {
    fetch(`https://${GetParentResourceName()}/harvestCrops`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification(`Harvested ${data.totalHarvested}kg of crops!`, 'success');
            loadCropData();
        } else {
            showNotification('No crops ready for harvest', 'warning');
        }
    });
}

function irrigateFarms() {
    fetch(`https://${GetParentResourceName()}/irrigateFarms`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('All farms have been irrigated!', 'success');
            loadOverviewData();
        }
    });
}

function treatPests() {
    if (confirm('Apply pest control treatment to all affected crops?')) {
        fetch(`https://${GetParentResourceName()}/treatPests`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Pest control treatment applied successfully!', 'success');
                loadCropData();
            }
        });
    }
}

function burnFields() {
    if (confirm('WARNING: This will destroy all crops in selected fields. Continue?')) {
        fetch(`https://${GetParentResourceName()}/burnFields`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Emergency field burning completed', 'warning');
                loadCropData();
            }
        });
    }
}

// Livestock Functions
function feedAnimals() {
    fetch(`https://${GetParentResourceName()}/feedAnimals`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('All animals have been fed!', 'success');
            loadLivestockData();
        }
    });
}

function milkCows() {
    fetch(`https://${GetParentResourceName()}/milkCows`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification(`Collected ${data.milkAmount}L of milk!`, 'success');
            loadLivestockData();
        }
    });
}

function shearSheep() {
    fetch(`https://${GetParentResourceName()}/shearSheep`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification(`Collected ${data.woolAmount}kg of wool!`, 'success');
            loadLivestockData();
        }
    });
}

function collectEggs() {
    fetch(`https://${GetParentResourceName()}/collectEggs`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification(`Collected ${data.eggCount} eggs!`, 'success');
            loadLivestockData();
        }
    });
}

function veterinaryCheck() {
    fetch(`https://${GetParentResourceName()}/veterinaryCheck`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Veterinary check completed for all animals', 'success');
            loadLivestockData();
        }
    });
}

// Weather Functions
function updateWeather() {
    fetch(`https://${GetParentResourceName()}/updateWeather`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Weather data updated!', 'success');
            loadWeatherData();
        }
    });
}

function triggerRain() {
    fetch(`https://${GetParentResourceName()}/triggerRain`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Rain has been triggered!', 'success');
            loadWeatherData();
        }
    });
}

function clearSkies() {
    fetch(`https://${GetParentResourceName()}/clearSkies`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Skies have been cleared!', 'success');
            loadWeatherData();
        }
    });
}

function triggerStorm() {
    if (confirm('Create a severe storm? This may damage crops.')) {
        fetch(`https://${GetParentResourceName()}/triggerStorm`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Severe storm created!', 'warning');
                loadWeatherData();
            }
        });
    }
}

// Market Functions
function sellProduce() {
    const product = prompt('Enter product to sell:', 'Wheat');
    const quantity = prompt('Enter quantity:', '500');
    
    if (product && quantity && !isNaN(quantity)) {
        fetch(`https://${GetParentResourceName()}/sellProduce`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                product: product,
                quantity: parseInt(quantity)
            })
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification(`Sold ${quantity} ${product} for ${formatCurrency(data.revenue)}!`, 'success');
                loadMarketData();
            } else {
                showNotification('Failed to sell produce', 'error');
            }
        });
    }
}

function buySeeds() {
    const seedType = prompt('Enter seed type:', 'Wheat Seeds');
    const quantity = prompt('Enter quantity:', '100');
    
    if (seedType && quantity && !isNaN(quantity)) {
        fetch(`https://${GetParentResourceName()}/buySeeds`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                seedType: seedType,
                quantity: parseInt(quantity)
            })
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification(`Purchased ${quantity} ${seedType} for ${formatCurrency(data.cost)}!`, 'success');
                loadMarketData();
            } else {
                showNotification('Failed to purchase seeds', 'error');
            }
        });
    }
}

function contractFarming() {
    fetch(`https://${GetParentResourceName()}/contractFarming`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Contract farming agreements updated!', 'success');
            loadMarketData();
        }
    });
}

function viewPrices() {
    showNotification('Market prices updated in real-time', 'info');
}

// Settings Functions
function saveSettings() {
    const settings = {
        growthMultiplier: document.getElementById('growth-multiplier').value,
        yieldRate: document.getElementById('yield-rate').value,
        weatherImpact: document.getElementById('weather-impact').value,
        priceVolatility: document.getElementById('price-volatility').value,
        marketTax: document.getElementById('market-tax').value,
        subsidyRate: document.getElementById('subsidy-rate').value,
        seasonalCycles: document.getElementById('seasonal-cycles').checked,
        weatherEffects: document.getElementById('weather-effects').checked,
        pestDisease: document.getElementById('pest-disease').checked,
        livestockAging: document.getElementById('livestock-aging').checked
    };
    
    fetch(`https://${GetParentResourceName()}/saveFarmingSettings`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(settings)
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            showNotification('Farming settings saved successfully!', 'success');
        } else {
            showNotification('Failed to save settings', 'error');
        }
    });
}

function resetSettings() {
    if (confirm('Reset all farming settings to default values?')) {
        fetch(`https://${GetParentResourceName()}/resetFarmingSettings`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('Settings reset to default values!', 'success');
                loadSettingsData();
            }
        });
    }
}

function resetAllFarms() {
    if (confirm('WARNING: This will reset all farm data. All crops and livestock will be lost. Continue?')) {
        fetch(`https://${GetParentResourceName()}/resetAllFarms`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        })
        .then(resp => resp.json())
        .then(data => {
            if (data.success) {
                showNotification('All farms reset successfully!', 'success');
                loadFarmingData();
            }
        });
    }
}

// Utility Functions
function updateWeatherSliders() {
    // Add any weather-specific slider updates here
}

function updateSettingsSliders() {
    const weatherImpact = document.getElementById('weather-impact');
    const priceVolatility = document.getElementById('price-volatility');
    
    if (weatherImpact) {
        document.getElementById('weather-impact-value').textContent = weatherImpact.value + '%';
        weatherImpact.addEventListener('input', function() {
            document.getElementById('weather-impact-value').textContent = this.value + '%';
        });
    }
    
    if (priceVolatility) {
        document.getElementById('price-volatility-value').textContent = priceVolatility.value + '%';
        priceVolatility.addEventListener('input', function() {
            document.getElementById('price-volatility-value').textContent = this.value + '%';
        });
    }
}

function getCurrentSeason() {
    const month = new Date().getMonth();
    if (month >= 2 && month <= 4) return 'Spring';
    if (month >= 5 && month <= 7) return 'Summer';
    if (month >= 8 && month <= 10) return 'Autumn';
    return 'Winter';
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
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
    
    switch(type) {
        case 'success':
            notification.style.background = 'rgba(34, 197, 94, 0.9)';
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
    
    setTimeout(() => {
        notification.style.opacity = '1';
        notification.style.transform = 'translateX(0)';
    }, 100);
    
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
    useDefaultData();
    updateSettingsSliders();
});

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openFarming':
            openPanel();
            break;
        case 'closeFarming':
            closePanel();
            break;
        case 'updateData':
            updateFarmingStats(data.data);
            break;
    }
});

// Keyboard Events
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && isFarmingPanelOpen) {
        closePanel();
    }
});