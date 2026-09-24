# Linux and Asterisk command reference

Use this reference for development, diagnostics, service operation, network inspection, media verification, packaging, and controlled Asterisk CLI work on Linux hosts.

## Version

Commands target common systemd-based Linux distributions and Asterisk 16 through 24. Service names, paths, package managers, and firewall tools vary by distribution.

## Security

Run read-only commands first. Commands that reload, restart, stop, change firewall rules, change ownership, alter configuration, or originate calls require explicit authorization. Mask passwords, tokens, SIP Authorization headers, caller data, and private keys.

## Asterisk CLI

~~~bash
sudo asterisk -rx 'core show version'
sudo asterisk -rx 'core show uptime'
sudo asterisk -rx 'core show channels verbose'
sudo asterisk -rx 'module show'
sudo asterisk -rx 'module show like pjsip'
sudo asterisk -rx 'dialplan show from-internal'
sudo asterisk -rx 'core show applications'
sudo asterisk -rx 'core show functions'
sudo asterisk -rx 'pjsip show endpoints'
sudo asterisk -rx 'pjsip show registrations'
sudo asterisk -rx 'pjsip show contacts'
sudo asterisk -rx 'pjsip show transports'
sudo asterisk -rx 'queue show'
sudo asterisk -rx 'rtp show settings'
sudo asterisk -rx 'http show status'
~~~

Prefer targeted commands and record version, module, host, and UTC timestamp with the evidence.

## Service and log inspection

~~~bash
systemctl status asterisk --no-pager
systemctl is-active asterisk
systemctl is-enabled asterisk
journalctl -u asterisk --since '30 min ago' --no-pager
journalctl -u asterisk -p warning..alert --since today --no-pager
ps -eo pid,ppid,user,etime,cmd | grep '[a]sterisk'
~~~

Mutation commands such as systemctl restart, reload, stop, enable, or disable are operational actions and must not be inferred from a diagnostic request.

## Network and TLS diagnosis

~~~bash
ss -lntup
ss -lntp '( sport = :5038 or sport = :8088 or sport = :8089 )'
ip addr
ip route
ip -s link
resolvectl status
dig +short pbx.example.test
nc -vz -w 3 PBX_HOST 5038
curl --fail-with-body --max-time 5 http://127.0.0.1:8088/httpstatus
openssl s_client -connect PBX_HOST:8089 -servername PBX_HOST -brief
~~~

Replace placeholders with test values and redact topology when sharing output.

## SIP/RTP packet evidence

~~~bash
sudo tcpdump -ni any -s 0 -w /tmp/asterisk-call.pcap 'udp or tcp port 5060 or tcp port 5061'
sudo tcpdump -ni any -vv 'udp portrange 10000-20000'
sudo tshark -r /tmp/asterisk-call.pcap -Y 'sip || rtp' -T fields -e frame.time -e ip.src -e ip.dst -e udp.srcport -e udp.dstport
~~~

Packet captures contain sensitive data. Store them in an access-controlled temporary location and never publish raw captures.

## Files, recordings, and permissions

~~~bash
find /var/spool/asterisk -maxdepth 2 -type f -name '*.call' -printf '%TY-%Tm-%Td %TH:%TM:%TS %u %g %m %p\n'
find /var/spool/asterisk/monitor -type f -mmin -60 -print
file /var/spool/asterisk/monitor/RECORDING.wav
ffprobe -hide_banner /var/spool/asterisk/monitor/RECORDING.wav
namei -l /var/spool/asterisk/monitor/RECORDING.wav
df -h /var/spool/asterisk
df -i /var/spool/asterisk
du -xhd1 /var/spool/asterisk/monitor | sort -h
~~~

Do not expose recording paths or audio files to unauthorized users. Do not delete recordings or spool files as part of diagnosis.

## Configuration and safe validation

~~~bash
sudo asterisk -rx 'core show settings'
sudo asterisk -rx 'config show help'
sudo asterisk -rx 'pjsip show settings'
~~~

Reload commands mutate runtime state and require authorization. Validate the proposed file diff and rollback path before using them. Never edit generated FreePBX files directly.

## Process and resource diagnosis

~~~bash
pidof asterisk
cat /proc/ASTERISK_PID/limits
ls -l /proc/ASTERISK_PID/fd | wc -l
top -H -p ASTERISK_PID
vmstat 1 5
iostat -xz 1 5
free -h
ulimit -n
~~~

Use bounded sampling windows and avoid logging full command output when it contains environment or topology details.

## Package, archive, and transfer commands

~~~bash
apt-cache policy asterisk
dnf info asterisk
rpm -qa | grep -i asterisk
dpkg -l | grep -i asterisk
tar -czf asterisk-config-backup.tgz /etc/asterisk
sha256sum asterisk-config-backup.tgz
rsync -navi --delete ./staging/ user@host:/safe/target/
~~~

Package installation, archive transfer, rsync execution, and remote changes are mutations. A dry-run does not authorize the real operation, and remote transfer remains subject to explicit deploy authorization.

## Primary References

Official Asterisk CLI, configuration, operation, deployment, security, and Linux distribution documentation are authoritative.

## Verification

Run read-only command smoke checks on the target distribution, verify command exit status and timestamp, and classify unavailable tools separately from product defects. Never claim a service or call is healthy from command availability alone.

