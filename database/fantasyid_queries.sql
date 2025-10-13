
-- ========================= DASHBOARD ===============================

-- Current matchups (today/this week)
SELECT g.game_id, g.start_time, g.status,
       ht.name AS home_team, at.name AS away_team
FROM games g
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
WHERE g.league_id = ?            -- :league_id
  AND g.season_id = ?            -- :season_id
  AND g.start_time BETWEEN ? AND ?  -- :from_utc, :to_utc
ORDER BY g.start_time
LIMIT ? OFFSET ?;

-- Quick standings snapshot
SELECT t.name AS team, st.wins, st.losses,
       (st.wins / NULLIF(st.wins + st.losses + st.draws, 0)) AS win_pct
FROM standings st
JOIN teams t ON t.team_id = st.team_id
WHERE st.season_id = ?           -- :season_id
ORDER BY st.wins DESC, st.losses ASC, t.name;

-- ============================== Live Scores ==================================

-- Live games + latest score (single query)
SELECT g.game_id, g.start_time,
       ht.name AS home_team, at.name AS away_team,
       s.home_score, s.away_score, s.period, s.update_time, s.is_final
FROM games g
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
LEFT JOIN (
  SELECT su.game_id, su.home_score, su.away_score, su.period, su.update_time, su.is_final
  FROM score_updates su
  JOIN (
    SELECT game_id, MAX(update_time) AS max_time
    FROM score_updates
    GROUP BY game_id
  ) m ON m.game_id = su.game_id AND m.max_time = su.update_time
) s ON s.game_id = g.game_id
WHERE g.league_id = ?
  AND g.season_id = ?
  AND g.status = 'live'
ORDER BY g.start_time
LIMIT ? OFFSET ?;

-- =========================== LEAGUE PAGE ===================================

-- Standings tab
SELECT t.name AS team, st.wins, st.losses, st.draws
FROM standings st
JOIN teams t ON t.team_id = st.team_id
WHERE st.season_id = ?
ORDER BY st.wins DESC, st.losses ASC, t.name;

-- Upcoming matchups (next 7 days)
SELECT g.game_id, g.start_time, g.venue, g.status,
       ht.name AS home_team, at.name AS away_team
FROM games g
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
WHERE g.league_id = ?
  AND g.season_id = ?
  AND g.status = 'scheduled'
  AND g.start_time BETWEEN ? AND ?
ORDER BY g.start_time
LIMIT ? OFFSET ?;

-- Recent results (last N days)
SELECT g.game_id, g.start_time,
       ht.name AS home_team, at.name AS away_team
FROM games g
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
WHERE g.league_id = ?
  AND g.season_id = ?
  AND g.status = 'final'
  AND g.start_time >= ?
ORDER BY g.start_time DESC
LIMIT ? OFFSET ?;

-- ======================== GAME DETAILS ========================

-- Header
SELECT g.game_id, g.start_time, g.venue, g.status,
       l.name AS league,
       ht.name AS home_team, at.name AS away_team
FROM games g
JOIN leagues l ON l.league_id = g.league_id
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
WHERE g.game_id = ?;

-- Score timeline
SELECT period, home_score, away_score, update_time, is_final
FROM score_updates
WHERE game_id = ?
ORDER BY update_time;

-- =========================== SEARCH ==========================

-- Search teams (by name/city/code)
SELECT team_id, name, short_name, city
FROM teams
WHERE league_id = ?
  AND (
    name LIKE CONCAT('%', ?, '%')
    OR short_name LIKE CONCAT('%', ?, '%')
    OR city LIKE CONCAT('%', ?, '%')
  )
ORDER BY name
LIMIT ? OFFSET ?;

-- Search games by team name within a window
SELECT g.game_id, g.start_time, g.status,
       ht.name AS home_team, at.name AS away_team
FROM games g
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
WHERE g.league_id = ?
  AND g.season_id = ?
  AND g.start_time BETWEEN ? AND ?
  AND (
    ht.name LIKE CONCAT('%', ?, '%')
    OR at.name LIKE CONCAT('%', ?, '%')
  )
ORDER BY g.start_time
LIMIT ? OFFSET ?;

-- ====================== ADMIN ================================

-- Recent users
SELECT user_id, email, username, created_at
FROM users
ORDER BY created_at DESC
LIMIT ? OFFSET ?;

-- Payments list (with user email)
SELECT p.payment_id, u.email, p.amount, p.currency, p.status, p.created_at
FROM payments p
JOIN users u ON u.user_id = p.user_id
ORDER BY p.created_at DESC
LIMIT ? OFFSET ?;

-- Payments summary
SELECT status, COUNT(*) AS count_tx, SUM(amount) AS total_amount
FROM payments
GROUP BY status;
