# 📊 Advanced Data Modeling — Global Superstore

[![Meta Database Engineer](https://img.shields.io/badge/Meta_Database_Engineer-Advanced_Data_Modeling-0860E5?style=flat-square&logo=meta&logoColor=white)](https://www.coursera.org/account/accomplishments/professional-cert/certificate/ECF0PIQNDK1P)

Raw sales data, transformed through a full database design pipeline: normalized schema → dimensional star schema → interactive Tableau dashboard.

**🔗 Live dashboard:** [GlobalSuperStore on Tableau Public](https://public.tableau.com/app/profile/md.faisal.alam6840/viz/GlobalSuperStore_17888527610020/Dashboard1)

![Dashboard Screenshot](dashboard.jpeg)

---

## What this project shows

Most beginner data projects start with a clean CSV and jump straight to charts. This one starts a step earlier — with raw, denormalized data — and shows the full design process a real analytics system goes through:

1. **Design a normalized relational schema** for transactional integrity (no duplicate/inconsistent data)
2. **Transform it into a star schema** — the dimensional model used by BI tools for fast analytical queries
3. **Build a dashboard** on top, with real written insights, not just default charts

This repo is a core project from the **Meta Database Engineer Professional Certificate** (Course 7: *Advanced Data Modeling*), extended beyond the course brief with a schema modeled 1:1 from the real dataset.

### Course requirements → deliverables in this repo

| Course requirement | Where it lives here |
|---|---|
| Physical ER diagram for Global Super Store (3NF) | `er_diagram.png`, `create_database.sql` |
| Deploy the model to MySQL via Forward Engineer | `create_database.sql` (MySQL Workbench Forward Engineering output) |
| Star schema with products, location and time dimensions | `Step3_StarSchema.sql`, `Step3_StarSchema_Diagram.png` |
| Map chart — sales by USA state with roll-over details | `Sales in USA` worksheet (`GlobalSuperStore.twb`) |
| Bubble chart — USA profits (state, quantity, profit, shipping cost) | `Profits in USA` worksheet (`GlobalSuperStore.twb`) |
| Line chart — sales trends, states with sales > $40,000 | `USA Sales Trends` worksheet (`GlobalSuperStore.twb`) |
| Interactive dashboard combining all three charts | `Dashboard 1` + `dashboard.jpeg` + [live link](https://public.tableau.com/app/profile/md.faisal.alam6840/viz/GlobalSuperStore_17888527610020/Dashboard1) |

---

## Entity-relationship diagram (normalized schema)

![ER diagram](er_diagram.png)

Five related tables — `Customers`, `Products`, `Orders`, `Shipping`, `DeliveryAddress` — each holding one entity's data exactly once, connected via foreign keys. This avoids repeating customer or product details across every order row.

Every column is taken directly from the Global Superstore source dataset (no invented fields):

| Table | Columns sourced from the dataset |
|---|---|
| `Customers` | Customer ID, Customer Name, Segment |
| `Products` | Product ID, Product Name, Category, Sub-Category |
| `DeliveryAddress` | Postal Code, City, State, Country, Region, Market |
| `Shipping` | Ship Date, Ship Mode, Shipping Cost |
| `Orders` | Row ID, Order ID, Order Date, Sales, Quantity, Discount, Profit, Order Priority |

## Star schema (dimensional model)

![Star schema diagram](Step3_StarSchema_Diagram.png)

The normalized tables are then reshaped into a **fact table** (`Sales`, holding the numeric measures — sales, profit, discount, shipping cost, quantity) surrounded by three **dimension tables** (`DimTime`, `DimLocation`, `DimProducts`) holding the descriptive attributes used for filtering and grouping — exactly the products, location and time dimensions the business brief asked for. This is the structure BI tools like Tableau are optimized to query quickly.

---

## Pipeline

1. **Raw data** — Global Superstore sales data (Excel)
2. **Normalize** — designed into a 5-table relational schema (`create_database.sql`), enforcing no data duplication
3. **ETL into star schema** — `Step3_StarSchema.sql` loads representative sample rows into the normalized tables, extracts from them, transforms the shape, and loads into `Sales` + 3 dimension tables
4. **Verify** — queries run and joined successfully against the star schema, verifying joins, key mappings, and aggregations (see `star_schema_verification.jpg`)
5. **Visualize** — the same source dataset is connected to Tableau, producing an interactive dashboard with maps, trend charts, and written analysis of regional sales patterns

---

## Tech stack

| Layer | Technology |
|---|---|
| Database design & modeling | MySQL, MySQL Workbench |
| Schema type | Normalized OLTP → Star schema (dimensional model) |
| Visualization | Tableau |
| Source data | Global Superstore dataset (Excel) |

---

## Run it locally

1. Open **MySQL Workbench**
2. Run `create_database.sql` — builds the normalized 5-table schema
3. Run `Step3_StarSchema.sql` — inserts representative sample rows, transforms them into the star schema (fact + dimension tables), and runs the verification queries
4. Open `GlobalSuperStore.twb` in **Tableau Desktop** to view/edit the dashboard, or view it live on the [published link](https://public.tableau.com/app/profile/md.faisal.alam6840/viz/GlobalSuperStore_17888527610020/Dashboard1)

---

## Design decisions & trade-offs

- **Validated the star-schema ETL on a representative sample before scaling** — confirming the transformation logic (joins, key mapping, aggregation) works correctly on a small, verifiable dataset first, rather than running an unverified transformation against the full dataset. Standard practice before a full production run.
- **The dashboard and the database layer are kept as separate, composable stages** — Tableau connects to the cleaned source data directly, while the MySQL schema/ETL work demonstrates the data modeling layer independently. This separation mirrors how real analytics stacks decouple the data warehouse layer from the BI layer, rather than hard-coupling one tool to one specific database.
- **Schema columns modeled 1:1 from the source dataset** — every column in the normalized schema maps to a real Global Superstore column (Segment, Region, Market, Sales, Profit, Discount, Shipping Cost), so the model stays honest to the data it represents.

## Future improvements

- Connect Tableau directly to the star-schema MySQL database, unifying both stages into a single live pipeline
- Run the validated ETL logic against the full dataset and benchmark query performance (star schema vs. normalized schema) on a real analytical question
- Automate the ETL as a scheduled job rather than a manual script run

---

## Built by

**Faisal** — [GitHub](https://github.com/faisal-devvv) · Project from the [Meta Database Engineer Professional Certificate](https://www.coursera.org/account/accomplishments/professional-cert/certificate/ECF0PIQNDK1P)