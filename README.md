# Application Performance Monitoring Tool (APM)

## Overview

This project implements a Bash-based Application Performance Monitoring (APM) tool that monitors system and process-level performance metrics for six applications (APM1–APM6).

The tool collects:

* CPU and memory usage per process
* Network bandwidth (RX/TX)
* Disk write activity
* Available disk space

All metrics are recorded into CSV files for further analysis and visualization.

---

## Tools Used

* ps (process CPU and memory usage)
* ifstat (network bandwidth monitoring)
* iostat (disk write monitoring)
* df (disk space monitoring)

---

## How to Run

### 1. Clone the repository

```
git clone https://github.com/YOUR-USERNAME/APM-Tool.git
cd APM-Tool
```

### 2. Give execute permissions

```
chmod +x apm_tool.sh
chmod +x APM*
```

### 3. Configure the script

Open the script:

```
nano apm_tool.sh
```

Update the following variables:

* IP address (your system's real IP, NOT 127.0.0.1)
* Network interface (e.g., ens33, ens160)
* Disk name (e.g., sda)

---

### 4. Run the tool

```
./apm_tool.sh
```

---

### 5. Let it run

* Run for **15 minutes**
* Do NOT auto-stop the script

---

### 6. Stop the tool manually

```
Ctrl + C
```

---

## Output Files

After execution, the following files are generated:

### Process Metrics (6 files)

```
APM1_metrics.csv
APM2_metrics.csv
APM3_metrics.csv
APM4_metrics.csv
APM5_metrics.csv
APM6_metrics.csv
```

Each file format:

```
<time in seconds>, <CPU %>, <Memory %>
```

---

### System Metrics (1 file)

```
system_metrics.csv
```

File format:

```
<time>, <RX data rate>, <TX data rate>, <disk writes>, <available disk space>
```

---

## How to Visualize Data

1. Open Excel (or Google Sheets)
2. Import CSV files
3. Use **Scatter Plot (with lines)**

### Recommended graphs:

* CPU vs Time (for each APM1–APM6)
* Network RX/TX vs Time
* Disk writes vs Time
* Disk space vs Time

---

## Features

* Collects metrics every 5 seconds
* Uses real-time system monitoring tools
* Logs structured CSV output
* Includes cleanup function to terminate all spawned processes

---

## Project Structure

```
apm_tool.sh
APM1_metrics.csv
APM2_metrics.csv
APM3_metrics.csv
APM4_metrics.csv
APM5_metrics.csv
APM6_metrics.csv
system_metrics.csv
report.docx
```

---

## 👤 Author

Anuj Agrawal
Elvis Lin
Jeliel Brown
