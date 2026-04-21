# 🌍 Oracle Spatial: Advanced Risk Assessment System

[![Oracle Database](https://img.shields.io/badge/Database-Oracle_19c%2F21c-F80000.svg?logo=oracle)](https://www.oracle.com/database/)
[![SQL](https://img.shields.io/badge/Language-SQL-003B57.svg)](https://en.wikipedia.org/wiki/SQL)
[![GIS](https://img.shields.io/badge/Domain-Geospatial_Analysis-1E88E5.svg)]()

This project is a specialized database engineering showcase demonstrating the use of **Oracle Spatial and Graph**. It features an advanced spatial schema designed for urban planning and disaster management, executing complex topological queries (Containment, Proximity, and Area Calculation) without the need for external GIS software.

---

## 🏗️ Technical Architecture & Schema Design

Traditional databases store location data as separate `latitude` and `longitude` numbers, making radius or boundary calculations extremely slow and mathematically complex. 

This project utilizes Oracle's native `SDO_GEOMETRY` object type and spatial indexing (`MDSYS.SPATIAL_INDEX`) to treat map data as actual geometric objects.

### 1. The Geometry Data Models
- **Urban Zones (Polygons):** Represents large geographical boundaries (e.g., Flood Zones, Commercial Sectors).
- **City Facilities (Points):** Represents specific infrastructure nodes mapped via WGS 84 GPS Coordinates (SRID 4326), such as Hospitals and Schools.

### 2. Spatial Metadata & Indexing
To ensure sub-second query performance on geographical calculations, the schema registers coordinates with `user_sdo_geom_metadata` and implements spatial R-tree indexing.

---

## 🔍 Core Spatial Queries

The true power of this implementation lies in its ability to answer complex business/logistical questions using native SQL functions. *(See `spatial_queries.sql` for the full implementation).*

### 1. Topological Containment (Point-in-Polygon)
**Business Question:** *Which critical hospitals are located directly inside high-risk flood zones and require immediate evacuation plans?*
- **Mechanism:** Utilizes the `SDO_INSIDE()` operator to verify if a Facility (Point) intersects entirely within a Zone (Polygon).

### 2. Buffer & Proximity Analysis
**Business Question:** *Which facilities are within a 15-kilometer radius of the "River Basin Alpha" boundary, regardless of whether they are strictly inside it?*
- **Mechanism:** Employs the `SDO_WITHIN_DISTANCE()` function to create a virtual 15km buffer around the polygon edge, calculating the precise `SDO_GEOM.SDO_DISTANCE` of surrounding points.

### 3. Geometric Area Calculation
**Business Question:** *What is the total geographical area (in square kilometers) of the high-risk flood zone to calculate relief budget allocation?*
- **Mechanism:** Computes the polygon area accounting for the Earth's curvature (SRID 4326) using `SDO_GEOM.SDO_AREA()`.

---

## 🚀 Quick Start / Deployment

To test these spatial queries in your own environment:

1. Ensure you have access to **Oracle Database 19c or 21c** (Oracle Live SQL is also supported).
2. Clone this repository:
   ```bash
   git clone [https://github.com/YOUR-USERNAME/Oracle-Spatial-Risk-Assessment.git](https://github.com/YOUR-USERNAME/Oracle-Spatial-Risk-Assessment.git)

3. Open your preferred SQL client (e.g., Oracle SQL Developer, SQL*Plus).

4. Execute the script spatial_queries.sql sequentially to build the schema, insert the mock coordinates, and run the analytical queries.
