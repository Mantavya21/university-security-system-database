# Software Requirements Specification (SRS)
## University Security System Database


## 1. Purpose

Most universities still rely on paper registers, handwritten rosters, and verbal communication between guards and administrators to manage campus security. This leads to missing data, delayed responses, and security gaps — visitors enter without leaving proper details, incidents are reported vaguely or not at all, and vehicle entries are rarely tracked.

The **University Security System Database** replaces these manual processes with a structured, centralized database that covers:

- **Digital entry/exit logging** for students, staff, and visitors, so administrators always know who is on campus.
- **Visitor management** — storing visitor name, contact, purpose of visit, and pass expiry instead of illegible paper registers.
- **Security guard management** — duty rosters, shift timings, and attendance instead of verbal/handwritten schedules.
- **Incident reporting** — structured records (type, location, time, reporter) that can't be lost or under-detailed.
- **Vehicles and parcels** — registration numbers, owners, and entry/exit times for vehicles; sender/receiver/delivery time for parcels.
- **Lost & Found** and **Golf Cart** modules for everyday campus operations.

The immediate focus is a reliable, easy-to-use database. Future expansions such as AI-based monitoring, CCTV integration, or predictive scheduling are explicitly out of scope for this phase.

## 2. Intended Audience

| Audience | Role |
|---|---|
| University administration / security officers | Need accurate, real-time information instead of paper registers and verbal updates. |
| Security guards | Frontline users — issue visitor passes, log vehicles, record incidents. |
| Students & staff | Indirect users — entry/exit logged digitally; can use anonymous incident reporting. |
| Visitors | Get quick digital passes with expiry instead of slow manual queues. |
| IT staff | Maintain the database, backups, and technical support. |

## 3. Product Scope

The system is a **data-centric solution**, not a hardware/physical-security project. Core scope:

1. Entry/exit management for students and staff (ID, gate, timestamp).
2. Visitor management with temporary passes (name, contact, purpose, validity).
3. Vehicle tracking (staff, student, visitor, and service vehicles).
4. Guard duty management (rosters, shifts, attendance).
5. Incident reporting (type, location, time, reporter, status).
6. Parcel and delivery management (sender, receiver, pickup deadline, status).
7. Lost & Found module.
8. Golf Cart booking/tracking module.

Advanced features (CCTV integration, mobile app, AI-based monitoring) are intentionally deferred to future phases.

## 4. Fact-Finding Phase

### 4.1 Background Readings

| # | Source | Key Takeaway |
|---|---|---|
| A | *Universities move to QR-based passes for better security* — The Times of India | Indian universities are adopting QR-based visitor passes; handwritten registers are often incomplete/illegible. |
| B | Panjab University, Chandigarh — Hindustan Times | Promotion of guards to "Shift In-Charge" shows the value of structured shift management. |
| C | Times of India — sticker rollout blame game | Bureaucratic delays from missing student data justify a dedicated **Student Vehicle Registration** table. |
| D | Acoem India — *6 ways to improve campus safety* | Manual paper records fail to provide accountability for unauthorized entry. |
| E | VersionX blog — unified campus security platforms | Justifies a **unified database design** consolidating visitors, vehicles, and guard operations. |

### 4.2 Interviews

- **Participants:** Security guards and students
- **Date:** 29/08/2025 (Evening), ~25 minutes, at the cafeteria
- **Agenda:** entry/exit logging issues, guard shift scheduling, incident reporting methods, expectations from a new system

**Guard's perspective:** Work is still paper-based — ID cards are checked but nothing is stored; visitor registers are often unclear; duty hours are managed verbally; incident reports are frequently incomplete or lost.

**Student's perspective:** Long queues at gates during peak hours; incidents like fights/thefts are not always properly recorded or acted on; students want a simple, optionally anonymous way to report incidents online.

### 4.3 Questionnaire

A Google Form was circulated to gather wider feedback from students, staff, and visitors on entry speed, online reporting, CCTV coverage, and vehicle tracking.

### 4.4 Observations

1. Long queues during mornings/events.
2. Entry books filled in incompletely, with no verification.
3. Guards frequently lacking clear shift information.
4. Incidents logged with minimal, handwritten detail.

### 4.5 Fact-Finding Chart

