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

    // Save settings functionality
    document.getElementById('save-settings').addEventListener('click', function() {
        const businessHours = document.getElementById('business-hours').value;
        const taxRate = document.getElementById('tax-rate').value;
        
        fetch(`https://${GetParentResourceName()}/saveSettings`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                businessHours: businessHours,
                taxRate: taxRate
            })
        });
    });

    // Hire employee functionality
    document.getElementById('hire-btn').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/hireEmployee`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Listen for messages from the client
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'show':
                container.classList.remove('hidden');
                if(data.businessData) {
                    updateBusinessInfo(data.businessData);
                }
                break;
                
            case 'hide':
                container.classList.add('hidden');
                break;
                
            case 'updateBusiness':
                if(data.businessData) {
                    updateBusinessInfo(data.businessData);
                }
                break;
                
            case 'updateEmployees':
                if(data.employees) {
                    updateEmployeeList(data.employees);
                }
                break;
                
            case 'updateFinances':
                if(data.finances) {
                    updateFinances(data.finances);
                }
                break;
        }
    });

    // Update business information
    function updateBusinessInfo(businessData) {
        document.getElementById('business-name').textContent = businessData.name || 'Unknown';
        document.getElementById('business-owner').textContent = businessData.owner || 'Unknown';
        document.getElementById('business-type').textContent = businessData.type || 'Unknown';
        
        const statusElement = document.getElementById('business-status');
        statusElement.textContent = businessData.status || 'Closed';
        statusElement.className = businessData.status === 'Open' ? 'status-open' : 'status-closed';
        
        if(businessData.settings) {
            document.getElementById('business-hours').value = businessData.settings.businessHours || '24/7';
            document.getElementById('tax-rate').value = businessData.settings.taxRate || 5;
        }
    }

    // Update employee list
    function updateEmployeeList(employees) {
        const employeeList = document.querySelector('.employee-list');
        employeeList.innerHTML = '';
        
        if(employees && employees.length > 0) {
            employees.forEach(employee => {
                const employeeDiv = document.createElement('div');
                employeeDiv.className = 'employee-item';
                employeeDiv.innerHTML = `
                    <div class="employee-info">
                        <span class="employee-name">${employee.name}</span>
                        <span class="employee-role">${employee.role}</span>
                    </div>
                    <div class="employee-actions">
                        <button class="fire-btn" onclick="fireEmployee(${employee.id})">Fire</button>
                    </div>
                `;
                employeeList.appendChild(employeeDiv);
            });
        } else {
            employeeList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No employees hired</p>';
        }
    }

    // Update finances
    function updateFinances(finances) {
        document.getElementById('daily-revenue').textContent = `$${finances.dailyRevenue || 0}`;
        document.getElementById('monthly-profit').textContent = `$${finances.monthlyProfit || 0}`;
        document.getElementById('total-balance').textContent = `$${finances.totalBalance || 0}`;
    }

    // Global function for firing employees
    window.fireEmployee = function(employeeId) {
        fetch(`https://${GetParentResourceName()}/fireEmployee`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                employeeId: employeeId
            })
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