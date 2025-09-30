/* =========================================================
   Target DB
   ========================================================= */
USE EsportsChampionship;
GO




-- 1) List all games with basic info
SELECT name, genre, platform
FROM dbo.Game;
GO

-- 2) Number of teams
SELECT COUNT(*) AS nb_teams
FROM dbo.Team;
GO

-- 3) Tunisian players (nickname + country)
SELECT nickname, country
FROM dbo.Player
WHERE country = 'Tunisia';
GO

-- 4) Teams founded in/after 2022
SELECT name, founded_year
FROM dbo.Team
WHERE founded_year >= 2022;
GO

-- 5) 2025 tournaments (start/end dates)
SELECT name, start_date, end_date
FROM dbo.Tournament
WHERE season_year = 2025;
GO

-- 6) Matches belonging to a specific tournament
SELECT m.*
FROM dbo.Match AS m
JOIN dbo.Tournament AS t
  ON t.tournament_id = m.tournament_id
WHERE t.name = 'Maghreb Valorant Cup';
GO

-- 7) Player count by country
SELECT country, COUNT(*) AS nb_players
FROM dbo.Player
GROUP BY country
ORDER BY country;
GO

-- 8) Teams (name + country), sorted by country then name
SELECT name, country
FROM dbo.Team
ORDER BY country, name;
GO

-- 9) All matches at the 'Final' stage
SELECT *
FROM dbo.Match
WHERE stage = 'Final';
GO

-- 10) First 5 players by ID
SELECT TOP (5) player_id, nickname
FROM dbo.Player
ORDER BY player_id;
GO



-- 11) Number of tournaments per game
SELECT g.name AS game, COUNT(*) AS nb_tournaments
FROM dbo.Tournament AS tt
JOIN dbo.Game AS g
  ON g.game_id = tt.game_id
GROUP BY g.name
ORDER BY g.name;
GO

-- 12) Match sheet (team1, team2, winner, date, stage)
--     (Fixed: winner join uses alias 'w' correctly)
SELECT
    m.match_id,
    t1.name AS team1,
    t2.name AS team2,
    w.name  AS winner,
    m.match_date,
    m.stage
FROM dbo.Match AS m
JOIN dbo.Team  AS t1 ON t1.team_id = m.team1_id
JOIN dbo.Team  AS t2 ON t2.team_id = m.team2_id
JOIN dbo.Team  AS w  ON w.team_id  = m.winner_team_id
ORDER BY m.match_date;
GO

-- 13) Current players per team (leave_date IS NULL)
SELECT
    t.name AS team,
    COUNT(*) AS current_players 
FROM dbo.Team AS t
LEFT JOIN dbo.TeamPlayer AS tp
  ON tp.team_id = t.team_id
 AND tp.leave_date IS NULL
GROUP BY t.name
ORDER BY current_players DESC, team;
GO

-- 14) Number of matches per tournament
SELECT
    tt.name AS tournament,
    COUNT(*) AS nb_matches 
FROM dbo.Tournament AS tt
JOIN dbo.Match AS m
  ON m.tournament_id = tt.tournament_id
GROUP BY tt.name
ORDER BY nb_matches DESC, tournament;
GO

-- 15) Matches played per team (only Tunisian teams)
SELECT
    t.name AS team,
    COUNT(*) AS matches_played
FROM dbo.Team AS t
JOIN dbo.Match AS m
  ON m.team1_id = t.team_id OR m.team2_id = t.team_id
WHERE t.country = 'Tunisia'
GROUP BY t.name
ORDER BY matches_played DESC, team;
GO

-- 16) Average match duration per tournament
SELECT
    m.tournament_id,
    t.name,
    AVG(CAST(m.duration_min AS FLOAT)) AS average_match_duration_min
FROM dbo.Match AS m
JOIN dbo.Tournament AS t
  ON t.tournament_id = m.tournament_id
GROUP BY m.tournament_id, t.name;
GO

-- 17) Winners in Finals (one row per final match)
SELECT
    t.name  AS tournament_name,
    te.name AS team_name
FROM dbo.Match AS m
JOIN dbo.Tournament AS t ON t.tournament_id = m.tournament_id
JOIN dbo.Team       AS te ON te.team_id      = m.winner_team_id
WHERE m.stage = 'Final'
GROUP BY m.tournament_id, m.winner_team_id, m.stage, t.name, te.name;
GO

-- 18) Number of teams and players per country
--     (Note: this counts memberships; use DISTINCT tp.player_id per country
--      if you want distinct people rather than rows in TeamPlayer.)
SELECT
    t.country,
    COUNT(t.team_id)          AS number_of_teams,
    COUNT(tp.player_id)       AS number_of_players
