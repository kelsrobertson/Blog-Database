
CREATE DATABASE my_blog_db;
USE my_blog_db;

CREATE TABLE UserAuthentication (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR (100)
);

CREATE TABLE Sessions (
    session_id VARCHAR(255) PRIMARY KEY, 
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES UserAuthentication(user_id) ON DELETE CASCADE, 
    INDEX (user_id),
    INDEX (session_token)
);

CREATE TABLE UserActions (
    action_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL,
    action_description VARCHAR(255) NOT NULL,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES UserAuthentication(user_id)
);

CREATE TABLE BlogPosts (
    post_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    FULLTEXT(title, content),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  	INDEX (created_at),
    FOREIGN KEY (user_id) REFERENCES UserAuthentication(user_id)
);

CREATE TABLE Comments (
	comment_id INT AUTO_INCREMENT PRIMARY KEY, 
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES BlogPosts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES UserAuthentication(user_id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);


INSERT INTO UserAuthentication (user_id, username, password_hash, email) VALUES
(1, 'princessnala', 'Ilovetreats2022!', 'nala.princess@gmail.com'),
(2, 'frozentrixy', 'Helloworld!', 'frozentrixy@gmail.com'),
(3, 'BrewThru', 'Supdudes', 'drinkup@gmail.com');


INSERT INTO Sessions (session_id, user_id, session_token, created_at) VALUES
('sess_12345', 1, 'token_abc123', '2024-11-04 10:15:00'),
('sess_67890', 2, 'token_def456', '2024-11-04 10:30:00'),
('sess_11223', 3, 'token_ghi789', '2024-11-04 11:00:00');


INSERT INTO UserActions (user_id, action_description) VALUES
(1, 'Logged in'),
(2, 'Logged in'),
(3, 'Created a new post'),
(1, 'Commented on a post');


INSERT INTO BlogPosts (post_id, user_id, title, content, created_at) VALUES
(5, 1, 'The Majestic Life of Tigers', 'Tigers are among the most magnificent creatures on Earth. This post explores their habitat, hunting habits, and conservation efforts...', '2024-11-04 08:00:00'),
(6, 2, 'A Guide to Caring for Your Pet Dog', 'Owning a dog can be a rewarding experience. Here are some tips on how to care for your furry friend, from diet to exercise...', '2024-11-04 09:00:00'),
(7, 3, 'Bird Watching for Beginners', 'Bird watching is a wonderful way to connect with nature. In this post, we share tips for beginners on how to get started with bird watching...', '2024-11-04 10:00:00'),
(8, 1, 'The Secret Lives of Dolphins', 'Dolphins are intelligent and social creatures. Learn more about their communication methods, social structures, and playful behaviors...', '2024-11-04 11:00:00'),
(9, 2, 'Top 5 Tips for Building a Fish Tank', 'Building a fish tank can be a fun project. Here’s a guide to setting up an aquarium and creating a healthy environment for your fish...', '2024-11-04 12:00:00'),
(10, 3, 'Understanding Cat Behavior', 'Cats have unique behaviors that often puzzle their owners. This post explains common cat behaviors and what they mean...', '2024-11-04 01:00:00');


INSERT INTO Comments (comment_id, post_id, user_id, content, created_at) VALUES
(6, 5, 2, 'I love tigers! It\'s heartbreaking to see them endangered. Thanks for raising awareness.', '2024-11-04 08:30:00'),
(7, 5, 3, 'Such a majestic animal! I hope conservation efforts succeed.', '2024-11-04 09:00:00'),
(8, 6, 1, 'Great tips! I just adopted a puppy, so this is very helpful.', '2024-11-04 09:15:00'),
(9, 6, 3, 'Thank you! My dog has been picky with food, so I\'ll try your diet suggestions.', '2024-11-04 09:45:00'),
(10, 7, 2, 'Bird watching sounds fun! I\'m planning to try it this weekend.', '2024-11-04 10:30:00'),
(11, 7, 1, 'Any recommendations on binoculars for beginners?', '2024-11-04 11:00:00'),
(12, 8, 2, 'Dolphins are amazing creatures! I never knew they had such complex social structures.', '2024-11-04 11:30:00'),
(13, 8, 3, 'This was a fascinating read. Dolphins are so intelligent!', '2024-11-04 11:45:00'),
(14, 9, 1, 'Setting up my first fish tank soon! This guide is just what I needed.', '2024-11-04 12:30:00'),
(15, 9, 2, 'Thanks for the tips! Can you recommend any low-maintenance fish?', '2024-11-04 12:45:00'),
(16, 10, 3, 'My cat does that too! I always wondered why.', '2024-11-04 01:15:00'),
(17, 10, 1, 'Great insights! This helped me understand my cat\'s behavior better.', '2024-11-04 01:30:00');



# Query for retrieving user actions by time 
SELECT * 
FROM UserActions 
WHERE action_timestamp BETWEEN '2024-01-01 00:00:00' AND '2024-01-31 23:59:59'
ORDER BY action_timestamp DESC;

# Query for retrieving posts by creation date
SELECT * 
FROM UserActions 
WHERE action_timestamp BETWEEN '2024-01-01 00:00:00' AND '2024-01-31 23:59:59'
ORDER BY action_timestamp DESC;

# Query for full-text search in posts
SELECT * 
FROM BlogPosts 
WHERE MATCH(title, content) AGAINST('keyword1 keyword2' IN BOOLEAN MODE);

# Query for getting recent comments
SELECT * 
FROM Comments 
ORDER BY created_at DESC 
LIMIT 10;  -- Adjust the limit as needed




