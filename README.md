# intern-tasks


# Mini Grep (mygrep.sh)

A Bash implementation of core grep functionality with case-insensitive search and option handling.

## Features
- Case-insensitive text search
- Line number display (`-n`)
- Inverted matching (`-v`)
- Combined flag support (`-nv`, `-vn`)
- Error handling for missing files/arguments

## Usage
```bash
./mygrep.sh [-n] [-v] search_string filename
```

## Implementation

### 1. Argument Handling
**Option Parsing:**
- Uses `case` statements to detect `-n`/`-v` flags
- Processes combined flags through pattern matching
- Stores options as "yes"/"no" strings

**Validation:**
- Requires exactly 2 non-option arguments
- Verifies file existence
- Provides clear error messages

**Execution:**
- First non-option → `search_term`
- Second non-option → `filename`

### 2. Future Enhancements
**Regex Support:**
- Replace `[[ "${line,,}" == *"${pattern,,}"* ]]` with `=~` operator
- Remove case conversion when using regex

**New Flags:**
```text
-i  Case sensitivity (new variable)
-c  Count matches (add counter)
-l  Filename-only output (modify print logic)
```
**Structural Changes:**
- Additional `case` branches
- Modified output handling
- Post-loop summary for counts

### 3. Development Challenges
**Main Difficulty:** Option combination logic  
**Why:** Ensuring `-vn`/`-nv`/`-v -n` behave identically

## Testing
**Basic Tests:**
```bash
./mygrep.sh hello testfile.txt
./mygrep.sh -n test testfile.txt
./mygrep.sh -vn hello testfile.txt
```
![Screenshot 2025-04-28 210156](https://github.com/user-attachments/assets/ec25bb86-94be-41dc-9b89-d38af7ede825)
# Troubleshooting Internal Dashboard (DNS/Network)

Diagnostic, analysis, and resolution of internal service (`internal.example.com`) DNS issues.

## Problem
- Users could not resolve `internal.example.com` (host not found error).
- Service was running but unreachable.

## Key Steps
- Verified DNS client configuration (`/etc/resolv.conf`, `resolvectl status`).
- Tested resolution via internal (`172.31.0.2`) and public (`8.8.8.8`) DNS.
- Confirmed NXDOMAIN (missing DNS record).
- Validated no network/firewall issues (port 53 UDP open).

## Conclusion
- **Root cause:** Missing internal DNS A record.
- **Fix:** Create a correct A record for `internal.example.com` on internal DNS server.
- **Bonus:** Suggested a temporary `/etc/hosts` entry for local testing if needed.

## Tools Used
- `dig`
- `nc`
- `ping`
- `curl`
- `resolvectl`