FROM dbo.Team AS t
JOIN dbo.TeamPlayer AS tp
  ON t.team_id = tp.team_id
GROUP BY t.country;
GO

-- 19) Player → current team mapping (all memberships)
SELECT
    p.nickname,
    p.full_name,
    t.name AS team_name
FROM dbo.Team       AS t
JOIN dbo.TeamPlayer AS tp ON t.team_id   = tp.team_id
JOIN dbo.Player     AS p  ON tp.player_id = p.player_id
GROUP BY tp.player_id, p.nickname, p.full_name, tp.team_id, t.name
ORDER BY tp.player_id;
GO


/* =========================================================
   SCORES & TOURNAMENT STATS
   ========================================================= */

-- 20) Total cumulative scores per tournament (team1 + team2)
SELECT 
    t.tournament_id,
    t.name        AS tournoi,
    t.season_year AS saison,
    SUM(m.team1_score + m.team2_score) AS total_scores
FROM dbo.Tournament AS t
JOIN dbo.Match      AS m 
  ON t.tournament_id = m.tournament_id
GROUP BY t.tournament_id, t.name, t.season_year
ORDER BY t.tournament_id;
GO

-- 21) Matches with score difference >= 3
--     (Casting to INT in case scores are stored as strings)
SELECT
    match_id,
    tournament_id,
    team1_score,
    team2_score,
    ABS(CAST(team1_score AS INT) - CAST(team2_score AS INT)) AS score_difference
FROM dbo.Match
WHERE ABS(CAST(team1_score AS INT) - CAST(team2_score AS INT)) >= 3;
GO

-- 22) Prize pools aggregated per game (with game metadata)
SELECT
    t.game_id,
    g.name,
    g.genre,
    g.platform,
    SUM(t.prize_pool_usd) AS sum_of_prizes
FROM dbo.Tournament AS t
JOIN dbo.Game      AS g ON g.game_id = t.game_id
GROUP BY t.game_id, g.name, g.genre, g.platform
ORDER BY sum_of_prizes DESC;
GO

-- 23) Distinct (tournament, team) participations
SELECT DISTINCT
    tt.name AS tournament,
    t.name  AS team
FROM dbo.Match AS m
JOIN dbo.Tournament AS tt
  ON tt.tournament_id = m.tournament_id
JOIN dbo.Team AS t
  ON t.team_id IN (m.team1_id, m.team2_id)
ORDER BY tournament, team;
GO

-- 24) Top 3 teams by total wins
WITH wins AS (
    SELECT winner_team_id AS team_id, COUNT(*) AS wins
    FROM dbo.Match
    GROUP BY winner_team_id
)
SELECT TOP (3) t.name, w.wins
FROM wins AS w
JOIN dbo.Team AS t ON t.team_id = w.team_id
ORDER BY w.wins DESC, t.name;
GO

-- 25) Win/Loss and win rate (%) per team
WITH stats AS (
    SELECT
        t.team_id,
        SUM(CASE WHEN m.winner_team_id = t.team_id THEN 1 ELSE 0 END) AS wins,
        SUM(
            CASE
                WHEN m.winner_team_id <> t.team_id
                 AND (m.team1_id = t.team_id OR m.team2_id = t.team_id)
                THEN 1 ELSE 0
            END
        ) AS losses
    FROM dbo.Team AS t
    LEFT JOIN dbo.Match AS m
      ON m.team1_id = t.team_id OR m.team2_id = t.team_id
    GROUP BY t.team_id
)
SELECT
    t.name,
    s.wins,
    s.losses,
    CAST(
        CASE WHEN (s.wins + s.losses) = 0 THEN 0.0
             ELSE (CAST(s.wins AS FLOAT) / (s.wins + s.losses)) * 100
        END AS DECIMAL(5,2)
    ) AS win_rate_pct
FROM stats AS s
JOIN dbo.Team AS t
  ON t.team_id = s.team_id
ORDER BY win_rate_pct DESC, t.name;
GO

-- 26) League points table (3 win, 1 draw, 0 loss)
;WITH team_matches AS (
    SELECT
        t.team_id,
        m.match_id,
        m.team1_score,
        m.team2_score, 
        m.winner_team_id
    FROM dbo.Team AS t
    JOIN dbo.Match AS m 
      ON m.team1_id = t.team_id OR m.team2_id = t.team_id
),
points AS (
    SELECT
        team_id,
        SUM(
            CASE
                WHEN winner_team_id = team_id THEN 3
                WHEN team1_score = team2_score THEN 1
                ELSE 0
            END
        ) AS pts
    FROM team_matches
    GROUP BY team_id
)
SELECT t.name, p.pts
FROM points AS p
JOIN dbo.Team AS t ON t.team_id = p.team_id
ORDER BY p.pts DESC, t.name;
GO

