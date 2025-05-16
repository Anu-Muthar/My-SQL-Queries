WITH post_engagement_report AS (
  SELECT 
    p.id AS post_id,
    p.content AS post_content,
    p.created_at AS post_created_time,

    -- Total counts
    COUNT(DISTINCT pl.id) AS total_post_likes,
    COUNT(DISTINCT cm.id) AS total_comments,
    COUNT(DISTINCT cl.id) AS total_comment_likes,
    COUNT(DISTINCT rp.id) AS total_replies,
    COUNT(DISTINCT rl.id) AS total_reply_likes,

    -- Daily activity counts
    COUNT(DISTINCT CASE WHEN DATE(pl.created_at) = CURRENT_DATE THEN pl.id END) AS daily_post_likes,
    COUNT(DISTINCT CASE WHEN DATE(cm.created_at) = CURRENT_DATE THEN cm.id END) AS daily_comments,
    COUNT(DISTINCT CASE WHEN DATE(cl.created_at) = CURRENT_DATE THEN cl.id END) AS daily_comment_likes,
    COUNT(DISTINCT CASE WHEN DATE(rp.created_at) = CURRENT_DATE THEN rp.id END) AS daily_replies,
    COUNT(DISTINCT CASE WHEN DATE(rl.created_at) = CURRENT_DATE THEN rl.id END) AS daily_reply_likes,

    -- Weekly activity counts (last 7 days)
    COUNT(DISTINCT CASE WHEN DATE(pl.created_at) > CURRENT_DATE - INTERVAL '7 days' THEN pl.id END) AS weekly_post_likes,
    COUNT(DISTINCT CASE WHEN DATE(cm.created_at) > CURRENT_DATE - INTERVAL '7 days' THEN cm.id END) AS weekly_comments,
    COUNT(DISTINCT CASE WHEN DATE(cl.created_at) > CURRENT_DATE - INTERVAL '7 days' THEN cl.id END) AS weekly_comment_likes,
    COUNT(DISTINCT CASE WHEN DATE(rp.created_at) > CURRENT_DATE - INTERVAL '7 days' THEN rp.id END) AS weekly_replies,
    COUNT(DISTINCT CASE WHEN DATE(rl.created_at) > CURRENT_DATE - INTERVAL '7 days' THEN rl.id END) AS weekly_reply_likes

  FROM app_posts p
  LEFT JOIN app_post_likes pl ON pl.post_id = p.id AND pl.liked = TRUE
  LEFT JOIN app_comments cm ON cm.post_id = p.id
  LEFT JOIN app_comment_likes cl ON cl.comment_id = cm.id
  LEFT JOIN app_replies rp ON rp.comment_id = cm.id
  LEFT JOIN app_reply_likes rl ON rl.reply_id = rp.id
  GROUP BY p.id, p.created_at, p.content
)

-- Final output with engagement metrics
SELECT 
  post_id,
  post_content,
  post_created_time,

  -- Daily aggregates
  (daily_comments + daily_replies) AS daily_total_comments,
  (daily_post_likes + daily_comment_likes + daily_reply_likes) AS daily_total_likes,
  (daily_comments + daily_replies + daily_post_likes + daily_comment_likes + daily_reply_likes) AS daily_engagement_total,

  -- Weekly aggregates
  (weekly_comments + weekly_replies) AS weekly_total_comments,
  (weekly_post_likes + weekly_comment_likes + weekly_reply_likes) AS weekly_total_likes,
  (weekly_comments + weekly_replies + weekly_post_likes + weekly_comment_likes + weekly_reply_likes) AS weekly_engagement_total,

  -- Cumulative aggregates
  (total_comments + total_replies) AS cumulative_total_comments,
  (total_post_likes + total_comment_likes + total_reply_likes) AS cumulative_total_likes,
  (total_comments + total_replies + total_post_likes + total_comment_likes + total_reply_likes) AS cumulative_engagement_total

FROM post_engagement_report
ORDER BY post_created_time;
