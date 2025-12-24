const vehiclePrices = {
    blista: 50,
    sultan: 75,
    rumpo: 100,
    sanchez: 30
};

let selectedVehicle = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openRental') {
        document.getElementById('rental-container').classList.remove('hidden');
        if (data.rentalData) {
            updateRentalData(data.rentalData);
        }
    }
});

function updateRentalData(data) {
    // Update available vehicles or rental status
    if (data.currentRental) {
        document.getElementById('return-btn').style.display = 'block';
    } else {
        document.getElementById('return-btn').style.display = 'none';
    }
}

function calculateTotal() {
    if (!selectedVehicle) return 0;
    
    const basePrice = vehiclePrices[selectedVehicle];
    const duration = parseInt(document.getElementById('rental-duration').value);
    const insurance = document.getElementById('insurance-option').checked ? 20 : 0;
    
    return (basePrice + insurance) * duration;
}

function updateTotalCost() {
    const total = calculateTotal();
    document.getElementById('total-cost').textContent = '$' + total.toLocaleString();
    
    // Enable/disable rent button
    document.getElementById('rent-btn').disabled = !selectedVehicle;
}

// Vehicle selection
document.querySelectorAll('.vehicle-card').forEach(card => {
    card.addEventListener('click', function() {
        // Remove previous selection
        document.querySelectorAll('.vehicle-card').forEach(c => c.classList.remove('selected'));
        
        // Select this vehicle
        this.classList.add('selected');
        selectedVehicle = this.dataset.vehicle;
        
        updateTotalCost();
    });
});

// Duration and insurance change
document.getElementById('rental-duration').addEventListener('change', updateTotalCost);
document.getElementById('insurance-option').addEventListener('change', updateTotalCost);

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeRental`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('rental-container').classList.add('hidden');
});

document.getElementById('rent-btn').addEventListener('click', function() {
    if (!selectedVehicle) return;
    
    const duration = parseInt(document.getElementById('rental-duration').value);
    const insurance = document.getElementById('insurance-option').checked;
    const totalCost = calculateTotal();
    
    fetch(`https://${GetParentResourceName()}/rentVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            vehicle: selectedVehicle,
            duration: duration,
            insurance: insurance,
            cost: totalCost
        })
    });
});

document.getElementById('return-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/returnVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeRental`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('rental-container').classList.add('hidden');
    }
});

// Initialize
updateTotalCost();