

#  FantasyID Database File (`fantasyid_schema.sql`)

This database stores all the data needed for the **FantasyID Sports Platform**.  
It is built in **MySQL** and designed to support multiple sports, leagues, seasons, teams, games, live scores, standings, user accounts, payments, player data, notifications, and user preferences.

---

## **Overview**

The database contains **13 main tables:**

| Table | Purpose |
|--------|----------|
| `sports` | List of sports supported (e.g. Baseball, American Football). |
| `leagues` | Leagues for each sport (e.g. MLB for Baseball, NFL for American Football). |
| `seasons` | Seasons/years of each league (e.g. 2024–25 MLB season). |
| `teams` | Teams that participate in a league. |
| `games` | Individual matchups/fixtures between teams. |
| `score_updates` | Live and final score snapshots for each game. |
| `standings` | Wins/losses/draws per team per season (drives standings and quick stats). |
| `players` | Player details linked to leagues and teams. |
| `player_stats` | Per-game performance data for each player. |
| `notifications` | Stores live/upcoming/final game alerts for users. |
| `user_follows` | Tracks users’ followed teams, players, or leagues. |
| `users` | User accounts for login and signup. |
| `payments` | Payment/subscription records linked to users. |

---

## **Table Details**

### 1. `sports`
- Stores each sport the app supports.  
- **Key columns:** `sport_id`, `name`.

### 2. `leagues`
- Stores leagues under each sport.  
- Linked to `sports` via `sport_id`.  
- **Key columns:** `league_id`, `sport_id`, `name`, `country`.

### 3. `seasons`
- Stores seasons/years for each league.  
- Linked to `leagues` via `league_id`.  
- **Key columns:** `season_id`, `league_id`, `year`.

### 4. `teams`
- Stores teams in a league.  
- Linked to `leagues` via `league_id`.  
- **Key columns:** `team_id`, `league_id`, `name`, `short_name`, `city`.

### 5. `games`
- Stores matchups between teams.  
- Linked to `seasons`, `leagues`, and both home/away `teams`.  
- **Key columns:** `game_id`, `season_id`, `league_id`, `home_team_id`, `away_team_id`, `start_time`, `venue`, `status`.

### 6. `score_updates`
- Stores score snapshots (live/final) for each game.  
- Linked to `games` via `game_id`.  
- **Key columns:** `score_update_id`, `game_id`, `update_time`, `period`, `home_score`, `away_score`, `is_final`.

### 7. `standings`
- Stores team performance per season.  
- Linked to `seasons` and `teams`.  
- **Key columns:** `standing_id`, `season_id`, `team_id`, `wins`, `losses`, `draws`.

### 8. `players`
- Stores player details for each team and league.  
- Linked to `leagues` and `teams`.  
- **Key columns:** `player_id`, `league_id`, `team_id`, `name`, `position`.

### 9. `player_stats`
- Stores player performance metrics for each game.  
- Linked to `players` and `games`.  
- **Key columns:** `player_stat_id`, `game_id`, `player_id`, `stats_json`, `points`, `yards`, `touchdowns`, `assists`.

### 10. `notifications`
- Stores alerts for users (live, upcoming, or final game updates).  
- Linked to `users` and optionally `games`.  
- **Key columns:** `notification_id`, `user_id`, `title`, `body`, `type`, `is_read`, `related_game_id`.

### 11. `user_follows`
- Tracks teams, players, or leagues followed by users.  
- Linked to `users`, `teams`, `players`, and `leagues`.  
- **Key columns:** `follow_id`, `user_id`, `team_id`, `player_id`, `league_id`, `created_at`.

### 12. `users`
- Stores user accounts.  
- **Key columns:** `user_id`, `email`, `username`, `password_hash`, `created_at`.

### 13. `payments`
- Stores payment and subscription records.  
- Linked to `users` via `user_id`.  
- **Key columns:** `payment_id`, `user_id`, `amount`, `currency`, `status`.

---

## **Relationships Diagram (Text)**




## Relationships Diagram (text)

 SPORTS └──< LEAGUES └──< SEASONS └──< GAMES >── TEAMS └──< SCORE_UPDATES
└──< PLAYERS └──< PLAYER_STATS
TEAMS └──< STANDINGS
USERS └──< PAYMENTS
USERS └──< NOTIFICATIONS
USERS └──< USER_FOLLOWS >── TEAMS / PLAYERS / LEAGUES


## **Explanation of Relationships**

- **sports → leagues:** One sport (e.g., Baseball) has many leagues (e.g., MLB).  
- **leagues → seasons:** One league has multiple seasons (e.g., 2024, 2025).  
- **seasons → games:** Each season contains multiple fixtures.  
- **games → teams:** Each game has two teams — home and away.  
- **games → score_updates:** Every game can have multiple live score entries.  
- **teams → standings:** Each team has one record per season.  
- **teams → players:** Each team contains multiple players.  
- **players → player_stats:** Each player has multiple stat entries per game.  
- **users → payments:** Each user can have multiple payment records.  
- **users → notifications:** Each user receives various notifications.  
- **users → user_follows:** Each user can follow teams, players, or leagues.



## **Queries File (`fantasyid_queries.sql`)**

Alongside the schema, there is a **queries file** containing all the `SELECT` statements used by the UI and backend.  
Queries are grouped by screen or feature.

### **Dashboard**
- Current matchups (today/this week)  
- Quick standings snapshot  

### **Live Scores**
- List of ongoing games  
- Latest score per game  

### **League Page**
- Standings table  
- Upcoming games (next 7 days)  
- Recent results  

### **Game Details**
- Game header information  
- Score timeline (period-wise updates)  

### **Search**
- Search teams by name, short name, or city  
- Search games by team name and date range  

### **Admin**
- Recent users  
- Payments list  
- Payments summary  

### **Players & Trending Players**
- Player list for a specific game or team  
- Trending players (top scorers or best performers from recent games)  

### **Notifications**
- Retrieve user-specific notifications (live, upcoming, final)  
- Mark notifications as read  

### **User Follows**
- Fetch live/upcoming games for followed teams or players  
- Add or remove user follows  

---

## **Usage Notes**

1. Run `fantasyid_schema.sql` to create all tables.  
2. (Optional) Add seed data manually or via API loader.  
3. Use `fantasyid_queries.sql` for backend integration — each endpoint corresponds to a UI feature.  
4. When new features are added to the UI, extend the schema and queries accordingly.
5. 