-- 27) Team win rate by game (0–100%)
;WITH base AS (
    SELECT m.*, tt.game_id
    FROM dbo.Match AS m
    JOIN dbo.Tournament AS tt
      ON tt.tournament_id = m.tournament_id
),
team_game AS ( 
    SELECT
        t.team_id,
        g.game_id,
        g.name AS game_name,
        SUM(CASE WHEN b.winner_team_id = t.team_id THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN (b.team1_id = t.team_id OR b.team2_id = t.team_id) THEN 1 ELSE 0 END) AS plays
    FROM dbo.Team AS t
    JOIN base AS b
      ON b.team1_id = t.team_id OR b.team2_id = t.team_id
    JOIN dbo.Game AS g
      ON g.game_id = b.game_id
    GROUP BY t.team_id, g.game_id, g.name
)
SELECT
    t.name AS team,
    tg.game_name,
    tg.wins,
    tg.plays,
    CAST(
        CASE WHEN tg.plays = 0 THEN 0.0 
             ELSE (CAST(tg.wins AS FLOAT) / tg.plays) * 100
        END AS DECIMAL(5,2)
    ) AS win_rate_pct
FROM team_game AS tg
JOIN dbo.Team AS t ON t.team_id = tg.team_id
ORDER BY team, win_rate_pct DESC;
GO

-- 28) Players who joined ≥ 2 distinct teams
;WITH affiliations AS (
    SELECT
        player_id,
        COUNT(DISTINCT team_id) AS nb_teams
    FROM dbo.TeamPlayer
    GROUP BY player_id
    HAVING COUNT(DISTINCT team_id) >= 2
)
SELECT
    p.nickname,
    p.full_name,
    a.nb_teams
FROM affiliations AS a
JOIN dbo.Player AS p ON p.player_id = a.player_id
ORDER BY a.nb_teams DESC, p.nickname;
GO

-- 29) First join & last activity per player (leave_date or today)
SELECT
    p.nickname,
    MIN(tp.join_date) AS first_join,
    MAX(COALESCE(tp.leave_date, CAST(GETDATE() AS DATE))) AS last_activity
FROM dbo.Player AS p
LEFT JOIN dbo.TeamPlayer AS tp
  ON tp.player_id = p.player_id
GROUP BY p.nickname
ORDER BY p.nickname;
GO

-- 30) Pairs of teams that faced each other ≥ 2 times (ID-based)
;WITH pairs AS (
    SELECT
        CASE WHEN m.team1_id < m.team2_id THEN m.team1_id ELSE m.team2_id END AS team_a,
        CASE WHEN m.team1_id < m.team2_id THEN m.team2_id ELSE m.team1_id END AS team_b,
        COUNT(*) AS nb_matches
    FROM dbo.Match AS m
    GROUP BY
        CASE WHEN m.team1_id < m.team2_id THEN m.team1_id ELSE m.team2_id END,
        CASE WHEN m.team1_id < m.team2_id THEN m.team2_id ELSE m.team1_id END
    HAVING COUNT(*) >= 2
)
SELECT
    ta.name AS team_a,
    tb.name AS team_b,
    p.nb_matches
FROM pairs AS p
JOIN dbo.Team AS ta ON ta.team_id = p.team_a
JOIN dbo.Team AS tb ON tb.team_id = p.team_b
ORDER BY p.nb_matches DESC, team_a, team_b;
GO

-- 31) Same as above but grouping on names directly
SELECT 
    CASE WHEN m.team1_id < m.team2_id THEN t1.team_id ELSE t2.team_id END AS equipe_A_id,
    CASE WHEN m.team1_id < m.team2_id THEN t2.team_id ELSE t1.team_id END AS equipe_B_id,
    CASE WHEN m.team1_id < m.team2_id THEN t1.name    ELSE t2.name    END AS equipe_A,
    CASE WHEN m.team1_id < m.team2_id THEN t2.name    ELSE t1.name    END AS equipe_B,
    COUNT(*) AS nb_matchs
FROM dbo.Match AS m
JOIN dbo.Team  AS t1 ON m.team1_id = t1.team_id
JOIN dbo.Team  AS t2 ON m.team2_id = t2.team_id
GROUP BY 
    CASE WHEN m.team1_id < m.team2_id THEN t1.team_id ELSE t2.team_id END,
    CASE WHEN m.team1_id < m.team2_id THEN t2.team_id ELSE t1.team_id END,
    CASE WHEN m.team1_id < m.team2_id THEN t1.name    ELSE t2.name    END,
    CASE WHEN m.team1_id < m.team2_id THEN t2.name    ELSE t1.name    END
HAVING COUNT(*) >= 2
ORDER BY nb_matchs DESC;
GO
