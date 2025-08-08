function renderPosts(container, posts) {    
    posts.forEach((post, idx) => {
        const postElement = document.createElement('div');
        postElement.classList.add('post');
        postElement.id = `post-${post.index}`;    // Unique ID per post
        
        let headerHTML = `
        <div class="post-header">
        <img src="${post.userPic}" alt="User Pic" class="user-pic">
        <span class="username">${post.username}</span>
        ${post.verified ? `<span class="verified-icon" id="check-${idx}"></span>` : ''}
        </div>
        `;
        
        let mediaHTML = '';
        if (post.type === 'image') {
            mediaHTML = `<img src="${post.media[0]}" class="post-img">`;
        } 
        else if (post.type === 'carousel') {
            mediaHTML = `<div class="carousel" data-idx="${idx}">
            ${post.media.map((src, i) => {
            if (/\.(mp4|webm|ogg)$/i.test(src)) {
                return `
                    <video class="${i === 0 ? 'active' : ''}" muted autoplay loop playsinline>
                    <source src="${src}">Your browser does not support the video tag.
                    </video>
                `;
            } else {
                return `<img src="${src}" class="${i === 0 ? 'active' : ''}">`;
            } }).join('')}
            <button class="prev">&#10094;</button>
        <button class="next">&#10095;</button>
    </div>
    `;
        }
        else if (post.type === 'video') {
            mediaHTML = `
          <div class="video-wrapper">
          <video muted autoplay loop playsinline>
          <source src="${post.media}" type="video/mp4">Your browser does not support the video tag.
          </video>
          <button class="mute-btn" aria-label="Toggle audio">
          <svg aria-label="Audio is muted" fill="white" height="20" viewBox="0 0 48 48" width="20">
          <path d="M16 32h-8V16h8l12-12v40zM41.4 6.6l-4.8 4.8C39.7 14.8 42 19.2 42 24c0 4.8-2.3 9.2-5.4 12.6l4.8 4.8c4.1-4.6 6.6-10.7 6.6-17.4s-2.5-12.8-6.6-17.4zM32 24c0-2.1-.7-4-2-5.6l-3 3c.7.9 1 2 1 3.2s-.4 2.3-1 3.2l3 3c1.3-1.6 2-3.5 2-5.8zM28 4v3.1c7.1 1.4 12 7.6 12 15.2s-4.9 13.8-12 15.2V44c10-1.4 18-9.7 18-20S38 5.4 28 4z"></path>
          </svg>
          </button>
          </div>
          `;
        }
        
        const actionsHTML = `<div class="post-actions">
          <div class="left-actions">
          <button class="action-btn">
          <svg aria-label="Like" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M16.8 3.9A5 5 0 0 1 21.5 9.1c0 3.1-2.7 5-5.2 7.2-2.5 2.2-3.9 3.5-4.3 3.8-.5-.3-2.1-1.8-4.3-3.8C5.1 14.1 2.5 12.2 2.5 9.1A5 5 0 0 1 7.2 3.9c1.4 0 2.7.7 3.7 1.9 1 1.2 1.1 1.8 1.1 1.8s.1-.6 1.1-1.8a4.2 4.2 0 0 1 3.7-1.9Z"/>
          </svg>
          </button>
          <button class="action-btn">
          <svg aria-label="Comment" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M20.656 17.008a9.993 9.993 0 1 0-3.59 3.615L22 22Z"/>
          </svg>
          </button>
          <button class="action-btn">
          <svg aria-label="Share" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M22 3 9.2 10.1"/>
          <polygon points="11.7 20.3 22 3 2 3 9.2 10.1 11.7 20.3"/>
          </svg>
          </button>
          </div>
          <div class="right-actions">
          <button class="action-btn">
          <svg aria-label="Save" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <polygon points="20 21 12 13.4 4 21 4 3 20 3 20 21"/>
          </svg>
          </button>
          </div>
          </div>
          `;
        
        const captionHTML = `
          <div class="post-caption">
          <p><span class="username">${post.username}</span> ${post.caption.replace(/\n/g, '<br>')}</p>
          </div>
          `;
        
        postElement.innerHTML = headerHTML + mediaHTML + actionsHTML + captionHTML;
        container.appendChild(postElement);
    });
    
    // Insert blue IG checkmark where needed
    const checkmarkSVG = `
        <svg aria-label="Verified" fill="#0095f6" height="14" viewBox="0 0 40 40" width="14">
        <path d="M19.998 3.094 14.638 0l-2.972 5.15H5.432v6.354L0 14.64 3.094 20 0 25.359l5.432 3.137v5.905h5.975L14.638 40l5.36-3.094L25.358 40l3.232-5.6h6.162v-6.01L40 25.359 36.905 20 40 14.641l-5.248-3.03v-6.46h-6.419L25.358 0l-5.36 3.094Zm7.415 11.225 2.254 2.287-11.43 11.5-6.835-6.93 2.244-2.258 4.587 4.581 9.18-9.18Z"></path>
        </svg>`;
    document.querySelectorAll('.verified-icon').forEach(el => el.innerHTML = checkmarkSVG);
    
    // Attach mute/unmute functionality to all videos
    document.querySelectorAll('.video-wrapper').forEach(wrapper => {
        const video = wrapper.querySelector('video');
        const btn = wrapper.querySelector('.mute-btn');
        
        const mutedIcon = `
          <svg aria-label="Audio is muted" fill="white" height="20" viewBox="0 0 48 48" width="20">
          <path clip-rule="evenodd" d="M1.5 13.3c-.8 0-1.5.7-1.5 1.5v18.4c0 .8.7 1.5 1.5 1.5h8.7l12.9 12.9c.9.9 2.5.3 2.5-1v-9.8c0-.4-.2-.8-.4-1.1l-22-22c-.3-.3-.7-.4-1.1-.4h-.6zm46.8 31.4-5.5-5.5C44.9 36.6 48 31.4 48 24c0-11.4-7.2-17.4-7.2-17.4-.6-.6-1.6-.6-2.2 0L37.2 8c-.6.6-.6 1.6 0 2.2 0 0 5.7 5 5.7 13.8 0 5.4-2.1 9.3-3.8 11.6L35.5 32c1.1-1.7 2.3-4.4 2.3-8 0-6.8-4.1-10.3-4.1-10.3-.6-.6-1.6-.6-2.2 0l-1.4 1.4c-.6.6-.6 1.6 0 2.2 0 0 2.6 2 2.6 6.7 0 1.8-.4 3.2-.9 4.3L25.5 22V1.4c0-1.3-1.6-1.9-2.5-1L13.5 10 3.3-.3c-.6-.6-1.5-.6-2.1 0L-.2 1.1c-.6.6-.6 1.5 0 2.1L4 7.6l26.8 26.8 13.9 13.9c.6.6 1.5.6 2.1 0l1.4-1.4c.7-.6.7-1.6.1-2.2z" fill-rule="evenodd"></path>
          </svg>`;
        
        const playingIcon = `
          <svg aria-label="Audio is playing" fill="white" height="20" viewBox="0 0 24 24" width="20">
          <path d="M16.636 7.028a1.5 1.5 0 1 0-2.395 1.807 5.365 5.365 0 0 1 1.103 3.17 5.378 5.378 0 0 1-1.105 3.176 1.5 1.5 0 1 0 2.395 1.806 8.396 8.396 0 0 0 1.71-4.981 8.39 8.39 0 0 0-1.708-4.978Zm3.73-2.332A1.5 1.5 0 1 0 18.04 6.59 8.823 8.823 0 0 1 20 12.007a8.798 8.798 0 0 1-1.96 5.415 1.5 1.5 0 0 0 2.326 1.894 11.672 11.672 0 0 0 2.635-7.31 11.682 11.682 0 0 0-2.635-7.31Zm-8.963-3.613a1.001 1.001 0 0 0-1.082.187L5.265 6H2a1 1 0 0 0-1 1v10.003a1 1 0 0 0 1 1h3.265l5.01 4.682.02.021a1 1 0 0 0 1.704-.814L12.005 2a1 1 0 0 0-.602-.917Z"></path>
          </svg>`;
        
        // Initialize with muted icon
        btn.innerHTML = mutedIcon;
        
        btn.addEventListener('click', () => {
            video.muted = !video.muted;
            btn.innerHTML = video.muted ? mutedIcon : playingIcon;
        });
    });                                  
    
    // Carousel functionality
    document.querySelectorAll('.carousel').forEach(carousel => {
        const mediaItems = carousel.querySelectorAll('img, video'); // Include both images and videos
        let current = 0;
        
        const showMedia = (index) => {
            mediaItems.forEach((el, i) => {
                const isActive = i === index;
                el.classList.toggle('active', isActive);
                
                // Pause videos that are not active
                if (el.tagName === 'VIDEO') {
                    if (isActive) {
                        el.play().catch(() => {}); // avoid autoplay errors
                    } else {
                        el.pause();
                    }
                }
            });
        };
        
        carousel.querySelector('.prev').addEventListener('click', () => {
            current = (current - 1 + mediaItems.length) % mediaItems.length;
            showMedia(current);
        });
        
        carousel.querySelector('.next').addEventListener('click', () => {
            current = (current + 1) % mediaItems.length;
            showMedia(current);
        });
        
        showMedia(current); // Initialize
    });
}