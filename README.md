## Project where I'll use snowflake, DBT and preset to analyze data produced by airnb

### First: Register to Snowflake
Go to [https://snowflake.net/](https://snowflake.net/) and register.
### Save region code and account name for later use
## Second: Create a worksheet
## Third: User creation
```
-- Use an admin role
USE ROLE ACCOUNTADMIN;
-- Create the `transform` role
CREATE ROLE IF NOT EXISTS transform;
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN;
-- Create the `dbt` user and assign to role
CREATE USER IF NOT EXISTS dbt
 PASSWORD='dbtPassword123'
 LOGIN_NAME='dbt'
 MUST_CHANGE_PASSWORD=FALSE
 DEFAULT_WAREHOUSE='COMPUTE_WH'
 DEFAULT_ROLE='transform'
 DEFAULT_NAMESPACE='AIRBNB.RAW'
 COMMENT='DBT user used for data transformation';
GRANT ROLE transform to USER dbt;
-- Create our database and schemas
CREATE DATABASE IF NOT EXISTS AIRBNB;
CREATE SCHEMA IF NOT EXISTS AIRBNB.RAW;
-- Set up permissions to role `transform`
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE transform; 
GRANT ALL ON DATABASE AIRBNB to ROLE transform;
GRANT ALL ON ALL SCHEMAS IN DATABASE AIRBNB to ROLE transform;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE AIRBNB to ROLE transform;
GRANT ALL ON ALL TABLES IN SCHEMA AIRBNB.RAW to ROLE transform;
GRANT ALL ON FUTURE TABLES IN SCHEMA AIRBNB.RAW to ROLE transform
```
## Create tables for storing data
```
-- Set up the defaults
USE WAREHOUSE COMPUTE_WH;
USE DATABASE airbnb;
USE SCHEMA RAW;
-- Create our three tables and import the data from S3
CREATE OR REPLACE TABLE raw_listings
 (id integer,
 listing_url string,
 name string,
 room_type string,
 minimum_nights integer,
 host_id integer,
 price string,
 created_at datetime,
 updated_at datetime);
COPY INTO raw_listings (id,
 listing_url,
 name,
 room_type,
 minimum_nights,
 host_id,
 price,
 created_at,
 updated_at)
 from 's3://dbtlearn/listings.csv'
 FILE_FORMAT = (type = 'CSV' skip_header = 1
 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
CREATE OR REPLACE TABLE raw_reviews
 (listing_id integer,
 date datetime,
 reviewer_name string,
 comments string,
 sentiment string);
COPY INTO raw_reviews (listing_id, date, reviewer_name, comments, sentiment)
 from 's3://dbtlearn/reviews.csv'
 FILE_FORMAT = (type = 'CSV' skip_header = 1
 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
CREATE OR REPLACE TABLE raw_hosts
 (id integer,
 name string,
 is_superhost string,
 created_at datetime,
 updated_at datetime);
COPY INTO raw_hosts (id, name, is_superhost, created_at, updated_at)
 from 's3://dbtlearn/hosts.csv'
 FILE_FORMAT = (type = 'CSV' skip_header = 1
 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```
## Install DBT on Windows
I'll use WSL to install DBT, alias created "winhome".
## Install pip
```
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
python get-pip.py
```
## I'll use a virtual environment to install DBT
```
pip install virtualenv
```
## Create a virtual environment
```
virtualenv venv
```
## Activate the virtual environment
```
source venv/bin/activate
```
## See the list of packages installed
```
pip list --format=columns
```
## Install DBT
```
pip install dbt-snowflake
```
## Creating a DBT project and connecting to Snowflake
```
dbt init airbnb
```
## Configure the connection to Snowflake
```
dbt config --provider snowflake --connect "account=dbt;warehouse=COMPUTE_WH;database=AIRBNB;schema=AIRBNB.RAW"
```
## You can see your credentials doing
```
cat ~/.dbt/profiles.yml
```
## Make sure the connection is working
```
dbt debug
```
## Data Flow Process
![We'll use DBT to transform the data](images/data_flow_process_1.PNG)
## Creating raw_listings AS 
```
WITH raw_listings AS (
    SELECT * FROM AIRBNB.RAW.RAW_LISTINGS
)
SELECT 
     id AS listing_id,
     name AS listing_name,
     listing_url,
     room_type,
     minimum_nights,
     host_id,
     price AS price_str,
     created_at,
     updated_at
FROM
 raw_listings
``` 
## Create src_listings in models folder and then execute dbt
```
dbt run
```
## Create src_reviews.sql
```
WITH raw_reviews AS (
    SELECT * FROM AIRBNB.RAW.RAW_REVIEWS
)
SELECT 
    listing_id,
    date AS review_date,
    reviewer_name,
    comments as review_text,
    sentiment as review_sentiment
FROM 
    raw_reviews
```
## Create src_reviews.sql in models folder and then execute dbt
```
dbt run
```
## Create src_hosts.sql
```
WITH raw_hosts AS (
    SELECT * FROM AIRBNB.RAW.RAW_HOSTS
)
SELECT 
    ID AS HOST_ID,
    NAME AS HOST_NAME,
    IS_SUPERHOST,
    CREATED_AT,
    UPDATED_AT
FROM RAW_HOSTS
```
## Create src_hosts.sql in models folder and then execute dbt
```
dbt run
```






