window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openEconomy') {
        document.getElementById('economy-container').classList.remove('hidden');
        if (data.economyData) {
            updateEconomyData(data.economyData);
        }
    }
});

function updateEconomyData(data) {
    if (data.cityFund !== undefined) {
        document.getElementById('city-fund').textContent = '$' + data.cityFund.toLocaleString();
    }
    if (data.taxRate !== undefined) {
        document.getElementById('tax-rate').textContent = data.taxRate + '%';
    }
    if (data.businessCount !== undefined) {
        document.getElementById('business-count').textContent = data.businessCount;
    }
    if (data.employmentRate !== undefined) {
        document.getElementById('employment-rate').textContent = data.employmentRate + '%';
    }
}

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeEconomy`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('economy-container').classList.add('hidden');
});

document.getElementById('set-tax-btn').addEventListener('click', function() {
    const taxRate = document.getElementById('tax-input').value;
    if (taxRate && taxRate >= 0 && taxRate <= 100) {
        fetch(`https://${GetParentResourceName()}/setTaxRate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ rate: parseFloat(taxRate) })
        });
        document.getElementById('tax-input').value = '';
    }
});

document.getElementById('add-fund-btn').addEventListener('click', function() {
    const amount = document.getElementById('fund-input').value;
    if (amount && amount > 0) {
        fetch(`https://${GetParentResourceName()}/addCityFunds`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ amount: parseInt(amount) })
        });
        document.getElementById('fund-input').value = '';
    }
});

document.getElementById('remove-fund-btn').addEventListener('click', function() {
    const amount = document.getElementById('fund-input').value;
    if (amount && amount > 0) {
        fetch(`https://${GetParentResourceName()}/removeCityFunds`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ amount: parseInt(amount) })
        });
        document.getElementById('fund-input').value = '';
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeEconomy`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('economy-container').classList.add('hidden');
    }
});