// ls-radio UI Script
console.log('ls-radio UI loaded');

window.addEventListener('message', function(event) {
    // Handle NUI messages
    console.log('Message received:', event.data);
});
