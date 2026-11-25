# Linux Admin Automation Toolkit

A Bash-based Linux system administration utility built and tested in a home lab. It collects baseline diagnostics, checks resource thresholds, and returns a machine-readable status code.

## Features

- CPU core count and load averages
- Memory summary and utilization estimate based on `MemAvailable`
- Filesystem capacity report
- Failed systemd unit check
- Network interface and routing inspection
- Gateway and external IP reachability tests
- DNS resolution check
- Disk and memory threshold warnings
- Timestamped report files and execution log
- Portable launcher
- Threshold and exit-code simulation scripts

## Environment and dependencies

- Debian/Linux with Bash
- `systemd`, `iproute2`, `ping`, `awk`, `df`, `free`, `getent`, `tee`

## Thresholds

| Utilization | Status |
|---|---|
| Below 80% | OK |
| 80–89% | WARNING |
| 90% and above | CRITICAL |

The overall exit code currently evaluates **root filesystem utilization and memory utilization**:

| Exit code | Meaning |
|---:|---|
| 0 | Healthy |
| 1 | Warning |
| 2 | Critical |

These are project-defined codes and thresholds, not universal monitoring standards. Service and connectivity checks are reported but not included in the overall status calculation yet.

## Quick start

```bash
chmod +x admin-toolkit scripts/health_check.sh tests/*.sh
./admin-toolkit
```

The launcher can also be invoked from elsewhere by its absolute path.

## Output

The toolkit creates `logs/health_check.log` and timestamped reports under `reports/`. These runtime files are excluded from version control by `.gitignore`.

## Tests

Run the simulated threshold tests:

```bash
./tests/threshold_test.sh
```

Test a single utilization and inspect its exit code:

```bash
./tests/status_test.sh 65; echo $?
./tests/status_test.sh 85; echo $?
./tests/status_test.sh 95; echo $?
```

Test overall status combinations:

```bash
./tests/overall_status_test.sh 65 70; echo $?
./tests/overall_status_test.sh 85 70; echo $?
./tests/overall_status_test.sh 65 85; echo $?
./tests/overall_status_test.sh 95 70; echo $?
./tests/overall_status_test.sh 65 95; echo $?
```

## Limitations and next steps

- Overall status currently considers only root filesystem and memory.
- CPU load averages are not CPU utilization percentages.
- Disk monitoring does not yet check inode exhaustion.
- Memory percentage is a simplified estimate; production monitoring should also consider swap behavior, pressure, reclaimable cache, and workload-specific signals.
- Network reachability and DNS checks are informational, not full application/service checks.
- Thresholds are fixed in the script.
- No automated remediation or service restart is performed.

Potential future enhancements: configurable thresholds, inode checks, incorporating failed services/network checks into overall status, structured output (JSON), unit tests, and alert integration.

## Skills demonstrated

Linux CLI administration, Bash scripting, conditional logic, functions, process exit codes, input validation, systemd diagnostics, network troubleshooting, resource monitoring, logging, report generation, test simulations, and technical documentation.

## Project purpose

A practical home-lab exercise demonstrating repeatable Linux diagnostics, basic automation, testing, and documentation—not a production monitoring replacement.
