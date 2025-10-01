

## FantasyID Database File (fantasyid_schema.sql)

This database stores all the data needed for the **FantasyID** Sports Platform.  
It is built in **MySQL** and designed to support multiple sports, leagues, seasons, teams, games, live scores, standings, user accounts and payments.

---

## Overview

The database contains 9 main tables:

| Table         | Purpose                                                                                  |
|---------------|------------------------------------------------------------------------------------------|
| `sports`      | List of sports supported (e.g. Basketball, American Football).                           |
| `leagues`     | Leagues for each sport (e.g. NBA for Basketball, NFL for American Football).             |
| `seasons`     | Seasons/years of each league (e.g. 2024-25 NBA season).                                  |
| `teams`       | Teams that participate in a league.                                                      |
| `games`       | Individual matchups/fixtures between teams.                                              |
| `score_updates`| Live and final score snapshots for each game.                                           |
| `standings`   | Wins/losses/draws per team per season (drives standings and quick stats).                |
| `users`       | User accounts for login and signup.                                                      |
| `payments`    | Payment/subscription records linked to users.                                            |

---

## Table Details

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
- Linked to `seasons` and `leagues` plus home and away `teams`.
- **Key columns:** `game_id`, `season_id`, `league_id`, `home_team_id`, `away_team_id`, `start_time`, `venue`, `status`.

### 6. `score_updates`
- Stores score snapshots over time for each game.
- Linked to `games` via `game_id`.
- **Key columns:** `score_update_id`, `game_id`, `update_time`, `period`, `home_score`, `away_score`, `is_final`.

### 7. `standings`
- Stores wins/losses/draws per team per season.
- Linked to `seasons` and `teams`.
- **Key columns:** `standing_id`, `season_id`, `team_id`, `wins`, `losses`, `draws`.

### 8. `users`
- Stores user accounts for login/signup.
- **Key columns:** `user_id`, `email`, `username`, `password_hash`.

### 9. `payments`
- Stores payment/subscription records.
- Linked to `users` via `user_id`.
- **Key columns:** `payment_id`, `user_id`, `amount`, `currency`, `status`.


## Relationships Diagram (text)

 SPORTS
   └──< LEAGUES
          └──< SEASONS
                 └──< GAMES >── TEAMS
                         └──< SCORE_UPDATES

 TEAMS
   └──< STANDINGS

 USERS
   └──< PAYMENTS


## Explanation of relationships

- sports → leagues:
- One sport (Basketball) has many leagues (NBA, EuroLeague, etc.).

- leagues → seasons:
- One league has many seasons/years (2024-25, 2025-26).

- seasons → games:
- Each season has many games (fixtures/matchups).

- games → teams:
- Each game involves two teams: home_team_id and away_team_id.

- games → score_updates:
- Each game can have many score updates (live snapshots).

- teams → standings:
- Each team has one row per season in standings.

- users → payments:
- Each user can have many payments/subscriptions.




## Queries File (`fantasyid_queries.sql`)

Alongside the schema, there is a **fantasyid_queries.sql file** that contains the `SELECT` statements used by the UI and backend.  
This file is organized by feature/screen:

- **Dashboard**  
  - Current matchups (today/this week)  
  - Quick standings snapshot  

- **Live Scores**  
  - List of live games  
  - Latest score per game  

- **League Page**  
  - Standings table  
  - Upcoming games (next 7 days)  
  - Recent results  

- **Game Details Page**  
  - Game header info  
  - Score timeline  

- **Search**  
  - Search teams by name/city  
  - Search games by team name + date range  

- **Admin**  
  - Recent users  
  - Payments list  
  - Payments summary  

> These queries use parameters like `league_id`, `season_id`, `status`, `from`/`to` date ranges, and `limit`/`offset`. They are written to align exactly with what the UI shows.

---

## Usage Notes

1. **Run the schema script first** (`fantasyid_schema.sql`) to create tables.  
2. (Optional) **Run the seed script** (`fantasyid_seed.sql`) to add demo data.  
3. **Use the queries** (`fantasyid_queries.sql`) as reference inside the backend API. Each API endpoint should map to one of these queries.  
4. When new screens are added to the UI, extend the queries file with new `SELECT` statements as needed.  
