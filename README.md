# Udacity DEND: Project 1 (Data Modeling with Postgres)

This project requires the student to put themselves in the shoes of an analytics
engineer at Sparkify, a music streaming startup. Sparkify needs a data model
that will allow analytic queries on song plays.

## Schema & ETL

The underlying data lives in JSON files as logs of user activity in the app and
metadata of songs. The ETL process herein extracts the these data and transforms
it into a set of relations in a *star* schema consisting of 1 fact table (i.e.,
`songplays`) and 4 dimension tables (i.e., `users`, `artists`, `songs`, `time`).

![sparkify_ERD](https://raw.githubusercontent.com/kenhanscombe/project-postgres/master/sparkify_erd.png)
**Image Credit**: Ken Hanscombe ([onekenken](https://github.com/kenhanscombe))

### Executing the ETL

- The Python environment dependencies can be found in `requirements.txt` and
installed with `pip install -r requirements.txt`. (This project was built using
Python 3.8.)
- This project was developed locally using the Docker image Ken Hanscombe ([onekenken](https://github.com/kenhanscombe)) built.
- The Makefile provides several useful commands to actually interface with the image and run the ETL; these commands are detailed in the table below.

| Command | Description |
|:-------:|:-------|
| `make run` | Pulls the requisite image and runs container. |
| `make test` |  Runs the ETL and test scripts. |
| `make clean` | Kills container. |

- `etl.py` populates the **songs** and **artists** tables with data stored in the JSON song files located in the `data/song_data` directory. 
- Log files, found in `data/log_data`, populate **time** and **users** tables (also performed by `etl.py`).

## Sample Queries

I've added a few sample queries to `test.ipynb`, which are reproduced below:

```sql
-- Average user-session length by level (excluding 0 minute sessions)
with

    cte_user_sessions as (
        select 
            user_id,
            session_id,
            level,
            (max(sp.start_time) - min(sp.start_time))::float / (1000 * 60) as session_length_mins
        from songplays as sp
        join time as t
            on sp.start_time = t.start_time
        where year = 2018
        group by 1, 2, 3
    )

select
    level,
    avg(session_length_mins) as avg_session_length_mins
from cte_user_sessions
where session_length_mins > 0
group by 1;
```

```sql
-- Weeks in 2018 with the highest proportion of female users 
select 
    week, 
    count(distinct (case when gender = 'F' then sp.user_id else null end))::float / count(distinct sp.user_id) as pct_female_users
from songplays as sp
left join users as u 
    on sp.user_id = u.user_id
left join time as t 
    on sp.start_time = t.start_time
where year = 2018
group by 1
order by 2 desc;
```

```sql
-- Users with the most number of devices / "user agents"
select
    user_id,
    device_cnt
from (
    select 
        user_id,
        count(distinct user_agent) device_cnt,
        dense_rank() over (
            partition by user_id
            order by count(distinct user_agent)
        ) as device_cnt_rank
    from songplays
    group by 1
) user_device_counts
where device_cnt_rank = 1
```
