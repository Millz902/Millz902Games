// Los Scotia Branding Script
document.addEventListener('DOMContentLoaded', function() {
    // Listen for NUI messages
    window.addEventListener('message', function(event) {
        let data = event.data;
        
        if (data.action === 'injectBranding') {
            injectBranding(data.data);
        } else if (data.action === 'openURL') {
            openURL(data.url);
        }
    });
    
    // Function to open URLs (like Discord)
    function openURL(url) {
        // Create an invisible iframe to handle the URL
        const iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.src = url;
        document.body.appendChild(iframe);
        
        // Clean up iframe after a delay
        setTimeout(() => {
            document.body.removeChild(iframe);
        }, 5000);
    }
    
    // Inject branding into QBCore menus
    function injectBranding(data) {
        // Find all QBCore menu containers
        const qbMenus = document.querySelectorAll('.qb-menu-container, .menu-container');
        
        qbMenus.forEach(menu => {
            // Check if we already injected branding
            if (menu.querySelector('.qb-menu-brand')) return;
            
            // Create branding element
            const brandingEl = document.createElement('div');
            brandingEl.className = 'qb-menu-brand animated-branding';
            brandingEl.innerHTML = `<span style="color: ${data.brandColor}">${data.brandName}</span>`;
            
            // Insert at the top of the menu
            menu.insertBefore(brandingEl, menu.firstChild);
        });
        
        // Find all headers and inject branding
        const headers = document.querySelectorAll('.menu-header, .header');
        headers.forEach(header => {
            // Add red Los Scotia styling
            header.classList.add('ls-menu-header');
        });
    }
    
    // Automatically detect and brand QBCore elements when they appear
    const observer = new MutationObserver(mutations => {
        mutations.forEach(mutation => {
            if (mutation.addedNodes && mutation.addedNodes.length > 0) {
                for (let i = 0; i < mutation.addedNodes.length; i++) {
                    const node = mutation.addedNodes[i];
                    // Check if the node is an element
                    if (node.nodeType === 1) {
                        // If it's a QBCore menu or similar element
                        if (node.classList && 
                           (node.classList.contains('qb-menu-container') || 
                            node.classList.contains('menu-container'))) {
                            injectBranding({
                                brandName: 'Los Scotia',
                                brandColor: '#ff0000' // Red in hex format
                            });
                        }
                    }
                }
            }
        });
    });
    
    // Start observing the body for changes
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
});