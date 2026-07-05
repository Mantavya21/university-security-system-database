# University Security System Database

A complete DBMS course project: requirements analysis, ER modeling, relational schema, and 40 SQL queries for a database that digitizes campus security — entry/exit logging, visitor passes, guard duty rosters, incident reports, vehicle tracking, parcels, lost & found, and golf cart bookings.

Built for our DBMS coursework by **Group 5C**:
- [Mantavya Bhojani](https://github.com/Mantavya21) — 202403028
- Chovatiya Yash — 202403006

> A working implementation of the Golf Cart module (Node.js/Express + PostgreSQL + HTML frontend) lives in a separate repo: **[golf-cart-manager](https://github.com/Mantavya21/golf-cart-manager)**.

---

## 📌 Why this project

Most universities still track campus security on paper — handwritten visitor registers, verbal guard shift handovers, incident reports scattered across notebooks. This leads to missing records, slow gate queues, and no reliable answer to "who is on campus right now?"

This project designs a relational database that replaces those manual processes with structured, queryable data. Full context — problem statement, stakeholder interviews, and background research — is in [`docs/SRS.md`](SRS.md).

## 🗂️ Repository structure

```
.
├── SRS.md              # Full Software Requirements Specification
├── er-diagram.jpg      # Entity-Relationship diagram
├── schema.sql          # DDL: normalized tables, function, trigger
├── queries.sql         # 40 sample SQL queries, organized by topic
└── README.md
```

## 🧩 Entity-Relationship Diagram

(in ['ER Diagram'](er-diagram.jpg))

## 🏗️ Database Design

The schema went through raw entity extraction → relational mapping → normalization. The final normalized design (in [`schema.sql`](schema.sql)) includes:

| Table | Purpose |
|---|---|
| `Person` | Base entity — shared attributes for students, visitors, and guards |
| `Student`, `Visitor`, `Guard` | Role-specific tables linked to `Person` (ISA hierarchy) |
| `EntryExit` | Digital entry/exit logs |
| `Vehicle` | Registered student, staff, and visitor vehicles |
| `GolfCart`, `Rides_Student`, `Rides_Visitor` | Golf cart bookings and ride history |
| `Parcel` | Deliveries — sender, receiver, pickup deadline, status |
| `LostItem`, `Claim` | Lost & Found reporting and claim tracking |
| `Incident` | Structured incident reports (type, severity, status) |

It also includes:
- A **PL/pgSQL function** `GetStudentName(student_id)` that resolves a student's name.
- A **trigger** that automatically flips a lost item's status to `'Claimed'` the moment a matching `Claim` row is inserted.

## 🔍 Sample Queries

[`queries.sql`](queries.sql) has 40 queries grouped into five sections:

1. Basic filtering & sorting
2. Joins across entities
3. Subqueries (`IN`, `NOT EXISTS`, correlated)
4. CTEs, window functions (`RANK() OVER`), and `CASE` logic
5. Function & trigger demonstrations

## 🚀 Getting Started

```bash
# 1. Create a database
createdb security_database

# 2. Build the schema (tables, function, trigger)
psql -d security_database -f database/schema.sql

# 3. Try the sample queries
psql -d security_database -f database/queries.sql
```

## 📖 Full Documentation

- [Software Requirements Specification (SRS)](SRS.md) — purpose, scope, user classes, operating environment, product functions, privileges matrix, assumptions, and constraints.

## 🔗 Related Repo

The **Golf Cart** module from this schema was implemented end-to-end as a full-stack CRUD app:
**[golf-cart-manager](https://github.com/Mantavya21/golf-cart-manager)** — Node.js/Express backend + PostgreSQL + a responsive HTML frontend for adding, updating, and removing golf carts in real time.

## 📄 License

This project was created for academic purposes as part of a DBMS coursework assignment.
