# Research Activity 4: Socket-based Distribution of Matrix Data

**Author:** Jakie Ashley C. Brabante  
**Section:** CD-1L  
**Lab Problem:** 4  

## Description  
This program implements a **master-slave architecture** using **TCP sockets** to distribute rows of an `n × n` matrix across multiple slave threads. Each slave receives its assigned submatrix from the master, with data transmission handled over the network via socket connections. Threads may optionally be **core-affined** using `pthread_setaffinity_np()` to measure the impact of CPU core binding on runtime performance.

This activity demonstrates the use of **POSIX threads**, **core affinity**, and **network communication** to simulate distributed matrix processing.

## Programming Language  
- C

## Dependencies  
- Standard Libraries: `math.h`, `time.h`, `stdlib.h`, `stdio.h`, `stdbool.h`, `errno.h`  
- Networking: `sys/socket.h`, `netinet/in.h`, `arpa/inet.h`, `unistd.h`  
- Threading & Core Affinity: `pthread.h`, `sched.h`  
- Compiler must support GNU extensions (`#define _GNU_SOURCE`)

## Folder Structure
```
root/
├── a.out
├── Makefile
├── BRABANTE_JA_code.c
├── README.md
├── droneconfig/ # Stores actual config files with drone IPs
│ └── config_<T>.cfg
├── localconfig/ # Stores config files for local/localhost testing
│ └── config_<T>.cfg
├── util/ # Contains helper scripts and IP list
│ ├── generate_configs.sh
│ ├── execute_runs.sh
│ └── ip_list.txt
```

## Source Code  
- Filename: `BRABANTE_JA_code.c`

## How to Run the Program  

### **Using the Makefile**  
Type one of the following commands in the terminal:

- **`make`**  
  Compiles the program into an executable named `a.out`.

- **`make generate`**  
  Runs `util/generate_configs.sh` which:
  - Reads `ip_list.txt` to build config files
  - Creates `config_T.cfg` for each `T` (2, 4, 8, 16) inside `droneconfig/`

- **`make execute`**  
  Runs `util/execute_runs.sh`, which:
  - Launches `T` slave terminals followed by the master
  - Assigns different ports to each thread
  - Uses the corresponding config file from either `droneconfig/` or `localconfig/`

- **`make clean`**  
  Deletes the compiled output file `a.out`.

### **Using the Bash Script (`execute_runs.sh`)**  
Inside `util/execute_runs.sh`, you can configure:
- `N`: matrix size (e.g., 25000)
- `T`: number of slave threads (e.g., 2, 4, 8)
- `C`: core affinity flag (`0` = disabled, `1` = enabled)
- `BASE_PORT`: port to begin assigning from (e.g., 28030)

The script opens one terminal per slave and finally runs the master.

> Requires `gnome-terminal` to be installed on your system.


## Output  
- **Terminal**: Shows process logs, connection status, and matrix send/receive debug info.
- **Files (Saved inside `../util/`)**:
  - `Exer4Results.tsv`: raw runtime log for data analysis
  - `Exer4Results_pretty.txt`: human-readable formatted table of results

## Special Mode
If `n == 15`, the program uses **dummy matrix data** for easier visual validation.  
All data sent and received will be printed for debugging purposes.

## Notes
- Ensure config files (`config_<T>.cfg`) are generated via `make generate` **before** running `make execute`.
- All drones (or localhost instances) listed in `ip_list.txt` must be accessible via SSH and network.