| Technique | Purpose | People Involved | Key Requirements Surfaced |
|---|---|---|---|
| Background reading | Understand existing practices & modern solutions | Self-study | Digital visitor management, ID-based entry |
| Interview | First-hand stakeholder opinions | Guard, Admin Officer, Student | Digital entry/exit logs, dashboard, incident reporting, guard scheduling |
| Questionnaire | Wider feedback | Students, staff, visitors | Faster entry, online reporting, CCTV coverage, vehicle tracking |
| Observation | See real practices in action | Observer, security staff | Automated ID scanning, structured incident logging, digital attendance |

## 5. Requirements List

1. Register every delivery person entering campus and keep a record.
2. Register visitor visits with appropriate details.
3. Allow booking a golf cart for internal transportation.
4. Provide an online platform for immediate incident reporting to security.
5. Digital entry and exit logs for students and staff.
6. Visitor management with pass generation, expiry, and purpose.
7. Guard duty management — rosters, shifts, attendance.
8. Digital record-keeping at every gate instead of paper books.
9. Digital attendance system at the security gate for guards.
10. A way for guards to check their shifts ahead of time.

## 6. User Classes and Characteristics

1. **Students** — use ID cards/QR codes for entry/exit.
2. **Security Guards** — monitor entry/exit, log visitors, verify IDs, submit incident reports digitally, have shifts recorded.
3. **Security/Admin Officers** — oversee schedules, approve/reject visitor passes, review incident reports.
4. **System Administrator (IT/Admin)** — maintains the database, manages accounts/permissions/security.
5. **Visitors** — receive temporary digital/printed passes; entry/exit logged.
6. **Security Supervisor** — views/edits guard duty rosters, approves incident reports, accesses detailed logs.
7. **Event Coordinator** — creates temporary group access for seminars/workshops/events.
8. **Temporary Visitor Role** — limited access via a pass that auto-expires at the end of the visit.

## 7. Operating Environment

**Hardware (Server side):** University/cloud server; barcode scanners at gates and parking; CCTV cameras with digital recording units.

**Hardware (User side):** Student/staff smartphones for notifications; ID cards with QR code printing.

**Software:** Web-based application for admins/security staff; mobile app/portal for students; PostgreSQL/MySQL database for logs and reports.

**Connectivity:** Reliable campus Wi-Fi/LAN linking gates, admin office, and servers.

## 8. Product Functions

1. **Entry and Exit Management** — record entry/exit via ID/QR, update presence records, block/reissue lost IDs.
2. **Visitor Management** — generate/verify temporary passes, track entry/exit, restrict access to specific areas.
3. **Security Guard Management** — duty rosters/shifts, attendance, activity logs.
4. **Incident Reporting** — structured digital reports, optional anonymity, secure storage for review.

## 9. Privileges Matrix

| Module | Students | Staff & Faculty | Visitors | Security Guards | Admin Officers |
|---|---|---|---|---|---|
| Entry/Exit Logging | ✅ (ID/QR) | ✅ (ID/QR) | ✅ (visitor pass) | ✅ (monitor gates) | ✅ (view logs) |
| Visitor Management | ❌ | ✅ (request entry) | ✅ (receive pass) | ✅ (issue passes) | ✅ (approve/reject) |
| Guard Duty Management | ❌ | ❌ | ❌ | ✅ (view own hours) | ✅ (manage schedules) |
| Incident Reporting | ✅ (can be anonymous) | ✅ | ❌ | ✅ (submit digitally) | ✅ (review) |
| Monitoring & Alerts Dashboard | ❌ | ❌ | ❌ | ✅ (gate alerts) | ✅ (full access) |

## 10. Assumptions

- All students/staff are issued valid ID cards with QR/RFID codes.
- Visitors agree to register at the gate and carry temporary passes.
- The university provides reliable internet/Wi-Fi at gates and admin offices.
- Security guards are trained to use basic computer/tablet systems.

## 11. Business Constraints

- **Budget:** Fixed budget rules out expensive, high-end hardware/software.
- **Policy Compliance:** Must comply with university rules, data privacy regulations, and government safety guidelines.
- **Time:** Implementation targeted within an academic year, avoiding disruption during admissions/exams.
- **Training:** Guard and admin staff training must stay simple and low-cost.
