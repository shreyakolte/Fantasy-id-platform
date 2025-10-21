-- Create database 
CREATE DATABASE fantasyid;
USE fantasyid;

-- Table: sports (stores list of sports)
CREATE TABLE sports ( 
  sport_id INT AUTO_INCREMENT PRIMARY KEY,    -- unique ID for each sport
  name VARCHAR(64) NOT NULL UNIQUE            -- sport name (Basketball, Football, etc.)
);

-- Table: leagues (stores leagues for each sport)
CREATE TABLE leagues (
  league_id INT AUTO_INCREMENT PRIMARY KEY,   -- unique ID for each league
  sport_id INT NOT NULL,                      -- references sports.sport_id
  name VARCHAR(128) NOT NULL,                 -- league name (NBA, NFL, etc.)
  country VARCHAR(64),                        -- country of the league
  provider_league_id VARCHAR(128),            -- optional: ID from external API
  UNIQUE KEY uniq_league (sport_id, name),
  FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

-- Table: seasons (stores seasons for each league)
CREATE TABLE seasons (
  season_id INT AUTO_INCREMENT PRIMARY KEY,   -- unique ID for each season
  league_id INT NOT NULL,                     -- references leagues.league_id
  year VARCHAR(16) NOT NULL,                  -- e.g. '2024-25'
  UNIQUE KEY uniq_season (league_id, year),
  FOREIGN KEY (league_id) REFERENCES leagues(league_id)
);

-- Table: teams (stores teams for each league)
CREATE TABLE teams (
  team_id INT AUTO_INCREMENT PRIMARY KEY,     -- unique ID for each team
  league_id INT NOT NULL,                     -- references leagues.league_id
  name VARCHAR(128) NOT NULL,                 -- team name
  short_name VARCHAR(64),                     -- short code (LAL, KC, etc.)
  city VARCHAR(128),                          -- team city
  provider_team_id VARCHAR(128),              -- optional: ID from external API
  UNIQUE KEY uniq_team (league_id, name),
  FOREIGN KEY (league_id) REFERENCES leagues(league_id)
);

-- Table: games (stores matchups)
CREATE TABLE games (
  game_id INT AUTO_INCREMENT PRIMARY KEY,     -- unique ID for each game
  season_id INT NOT NULL,                     -- references seasons.season_id
  league_id INT NOT NULL,                     -- references leagues.league_id
  home_team_id INT NOT NULL,                  -- references teams.team_id
  away_team_id INT NOT NULL,                  -- references teams.team_id
  start_time DATETIME NOT NULL,               -- scheduled start time
  venue VARCHAR(128),                         -- stadium or arena
  status VARCHAR(20) DEFAULT 'scheduled',     -- scheduled, live, final
  provider_game_id VARCHAR(128),              -- optional: ID from external API
  FOREIGN KEY (season_id) REFERENCES seasons(season_id),
  FOREIGN KEY (league_id) REFERENCES leagues(league_id),
  FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
  FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);

-- Table: score_updates (stores live and final scores for each game)
CREATE TABLE score_updates (
  score_update_id INT AUTO_INCREMENT PRIMARY KEY,  -- unique ID for each update
  game_id INT NOT NULL,                            -- references games.game_id
  update_time DATETIME NOT NULL,                   -- when the score was recorded
  period VARCHAR(16),                              -- Q1, Q2, etc.
  home_score INT NOT NULL,                         -- home team score
  away_score INT NOT NULL,                         -- away team score
  is_final TINYINT(1) DEFAULT 0,                   -- 1 if final score
  FOREIGN KEY (game_id) REFERENCES games(game_id)
);

-- Table: standings (stores wins/losses for teams per season)
CREATE TABLE standings (
  standing_id INT AUTO_INCREMENT PRIMARY KEY,   -- unique ID for each row
  season_id INT NOT NULL,                       -- references seasons.season_id
  team_id INT NOT NULL,                         -- references teams.team_id
  wins INT DEFAULT 0,                           -- number of wins
  losses INT DEFAULT 0,                         -- number of losses
  draws INT DEFAULT 0,                          -- number of draws/ties
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_standing (season_id, team_id),
  FOREIGN KEY (season_id) REFERENCES seasons(season_id),
  FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- Table: users (stores user accounts)
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,       -- unique ID for each user
  email VARCHAR(128) NOT NULL UNIQUE,           -- email address
  username VARCHAR(64) NOT NULL UNIQUE,         -- username
  password_hash VARCHAR(256) NOT NULL,          -- hashed password
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: payments (stores payment records)
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,    -- unique ID for each payment
  user_id INT NOT NULL,                         -- references users.user_id
  amount DECIMAL(10,2) NOT NULL,                -- amount paid
  currency VARCHAR(8) DEFAULT 'USD',            -- currency code
  status VARCHAR(20) DEFAULT 'pending',         -- payment status
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SHOW TABLES;
DELETE FROM sports WHERE name = 'Basketball';

-- For Handball
INSERT INTO sports (name) VALUES ('Handball');

-- For Baseball
INSERT INTO sports (name) VALUES ('Baseball');

-- for american football
INSERT INTO sports (name) VALUES ('American Football');

SELECT * FROM sports;

-- Players in any league/team
CREATE TABLE players (
  player_id INT AUTO_INCREMENT PRIMARY KEY,
  league_id INT NOT NULL,
  team_id INT NOT NULL,
  name VARCHAR(128) NOT NULL,
  position VARCHAR(32),
  provider_player_id VARCHAR(128),
  FOREIGN KEY (league_id) REFERENCES leagues(league_id),
  FOREIGN KEY (team_id)   REFERENCES teams(team_id),
  UNIQUE KEY uniq_player_provider (provider_player_id)
);

-- Stats per player per game (keep it generic with JSON)
CREATE TABLE player_stats (
  player_stat_id INT AUTO_INCREMENT PRIMARY KEY,
  game_id INT NOT NULL,
  player_id INT NOT NULL,
  -- store API payload (works for any sport)
  stats_json JSON,
  -- optional common fields you can sort by (nullable, use what applies per sport)
  points INT NULL,        -- basketball/handball
  yards INT NULL,         -- football/baseball (generic “yards”)
  touchdowns INT NULL,
  assists INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (game_id) REFERENCES games(game_id),
  FOREIGN KEY (player_id) REFERENCES players(player_id),
  UNIQUE KEY uniq_player_game (player_id, game_id)
);

CREATE TABLE notifications (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(160) NOT NULL,
  body VARCHAR(500),
  type VARCHAR(32),                  -- live | upcoming | final | league_update | payment | etc.
  is_read TINYINT(1) DEFAULT 0,
  related_game_id INT NULL,          -- optional deep link
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (related_game_id) REFERENCES games(game_id)
);

CREATE TABLE user_follows (
  follow_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  team_id INT NULL,
  player_id INT NULL,
  league_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Exactly one target type must be chosen
  CHECK (
    (team_id IS NOT NULL) + (player_id IS NOT NULL) + (league_id IS NOT NULL) = 1
  ),

  FOREIGN KEY (user_id)  REFERENCES users(user_id),
  FOREIGN KEY (team_id)  REFERENCES teams(team_id),
  FOREIGN KEY (player_id) REFERENCES players(player_id),
  FOREIGN KEY (league_id) REFERENCES leagues(league_id),

  -- Prevent duplicates per user/target
  UNIQUE KEY uniq_user_team   (user_id, team_id),
  UNIQUE KEY uniq_user_player (user_id, player_id),
  UNIQUE KEY uniq_user_league (user_id, league_id)
);

CREATE TABLE wallets (
  user_id INT PRIMARY KEY,
  balance DECIMAL(12,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE wallet_transactions (
  tx_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,     -- + credit, - debit
  tx_type VARCHAR(32),               -- deposit | withdraw | prize | fee | refund
  reference VARCHAR(128),            -- payment_id or game_id etc.
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  INDEX idx_wallet_user_time (user_id, created_at)
);

-- Sports list (for filter)
SELECT sport_id, name FROM sports ORDER BY name;

-- Leagues for a sport
SELECT league_id, name FROM leagues WHERE sport_id = ? ORDER BY name;

-- Seasons for a league
SELECT season_id, year FROM seasons WHERE league_id = ? ORDER BY year DESC;

show tables;