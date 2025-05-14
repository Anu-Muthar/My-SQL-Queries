
/*************************************************************
 * Title: App Engagement Metrics
 * Description: Collection of SQL queries to analyze user 
 *              activity and content engagement in the app.
 * Author: [Your Name]
 *************************************************************/

------------------------------------------------------------
-- 1. Total number of active users in the app
-- (Approved or subscribed users not in the ignored list)
------------------------------------------------------------
SELECT u.id 
FROM platform_users u 
WHERE u.aasm_state IN ('approved', 'subscribed')
  AND u.id NOT IN (SELECT user_id FROM ignored_users_list);


------------------------------------------------------------
-- 2. Weekly Active Users (WAU)
-- Users who spent more than 1 minute/day in the past 7 days
------------------------------------------------------------
SELECT COUNT(DISTINCT s.user_id) AS wau_count
FROM session_data s
JOIN platform_users u ON s.user_id = u.id
WHERE s.date > CURRENT_DATE - INTERVAL '8 day'
  AND s.date <= CURRENT_DATE - INTERVAL '1 day'
  AND s.duration_screen_view > 60000
  AND u.aasm_state = 'subscribed'
  AND s.user_id NOT IN (SELECT user_id FROM ignored_users_list);


------------------------------------------------------------
-- 3. Number of users who joined a room per day
------------------------------------------------------------
SELECT DATE(p.created_at) AS date, COUNT(p.id) AS join_count
FROM meeting_participants p
WHERE DATE(p.created_at) > CURRENT_DATE - INTERVAL '8 day'
  AND DATE(p.created_at) <= CURRENT_DATE - INTERVAL '1 day'
  AND p.user_id NOT IN (SELECT user_id FROM ignored_users_list)
GROUP BY date
ORDER BY date;


------------------------------------------------------------
-- 4. Number of users who unmuted in a room per day
------------------------------------------------------------
SELECT DATE(p.created_at) AS date, COUNT(p.id) AS unmute_count
FROM meeting_participants p
JOIN participant_mute_statuses m 
  ON p.id = m.participant_id
WHERE DATE(p.created_at) > CURRENT_DATE - INTERVAL '8 day'
  AND DATE(p.created_at) <= CURRENT_DATE - INTERVAL '1 day'
  AND p.user_id NOT IN (SELECT user_id FROM ignored_users_list)
GROUP BY date
ORDER BY date;


------------------------------------------------------------
-- 5. Total number of posts created (past 7 days)
------------------------------------------------------------
SELECT DATE(p.created_at) AS date, COUNT(p.id) AS post_count
FROM content_posts p
WHERE DATE(p.created_at) > CURRENT_DATE - INTERVAL '8 day'
  AND DATE(p.created_at) <= CURRENT_DATE - INTERVAL '1 day'
  AND p.user_id NOT IN (SELECT user_id FROM ignored_users_list)
  AND p.deleted_at IS NULL
GROUP BY date
ORDER BY date ASC;


------------------------------------------------------------
-- 6. Posts that do not have at least 2 comments
-- as of the previous day
------------------------------------------------------------
SELECT p.id, p.created_at
FROM content_posts p
WHERE p.id NOT IN (
    SELECT c.post_id
    FROM content_comments c
    WHERE c.user_id NOT IN (SELECT user_id FROM ignored_users_list)
      AND c.created_at <= CURRENT_DATE - INTERVAL '1 day'
      AND c.deleted_at IS NULL
    GROUP BY c.post_id
    HAVING COUNT(c.post_id) >= 2
)
AND p.created_at <= CURRENT_DATE - INTERVAL '1 day'
AND p.deleted_at IS NULL
ORDER BY p.created_at DESC;


------------------------------------------------------------
-- 7. Posts that do not have at least 5 likes
-- as of the previous day
------------------------------------------------------------
SELECT p.id, p.created_at
FROM content_posts p
WHERE p.id NOT IN (
    SELECT pl.post_id
    FROM content_likes pl
    WHERE pl.user_id NOT IN (SELECT user_id FROM ignored_users_list)
      AND pl.created_at <= CURRENT_DATE - INTERVAL '1 day'
      AND pl.liked = TRUE
    GROUP BY pl.post_id
    HAVING COUNT(pl.post_id) >= 5
)
AND p.created_at <= CURRENT_DATE - INTERVAL '1 day'
AND p.deleted_at IS NULL
ORDER BY p.created_at DESC;
