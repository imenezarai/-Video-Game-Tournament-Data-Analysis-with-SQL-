# -Video-Game-Tournament-Data-Analysis-with-SQL-
 SQL project focused on analyzing a video game tournament dataset using SQL Server Management Studio (SSMS). The repository includes the database schema and advanced T-SQL queries used to calculate player performance metrics, team statistics, and derive key insights into tournament dynamics and outcomes.
🏆 Maghreb E-Sport Championship: In-Depth SQL Data Analysis 📊
This repository showcases a comprehensive SQL data analysis project focused on the competitive data from a hypothetical Maghreb E-Sport Championship. The project involved designing a functional database schema and employing advanced T-SQL techniques to transform raw match and player data into actionable insights for e-sport management and strategic analysis.

🎯 Analytical Objectives
The core objective was to utilize the EsportsChampionship database to address critical business questions across four key areas of the tournament:

1. Tournament & Match Dynamics
Match Reporting: Generating detailed match logs, including team names, winners, and score differentials.

Event Statistics: Calculating metrics like the average match duration per tournament and the total accumulated score for each event.

Championship Insight: Identifying the overall tournament champion (winner of the Final stage) for every major event.

2. Team & Player Performance
Efficiency Metrics: Calculating complex performance indicators such as the Win Rate (%) per team, per game (segmented analysis).

Ranking System: Implementing a global team ranking algorithm based on a point system (Win=3, Draw=1, Loss=0).

Talent Scouting: Determining the current roster size for each team and identifying the Top 3 teams by total victories.

3. Rivalry & Activity Tracking
Head-to-Head Analysis: Detecting team rivalries by identifying pairs of teams that have faced each other at least two times.

Player History: Analyzing player tenure by calculating their total professional activity period (from their first join_date to their last leave_date or today).

Transfer Analysis: Detecting player transfers by querying players who have been associated with multiple teams.

4. Geographic & Structural Analysis
Resource Allocation: Providing a breakdown of teams and players organized by country of origin.

Tournament Ecosystem: Analyzing the distribution of tournaments across different games and calculating the total prize pool associated with each game title.
