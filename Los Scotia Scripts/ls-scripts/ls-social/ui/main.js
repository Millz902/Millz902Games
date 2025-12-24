let currentTab = 'feed';
let selectedConversation = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openSocial') {
        document.getElementById('social-container').classList.remove('hidden');
        if (data.socialData) {
            updateSocialData(data.socialData);
        }
    }
    
    if (data.action === 'updateFeed') {
        updateFeed(data.posts);
    }
    
    if (data.action === 'updateMessages') {
        updateMessages(data.messages);
    }
});

function updateSocialData(data) {
    if (data.profile) {
        document.getElementById('profile-name').textContent = data.profile.name || 'Your Name';
        document.getElementById('profile-bio').textContent = data.profile.bio || 'Add a bio...';
        document.getElementById('friends-count').textContent = data.profile.friendsCount || '0';
        document.getElementById('posts-count').textContent = data.profile.postsCount || '0';
    }
    
    if (data.friends) {
        updateFriendsList(data.friends);
    }
}

function updateFeed(posts) {
    const feed = document.getElementById('news-feed');
    feed.innerHTML = '';
    
    posts.forEach(post => {
        const postElement = document.createElement('div');
        postElement.className = 'post';
        postElement.innerHTML = `
            <div class="post-header">
                <div class="user-avatar">👤</div>
                <div class="user-info">
                    <h4>${post.author}</h4>
                    <span class="post-time">${post.timeAgo}</span>
                </div>
            </div>
            <div class="post-content">${post.content}</div>
            <div class="post-actions">
                <button class="like-btn">👍 Like (${post.likes})</button>
                <button class="comment-btn">💬 Comment (${post.comments})</button>
                <button class="share-btn">🔄 Share</button>
            </div>
        `;
        feed.appendChild(postElement);
    });
}

function updateFriendsList(friends) {
    const friendsList = document.getElementById('friends-list');
    friendsList.innerHTML = '';
    
    friends.forEach(friend => {
        const friendElement = document.createElement('div');
        friendElement.className = 'friend-item';
        friendElement.innerHTML = `
            <div class="friend-avatar">👤</div>
            <div class="friend-info">
                <h4>${friend.name}</h4>
                <p>${friend.status}</p>
            </div>
            <div class="friend-actions">
                <button class="message-friend-btn" onclick="openMessage('${friend.id}')">Message</button>
            </div>
        `;
        friendsList.appendChild(friendElement);
    });
}

function switchTab(tabName) {
    // Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Remove active class from all tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Show selected tab content
    document.getElementById(tabName + '-tab').classList.add('active');
    
    // Add active class to selected tab button
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
    
    currentTab = tabName;
}

function openMessage(friendId) {
    switchTab('messages');
    selectedConversation = friendId;
    // Load conversation messages
}

// Tab switching
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        const tab = this.dataset.tab;
        switchTab(tab);
    });
});

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeSocial`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('social-container').classList.add('hidden');
});

document.getElementById('post-btn').addEventListener('click', function() {
    const postText = document.getElementById('post-text').value.trim();
    if (postText) {
        fetch(`https://${GetParentResourceName()}/createPost`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ content: postText })
        });
        document.getElementById('post-text').value = '';
    }
});

document.getElementById('edit-profile-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/editProfile`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('search-btn').addEventListener('click', function() {
    const searchQuery = document.getElementById('friend-search').value.trim();
    if (searchQuery) {
        fetch(`https://${GetParentResourceName()}/searchFriends`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query: searchQuery })
        });
    }
});

document.getElementById('send-message-btn').addEventListener('click', function() {
    const messageText = document.getElementById('message-text').value.trim();
    if (messageText && selectedConversation) {
        fetch(`https://${GetParentResourceName()}/sendMessage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                recipient: selectedConversation,
                message: messageText 
            })
        });
        document.getElementById('message-text').value = '';
    }
});

// Enter key support for posting and messaging
document.getElementById('post-text').addEventListener('keydown', function(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        document.getElementById('post-btn').click();
    }
});

document.getElementById('message-text').addEventListener('keydown', function(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        document.getElementById('send-message-btn').click();
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeSocial`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('social-container').classList.add('hidden');
    }
});