# Nashville Housing Data Cleaning — SQL

**Tools:** Microsoft SQL Server (T-SQL) | SSMS | String Parsing | Self-Joins | CTEs | Schema Alteration  
**Dataset:** Nashville Housing Market — 56,000+ real estate transaction records  
**Focus:** End-to-end data preparation pipeline transforming raw housing data into an analysis-ready dataset

---

## Business Problem

Raw real estate transaction data is rarely clean. Date fields are inconsistent, address data is incomplete or unparsed, boolean flags use non-standard encoding, and duplicate records inflate counts and skew analysis. Before any meaningful market analysis can occur — pricing trends, vacancy rates, ownership patterns — the underlying data must be standardized, enriched, and deduplicated. This project simulates a real-world data preparation pipeline using SQL Server on Nashville housing transaction data.

---

## What Was Cleaned

| Problem | Technique Used | Outcome |
|---|---|---|
| Inconsistent date formats | `CONVERT(Date, SaleDate)` + `ALTER TABLE` | Standardized `SaleDateConverted` column added |
| Null property addresses | Self-join on `ParcelID` + `ISNULL()` imputation | Missing addresses populated from matching records |
| Concatenated address strings | `SUBSTRING()` + `CHARINDEX()` parsing | Address split into `PropertySplitAddress` and `PropertySplitCity` |
| Unparsed owner addresses | `PARSENAME()` + `REPLACE()` | Owner data split into Address, City, and State columns |
| Inconsistent boolean flags | `CASE WHEN` standardization | `Y`/`N` values normalized to `Yes`/`No` across dataset |
| Duplicate records | CTE + `ROW_NUMBER()` window function | Duplicates identified and flagged by partition key |
| Unused columns | `ALTER TABLE DROP COLUMN` | Schema cleaned of redundant fields post-transformation |

---

## Technical Highlights

### Null Imputation via Self-Join
```sql
SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress,
       ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
```
Properties sharing a `ParcelID` should share an address. This self-join identifies records with null addresses and imputes them from a matching row — a common real-world pattern in ETL pipelines where source systems have partial data.

### Address Parsing with SUBSTRING and CHARINDEX
```sql
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
```
Splits a single concatenated address string into structured columns, enabling geographic filtering and aggregation downstream.

### Owner Address Parsing with PARSENAME
```sql
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) -- Street
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) -- City
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) -- State
```
Repurposes SQL Server's `PARSENAME()` function — typically used for object name parsing — as an elegant multi-part string splitter by replacing commas with periods.

### Duplicate Detection with CTE + Window Function
```sql
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
SELECT * FROM RowNumCTE WHERE row_num > 1
```
Uses a CTE with `ROW_NUMBER()` partitioned across five business key fields to surface duplicate records — a production-grade deduplication pattern used in data warehouse pipelines.

### Schema Management
Demonstrates DDL proficiency with `ALTER TABLE ADD`, `UPDATE`, and `DROP COLUMN` to evolve the table schema as part of the cleaning workflow — reflecting how data engineers incrementally transform tables in place.

---

## Skills Demonstrated

- Self-joins for data imputation
- String parsing with `SUBSTRING`, `CHARINDEX`, `PARSENAME`, `REPLACE`, `LEN`
- Conditional logic with `CASE WHEN`
- Duplicate detection using `ROW_NUMBER()` window function with multi-field partitioning
- Schema alteration with `ALTER TABLE` (ADD / DROP COLUMN)
- Data standardization and type conversion with `CONVERT`
- CTE-based intermediate result sets

---

## Dataset

- **Source:** Nashville, TN public property records
- **File:** `Nashville Housing Data for Data Cleaning.xlsx`
- **Records:** 56,000+ housing transactions
- **Key Fields:** `ParcelID`, `PropertyAddress`, `OwnerAddress`, `SaleDate`, `SalePrice`, `SoldAsVacant`, `LegalReference`

---

## How to Run

1. Import `Nashville Housing Data for Data Cleaning.xlsx` into SQL Server as a table named `NashvilleHousing` under a database named `Nashville`
2. Open `SQLQuery15.sql` in SSMS
3. Execute sections sequentially — each block builds on the previous transformation
4. Final `DROP COLUMN` statement removes columns superseded by the parsed versions

---

## Author

**Caleb Haqq** — Data Engineer / Analytics Engineer  
[LinkedIn](https://linkedin.com/in/caleb-haqq-5360ab51) | [Portfolio](https://hawkk2.github.io/CalebHaqq.github.io/)
