window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openBanking') {
        document.getElementById('banking-container').classList.remove('hidden');
        if (data.playerData && data.playerData.money) {
            document.getElementById('bank-balance').textContent = '$' + data.playerData.money.bank.toLocaleString();
        }
    }
});

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeBanking`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('banking-container').classList.add('hidden');
});

document.getElementById('withdraw-btn').addEventListener('click', function() {
    const amount = document.getElementById('withdraw-amount').value;
    if (amount && amount > 0) {
        fetch(`https://${GetParentResourceName()}/withdraw`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ amount: parseInt(amount) })
        });
        document.getElementById('withdraw-amount').value = '';
    }
});

document.getElementById('deposit-btn').addEventListener('click', function() {
    const amount = document.getElementById('deposit-amount').value;
    if (amount && amount > 0) {
        fetch(`https://${GetParentResourceName()}/deposit`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ amount: parseInt(amount) })
        });
        document.getElementById('deposit-amount').value = '';
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeBanking`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('banking-container').classList.add('hidden');
    }
});