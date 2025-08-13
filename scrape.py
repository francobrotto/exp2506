import instaloader
import re
import time
import random
import csv
import os
import shutil

# Constants
media_folder = 'img'
csv_file = 'instagram_posts.csv'
shortcode_pattern = re.compile(r"(?:/p/|/reel/|/tv/)([A-Za-z0-9_-]+)/?")

# Ensure media folder exists
os.makedirs(media_folder, exist_ok=True)

# Initialize Instaloader
L = instaloader.Instaloader(
    download_comments=False,
    download_geotags=False,
    save_metadata=False,
    post_metadata_txt_pattern=''
)

# Read CSV into list of dicts
rows = []
with open(csv_file, 'r', encoding='utf-8', newline='') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames  # preserve column order
    for row in reader:
        rows.append(row)

# Process each row if 'media' column is empty
for row in rows:
    link = row['link']
    media = row['media'].strip()

    if media:  # Already filled, skip
        print(f"Skipping (already filled): {link}")
        continue

    # Extract shortcode from link
    match = shortcode_pattern.search(link)
    if not match:
        print(f"Invalid Instagram URL: {link}")
        continue

    shortcode = match.group(1)
    print(f"\nProcessing post: {shortcode}")

    try:
        post = instaloader.Post.from_shortcode(L.context, shortcode)

        username = post.owner_username
        sanitized_username = re.sub(r'\.', '', username)  # remove dots for userPic
        userPic = f"{sanitized_username}.jpg"
        caption = post.caption or ''
        verified = post.owner_profile.is_verified
        post_type = 'image'  # default
        media_files = []

        # Download post to temp folder
        L.download_post(post, target=shortcode)

        # Handle media files (rename, move to /img/)
        i = 0
        for file in os.listdir(shortcode):
            if file.endswith(('.jpg', '.mp4')):
                ext = os.path.splitext(file)[1]
                new_filename = f"{shortcode}_{i}{ext}"
                src = os.path.join(shortcode, file)
                dst = os.path.join(media_folder, new_filename)
                shutil.move(src, dst)
                media_files.append(new_filename)
                i += 1

        # Determine type
        if post.typename == 'GraphSidecar':
            post_type = 'carousel'
        elif post.is_video:
            post_type = 'video'
        else:
            post_type = 'image'

        # Download profile pic if not already present
        profile = post.owner_profile
        userpic_path = os.path.join(media_folder, userPic)
        if not os.path.exists(userpic_path):
            L.download_profilepic(profile)
            for file in os.listdir(profile.username):
                if file.endswith('.jpg'):
                    shutil.move(os.path.join(profile.username, file), userpic_path)
            shutil.rmtree(profile.username, ignore_errors=True)

        # Update CSV row
        row['type'] = post_type
        row['username'] = username
        row['userPic'] = userPic
        row['media'] = ';'.join(media_files)  # list of media files
        row['caption'] = caption.strip()  # preserve line breaks
        row['verified'] = str(verified).upper()  # TRUE/FALSE as string

        # Clean up temp folder
        shutil.rmtree(shortcode, ignore_errors=True)

        # Random human-like delay
        delay = random.uniform(80, 120)
        print(f"Waiting {delay:.2f} seconds before next post...")
        time.sleep(delay)

    except Exception as e:
        print(f"Error processing {link}: {e}")
        continue

# Write back to CSV (overwrite with updated data)
with open(csv_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)

print("\nCSV updated. All posts processed.")
