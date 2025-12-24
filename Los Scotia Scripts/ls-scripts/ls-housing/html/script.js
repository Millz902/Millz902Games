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

    // Property action button handlers
    document.getElementById('buy-property').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/buyProperty`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('rent-property').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/rentProperty`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('pay-rent').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/payRent`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('search-btn').addEventListener('click', function() {
        const searchTerm = document.getElementById('search-input').value;
        const priceFilter = document.getElementById('price-filter').value;
        
        fetch(`https://${GetParentResourceName()}/searchProperties`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                search: searchTerm,
                priceFilter: priceFilter
            })
        });
    });

    // Management option button handlers
    document.querySelectorAll('.option-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const option = this.textContent.toLowerCase().replace(' ', '');
            fetch(`https://${GetParentResourceName()}/manageProperty`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    option: option
                })
            });
        });
    });

    // Listen for messages from the client
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'show':
                container.classList.remove('hidden');
                if(data.housingData) {
                    updateHousingInfo(data.housingData);
                }
                break;
                
            case 'hide':
                container.classList.add('hidden');
                break;
                
            case 'updateProperties':
                if(data.properties) {
                    updatePropertyList(data.properties);
                }
                break;
                
            case 'updateRentals':
                if(data.rentals) {
                    updateRentalList(data.rentals);
                }
                break;
                
            case 'updateMarket':
                if(data.market) {
                    updateMarketInfo(data.market);
                }
                break;
                
            case 'updateAvailableProperties':
                if(data.availableProperties) {
                    updateAvailableProperties(data.availableProperties);
                }
                break;
        }
    });

    // Update housing information
    function updateHousingInfo(housingData) {
        if(housingData.properties) {
            updatePropertyList(housingData.properties);
        }
        if(housingData.rentals) {
            updateRentalList(housingData.rentals);
        }
        if(housingData.market) {
            updateMarketInfo(housingData.market);
        }
    }

    // Update property list
    function updatePropertyList(properties) {
        const propertyList = document.querySelector('.property-list');
        propertyList.innerHTML = '';
        
        if(properties && properties.length > 0) {
            properties.forEach(property => {
                const propertyDiv = document.createElement('div');
                propertyDiv.className = 'property-item';
                propertyDiv.innerHTML = `
                    <div class="property-info">
                        <span class="property-name">${property.name}</span>
                        <span class="property-address">${property.address}</span>
                        <span class="property-price">$${property.price}</span>
                    </div>
                    <div class="property-actions">
                        <button onclick="enterProperty(${property.id})">Enter</button>
                        <button onclick="manageProperty(${property.id})">Manage</button>
                        <button class="danger" onclick="sellProperty(${property.id})">Sell</button>
                    </div>
                `;
                propertyList.appendChild(propertyDiv);
            });
        } else {
            propertyList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No properties owned</p>';
        }
    }

    // Update rental list
    function updateRentalList(rentals) {
        const rentalList = document.querySelector('.rental-list');
        rentalList.innerHTML = '';
        
        if(rentals && rentals.length > 0) {
            rentals.forEach(rental => {
                const rentalDiv = document.createElement('div');
                rentalDiv.className = 'rental-item';
                rentalDiv.innerHTML = `
                    <div class="rental-info">
                        <span class="rental-name">${rental.name}</span>
                        <span class="rental-address">${rental.address}</span>
                        <span class="rental-price">$${rental.rent}/month</span>
                    </div>
                    <div class="rental-actions">
                        <button onclick="enterRental(${rental.id})">Enter</button>
                        <button class="danger" onclick="cancelRental(${rental.id})">Cancel</button>
                    </div>
                `;
                rentalList.appendChild(rentalDiv);
            });
        } else {
            rentalList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No active rentals</p>';
        }
    }

    // Update market information
    function updateMarketInfo(market) {
        document.getElementById('available-properties').textContent = market.availableProperties || 0;
        document.getElementById('average-price').textContent = `$${market.averagePrice || 0}`;
        
        const trendElement = document.getElementById('market-trend');
        trendElement.textContent = market.trend || 'Stable';
        trendElement.className = `trend-${(market.trend || 'stable').toLowerCase()}`;
    }

    // Update available properties in market
    function updateAvailableProperties(availableProperties) {
        const availableList = document.querySelector('.available-properties');
        availableList.innerHTML = '';
        
        if(availableProperties && availableProperties.length > 0) {
            availableProperties.forEach(property => {
                const propertyDiv = document.createElement('div');
                propertyDiv.className = 'property-item';
                propertyDiv.innerHTML = `
                    <div class="property-info">
                        <span class="property-name">${property.name}</span>
                        <span class="property-address">${property.address}</span>
                        <span class="property-price">$${property.price}</span>
                    </div>
                    <div class="property-actions">
                        <button onclick="viewProperty(${property.id})">View</button>
                        <button onclick="buyPropertyFromMarket(${property.id})">Buy</button>
                    </div>
                `;
                availableList.appendChild(propertyDiv);
            });
        } else {
            availableList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No properties available</p>';
        }
    }

    // Global functions for property actions
    window.enterProperty = function(propertyId) {
        fetch(`https://${GetParentResourceName()}/enterProperty`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ propertyId: propertyId })
        });
    };

    window.manageProperty = function(propertyId) {
        fetch(`https://${GetParentResourceName()}/manageSpecificProperty`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ propertyId: propertyId })
        });
    };

    window.sellProperty = function(propertyId) {
        fetch(`https://${GetParentResourceName()}/sellProperty`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ propertyId: propertyId })
        });
    };

    window.enterRental = function(rentalId) {
        fetch(`https://${GetParentResourceName()}/enterRental`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ rentalId: rentalId })
        });
    };

    window.cancelRental = function(rentalId) {
        fetch(`https://${GetParentResourceName()}/cancelRental`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ rentalId: rentalId })
        });
    };

    window.viewProperty = function(propertyId) {
        fetch(`https://${GetParentResourceName()}/viewProperty`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ propertyId: propertyId })
        });
    };

    window.buyPropertyFromMarket = function(propertyId) {
        fetch(`https://${GetParentResourceName()}/buyPropertyFromMarket`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ propertyId: propertyId })
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