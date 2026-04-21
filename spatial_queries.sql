-- ==============================================================================
-- ORACLE SPATIAL RISK ASSESSMENT SYSTEM
-- Project: Advanced Spatial Database Design & Risk Assessment
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. SCHEMA CREATION
-- ------------------------------------------------------------------------------

-- Create Table for Urban Risk Zones (Polygons)
CREATE TABLE urban_zones (
    zone_id NUMBER PRIMARY KEY,
    zone_name VARCHAR2(100),
    zone_type VARCHAR2(50), -- e.g., 'Flood Risk', 'Commercial'
    shape SDO_GEOMETRY
);

-- Create Table for Critical Facilities (Points)
CREATE TABLE city_facilities (
    facility_id NUMBER PRIMARY KEY,
    facility_name VARCHAR2(100),
    category VARCHAR2(50), -- e.g., 'Hospital', 'School'
    location SDO_GEOMETRY
);

-- ------------------------------------------------------------------------------
-- 2. METADATA REGISTRATION & INDEXING
-- Register Geometry Metadata for both tables (SRID 4326 - WGS 84 GPS Coordinates)
-- ------------------------------------------------------------------------------

INSERT INTO user_sdo_geom_metadata VALUES (
    'URBAN_ZONES', 
    'SHAPE',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, 0.005), SDO_DIM_ELEMENT('Y', -90, 90, 0.005)), 
    4326
);

INSERT INTO user_sdo_geom_metadata VALUES (
    'CITY_FACILITIES', 
    'LOCATION',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, 0.005), SDO_DIM_ELEMENT('Y', -90, 90, 0.005)), 
    4326
);

-- Create Spatial Indexes (Crucial for query efficiency on large datasets)
CREATE INDEX zone_spatial_idx ON urban_zones(shape) INDEXTYPE IS MDSYS.SPATIAL_INDEX;
CREATE INDEX facility_spatial_idx ON city_facilities(location) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- ------------------------------------------------------------------------------
-- 3. DATA INSERTION (Simulating the Urban Environment)
-- ------------------------------------------------------------------------------

-- Insert a High-Risk Flood Zone (A Polygon covering a specific coordinate block)
INSERT INTO urban_zones VALUES (
    1,
    'River Basin Alpha', 
    'Flood Risk',
    SDO_GEOMETRY(
        2003, 
        4326, 
        NULL, 
        SDO_ELEM_INFO_ARRAY(1, 1003, 1), 
        SDO_ORDINATE_ARRAY(72.80, 19.00, 72.90, 19.00, 72.90, 19.10, 72.80, 19.10, 72.80, 19.00)
    )
);

-- Insert Facilities (Hospitals and Schools at specific GPS coordinates)
-- Inside the Flood Zone
INSERT INTO city_facilities VALUES (
    101,
    'City Central Hospital', 
    'Hospital',
    SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(72.85, 19.05, NULL), NULL, NULL)
);

-- Outside the Flood Zone
INSERT INTO city_facilities VALUES (
    102,
    'Safehill High School', 
    'School',
    SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(73.10, 19.50, NULL), NULL, NULL)
);

-- Just outside, but close to the boundary
INSERT INTO city_facilities VALUES (
    103,
    'Metro General Hospital', 
    'Hospital',
    SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(72.92, 19.08, NULL), NULL, NULL)
);

COMMIT;

-- ------------------------------------------------------------------------------
-- 4. ANALYTICAL SPATIAL QUERIES
-- ------------------------------------------------------------------------------

-- Query 1: Topological Containment (Point-in-Polygon)
-- Business Question: Which critical hospitals are located directly inside the 
-- high-risk flood zones and need immediate evacuation plans?
SELECT f.facility_name, f.category, z.zone_name
FROM city_facilities f, urban_zones z
WHERE z.zone_type = 'Flood Risk' 
  AND f.category = 'Hospital'
  AND SDO_INSIDE(f.location, z.shape) = 'TRUE';

-- Query 2: Buffer & Proximity Analysis
-- Business Question: Which facilities are within a 15-kilometer radius of the 
-- "River Basin Alpha" boundary, regardless of whether they are strictly inside it?
SELECT f.facility_name, 
       SDO_GEOM.SDO_DISTANCE(f.location, z.shape, 0.005, 'unit=KM') AS Distance_From_Zone_KM
FROM city_facilities f, urban_zones z
WHERE z.zone_name = 'River Basin Alpha'
  AND SDO_WITHIN_DISTANCE(f.location, z.shape, 'distance=15 unit=KM') = 'TRUE'
ORDER BY Distance_From_Zone_KM ASC;

-- Query 3: Geometric Area Calculation
-- Business Question: What is the total geographical area (in square kilometers) 
-- of the high-risk flood zone to calculate relief budget allocation?
SELECT zone_name, 
       ROUND(SDO_GEOM.SDO_AREA(shape, 0.005, 'unit=SQ_KM'), 2) AS Area_Square_Kilometers
FROM urban_zones
WHERE zone_type = 'Flood Risk';
