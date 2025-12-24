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

    // File claim functionality
    document.getElementById('file-claim-btn').addEventListener('click', function() {
        const claimType = document.getElementById('claim-type').value;
        const claimAmount = document.getElementById('claim-amount').value;
        const claimDescription = document.getElementById('claim-description').value;
        
        if (!claimAmount || claimAmount <= 0) {
            showNotification('Please enter a valid claim amount', 'error');
            return;
        }
        
        if (!claimDescription.trim()) {
            showNotification('Please provide a description', 'error');
            return;
        }
        
        fetch(`https://${GetParentResourceName()}/fileClaim`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                type: claimType,
                amount: parseInt(claimAmount),
                description: claimDescription
            })
        });
        
        // Clear form
        document.getElementById('claim-amount').value = '';
        document.getElementById('claim-description').value = '';
    });

    // Purchase insurance functionality
    document.querySelectorAll('.purchase-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const packageType = this.getAttribute('data-package');
            
            fetch(`https://${GetParentResourceName()}/purchaseInsurance`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    package: packageType
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
                if(data.insuranceData) {
                    updateInsuranceData(data.insuranceData);
                }
                break;
                
            case 'hide':
                container.classList.add('hidden');
                break;
                
            case 'updateInsurance':
                if(data.insuranceData) {
                    updateInsuranceData(data.insuranceData);
                }
                break;
                
            case 'updateClaims':
                if(data.claims) {
                    updateClaimsHistory(data.claims);
                }
                break;
                
            case 'notification':
                showNotification(data.message, data.type);
                break;
        }
    });

    // Update insurance data
    function updateInsuranceData(insuranceData) {
        // Update overview stats
        document.getElementById('active-policies').textContent = insuranceData.activePolicies || 0;
        document.getElementById('total-coverage').textContent = `$${(insuranceData.totalCoverage || 0).toLocaleString()}`;
        document.getElementById('monthly-premium').textContent = `$${(insuranceData.monthlyPremium || 0).toLocaleString()}`;
        
        // Update coverage breakdown
        updateCoverageList(insuranceData.coverage);
        
        // Update policies list
        updatePoliciesList(insuranceData.policies);
    }

    // Update coverage list
    function updateCoverageList(coverage) {
        const coverageList = document.getElementById('coverage-list');
        coverageList.innerHTML = '';
        
        if (coverage && coverage.length > 0) {
            coverage.forEach(item => {
                const coverageDiv = document.createElement('div');
                coverageDiv.className = 'coverage-item';
                coverageDiv.innerHTML = `
                    <span class="coverage-type">${item.type}</span>
                    <span class="coverage-amount">$${item.amount.toLocaleString()}</span>
                `;
                coverageList.appendChild(coverageDiv);
            });
        } else {
            coverageList.innerHTML = `
                <div class="coverage-item">
                    <span class="coverage-type">No active policies</span>
                    <span class="coverage-amount">-</span>
                </div>
            `;
        }
    }

    // Update policies list
    function updatePoliciesList(policies) {
        const policiesList = document.getElementById('policies-list');
        policiesList.innerHTML = '';
        
        if (policies && policies.length > 0) {
            policies.forEach(policy => {
                const policyDiv = document.createElement('div');
                policyDiv.className = 'policy-item';
                policyDiv.innerHTML = `
                    <div class="policy-header">
                        <h4>${policy.name}</h4>
                        <span class="policy-status ${policy.status.toLowerCase()}">${policy.status}</span>
                    </div>
                    <div class="policy-details">
                        <p><strong>Coverage:</strong> $${policy.coverage.toLocaleString()}</p>
                        <p><strong>Premium:</strong> $${policy.premium}/month</p>
                        <p><strong>Expires:</strong> ${policy.expiryDate}</p>
                    </div>
                    <div class="policy-actions">
                        <button class="action-btn" onclick="renewPolicy(${policy.id})">Renew</button>
                        <button class="action-btn cancel" onclick="cancelPolicy(${policy.id})">Cancel</button>
                    </div>
                `;
                policiesList.appendChild(policyDiv);
            });
        } else {
            policiesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No active insurance policies</p>';
        }
    }

    // Update claims history
    function updateClaimsHistory(claims) {
        const claimsList = document.getElementById('claims-list');
        claimsList.innerHTML = '';
        
        if (claims && claims.length > 0) {
            claims.forEach(claim => {
                const claimDiv = document.createElement('div');
                claimDiv.className = 'claim-item';
                claimDiv.innerHTML = `
                    <div class="claim-header">
                        <h4>Claim #${claim.id}</h4>
                        <span class="claim-status ${claim.status.toLowerCase()}">${claim.status}</span>
                    </div>
                    <div class="claim-details">
                        <p><strong>Type:</strong> ${claim.type}</p>
                        <p><strong>Amount:</strong> $${claim.amount.toLocaleString()}</p>
                        <p><strong>Filed:</strong> ${claim.dateSubmitted}</p>
                        <p><strong>Description:</strong> ${claim.description}</p>
                    </div>
                `;
                claimsList.appendChild(claimDiv);
            });
        } else {
            claimsList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No claims filed</p>';
        }
    }

    // Show notification
    function showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    // Global functions for policy management
    window.renewPolicy = function(policyId) {
        fetch(`https://${GetParentResourceName()}/renewPolicy`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                policyId: policyId
            })
        });
    };

    window.cancelPolicy = function(policyId) {
        if (confirm('Are you sure you want to cancel this policy?')) {
            fetch(`https://${GetParentResourceName()}/cancelPolicy`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    policyId: policyId
                })
            });
        }
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