# Troubleshooting Internal Web Dashboard Connectivity


## 1. Problem Statement
Users report that `internal.example.com` is unreachable from multiple systems, showing a "host not found" error. The web service itself seems operational, so we suspect a DNS or network misconfiguration.

Objective: Diagnose, verify, and restore connectivity to the internal service.

---

## 2. Step-by-Step Troubleshooting

### 2.1 Verify DNS Resolution

- Check current DNS servers configured:
```bash
cat /etc/resolv.conf
```
![Screenshot 2025-04-28 223347](https://github.com/user-attachments/assets/2b648511-e5c4-4344-8c25-6b0cf9a7cbb9)
This mean system uses a local DNS resolver (systemd-resolved) instead of direct DNS servers. We must check upstream servers.
- Check Upstream DNS Servers:
```bash
resolvectl status
```

![Screenshot 2025-04-28 224135](https://github.com/user-attachments/assets/e12fa9aa-7e23-4438-aa25-376076360c4e)

Result:
The server is using systemd-resolved.

The real upstream DNS server being used is 172.31.0.2.

Any DNS queries will be forwarded to 172.31.0.2 for resolution.

DNS requests for internal.example.com will be handled by 172.31.0.2, so any DNS troubleshooting must check this server.


- Test DNS resolution using system DNS:
```bash
dig @172.31.0.2 internal.example.com
```
![Screenshot 2025-04-28 224753](https://github.com/user-attachments/assets/0cc3073b-f75e-4a1e-925d-9558c7e8404d)
Result:

The DNS query to 172.31.0.2 did not return an IP address for internal.example.com.

Status: NXDOMAIN means "Non-Existent Domain" — the DNS server does not know about internal.example.com.

This is a DNS-level problem, not a network or application problem.

Therefore, users are seeing "host not found" errors because the name cannot even be resolved to an IP




- Test DNS resolution using Google Public DNS:
```bash
dig @8.8.8.8 internal.example.com
```
![Screenshot 2025-04-28 225452](https://github.com/user-attachments/assets/fe526c0b-7305-4de3-8e88-2cb48554a177)

Result:

The query to Google DNS also returns NXDOMAIN (Non-Existent Domain).

This confirms that internal.example.com is not publicly available and must exist only in internal/private DNS zones.

Therefore, the problem is related to internal DNS configuration — missing or incorrect internal records.

### 2.2 Diagnose Service Reachability

- However we don't know the ip but we will simulate  if the server was reachable directly :
```bash
ping internal.example.com
```

- Check service availability on HTTP (port 80) or HTTPS (port 443):
```bash
nc -vz internal.example.com 80
curl -I http://internal.example.com
```
![Screenshot 2025-04-28 231032](https://github.com/user-attachments/assets/835743a7-63a3-4edb-8d5c-0d07ce8459b9)


> **Result**:
All service reachability tests failed before even attempting a network connection.

Root cause confirmed: DNS resolution failure.
No IP address could be obtained for internal.example.com, so connection attempts cannot proceed.




---

## 3. Trace the Issue – Possible Causes
After verifying DNS resolution failure and unsuccessful network tests, the following potential causes are identified:

3.1 Missing DNS Record
internal.example.com may not have an A (IPv4) or AAAA (IPv6) record configured on the internal DNS server.

3.2 Incorrect DNS Server Configuration
The local system might be configured with the wrong internal DNS server IP, or the upstream server itself is not correct.

3.3 Internal DNS Server Misconfiguration
The DNS server 172.31.0.2 might be misconfigured, missing the correct zones, or experiencing service issues.

3.4 DNS Propagation Delay
If recent changes were made to DNS records, it may take some time to propagate fully across servers.

3.5 Firewall or Security Group Rules
Firewalls or cloud security groups (AWS, Azure, etc.) might block DNS (port 53 UDP/TCP) traffic.

3.6 Network Routing Issues
Routing issues could prevent the client from properly reaching internal resources even if DNS resolves later.



---

## 4. Proposed and Applied Fixes

### Cause 1: Missing DNS Record

```bash
dig @172.31.0.2 internal.example.com
```
![Screenshot 2025-04-28 232346](https://github.com/user-attachments/assets/19aa5ef5-c8fa-45b3-91a7-d9d6577dc0b9)
How to Fix:

Access the DNS server admin console.

Create a new A record:

Name: internal.example.com

IP Address: Ip



- Incorrect DNS Server Configuration:
  
```bash
cat /etc/resolv.conf
resolvectl status
```
![Screenshot 2025-04-28 232848](https://github.com/user-attachments/assets/f80614e0-6b6c-4298-9fd0-2df9dbe8527b)

![Screenshot 2025-04-28 233047](https://github.com/user-attachments/assets/cbd00785-f886-4b69-b26e-538d779dca73)
Result:
The local resolver is configured correctly.

The upstream DNS server (172.31.0.2) is the one responsible for failing to resolve internal.example.com.

No changes are needed to /etc/resolv.conf or systemd-resolved settings at this point.


- Firewall or Security Group Rules:
  ![Screenshot 2025-04-28 234132](https://github.com/user-attachments/assets/5c7ae4b0-f6d0-48e1-a85d-65e08286df82)

  Result:
    There are no firewall or security group issues blocking DNS traffic.

    The issue is 100% not network-related, but only a DNS record missing problem.






---

## 6. Conclusion:
After thorough troubleshooting, we confirmed that the root cause of the internal.example.com unreachability was DNS resolution failure. The internal DNS server (172.31.0.2) did not have a valid A record for the domain, resulting in NXDOMAIN responses.

We verified:

Verified /etc/resolv.conf points correctly.

Verified upstream DNS (172.31.0.2) reachable over UDP port 53.

Confirmed DNS record missing (NXDOMAIN).

No firewall, routing, or service port issues.

Public DNS (8.8.8.8) confirms the domain is internal-only.

