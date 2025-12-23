
# 🚀 End-to-End ETL Pipeline using Snowflake, AWS S3, Snowpipe, Streams & Tasks

## 📌 Project Overview

This project demonstrates a **fully automated, production-grade ETL pipeline** built on **Snowflake** using **AWS S3** as the source system.  
The pipeline ingests CSV files from S3, processes data incrementally, and loads clean, analytics-ready data using **Snowpipe, Streams, and Tasks**.

The implementation follows **modern ELT best practices** and is designed to be **scalable, cost-efficient, and easy to operate**.

---

## 🏗️ High-Level Architecture

```
AWS S3
  │
  ▼
External Stage
  │
  ▼
Snowpipe (AUTO_INGEST)
  │
  ▼
orders_raw (Transient Table)
  │
  ▼
Stream (CDC)
  │
  ▼
Task (Scheduled Transformation)
  │
  ▼
orders_clean (Analytics-Ready Table)
```

---

## 🧩 Technologies Used

- Snowflake Cloud Data Platform  
- AWS S3  
- Snowpipe (Auto Ingestion)  
- Streams (Change Data Capture)  
- Tasks (Scheduling & Orchestration)  
- SQL (ELT Transformations)  

---

## 🛠️ Pipeline Components Explained

### Raw Ingestion Layer – `orders_raw`
- Implemented as a **transient table** to avoid Fail-safe storage costs  
- Stores raw CSV data exactly as received  
- Acts as a landing layer for ingestion  

### Snowpipe
- Automatically ingests files when they arrive in S3  
- Event-driven ingestion (no warehouse required)  
- Enables near real-time data loading  

### Stream (CDC)
- Tracks **incremental inserts** into the raw table  
- Ensures only new data is processed  
- Prevents expensive full-table scans  

### Task (Transformation Layer)
- Runs on a defined schedule  
- Executes only when stream has data  
- Performs type casting, validation, and transformation  

### Clean Table – `orders_clean`
- Stores analytics-ready data  
- Uses proper data types  
- Designed for reporting and downstream analytics  

---

## 📄 Sample Data Format

```csv
order_id,customer_id,product,quantity,amount,order_date
1001,201,Keyboard,1,1500,2025-01-01
1002,202,Mouse,2,800,2025-01-01
```

---

## ▶️ How the Pipeline Works

1. CSV files are uploaded to AWS S3  
2. Snowpipe automatically ingests the files into the raw table  
3. A stream captures newly inserted rows  
4. A scheduled task transforms and loads clean data  
5. The target table is continuously updated incrementally  

---

## ✅ Validation Queries

```sql
SELECT COUNT(*) FROM orders_raw;
SELECT COUNT(*) FROM orders_clean;
SELECT * FROM orders_clean ORDER BY inserted_at DESC;
```

---

## 💡 Key Design Decisions

| Design Choice | Reason |
|--------------|-------|
| Transient RAW table | Avoid Fail-safe storage cost |
| Snowpipe | Event-driven ingestion |
| Streams | Efficient incremental processing |
| Tasks | Serverless orchestration |
| ELT approach | Leverages Snowflake compute |

---

## 📈 Future Enhancements

- Error handling and reject tables  
- Audit and reconciliation tables  
- SCD Type-2 implementation  
- Downstream analytics aggregation  
- Monitoring and alerting  

---

## 🎯 Learning Outcomes

- Built a real-world Snowflake ETL pipeline  
- Implemented auto-ingestion using Snowpipe  
- Applied CDC using Streams  
- Automated transformations using Tasks  
- Followed cloud-native ELT architecture  

---

## 🧠 Interview-Ready Summary

Designed and implemented an end-to-end ETL pipeline in Snowflake using AWS S3, Snowpipe for auto-ingestion, Streams for CDC-based incremental processing, and Tasks for scheduled transformations.

---

## 👤 Author

**Sandeep Kumar Peddareddy**  
Data Engineer  
GitHub: https://github.com/Sandeep-4512  
