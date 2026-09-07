BUGATHON 2026
LEVEL 3 — BEHIND THE APPLICATION

FINAL ORGANIZER DOCUMENTATION
LOGISTICS-PORTAL BUILD

CONFIDENTIAL — ORGANIZERS / HEADS ONLY

1. Version / Submission Scope
This document is specifically for the logistics-portal Level 3 build that is intended for final submission. It represents the transition from external web exploitation to internal system access. 
The investigation is server-side and requires the participant to chain a file-read vulnerability into an arbitrary file write and template injection.

2. Challenge Overview
Level 3 continues from the Level 2 handoff (G. Fring — Los Pollos Hermanos Logistics / LOT-74B-SUPERLAB). The intended chain is: discover the hidden logistics portal → trigger a verbose error to find an LFI vulnerability → use LFI to recover source code and configuration → analyze the file upload filter → bypass the path traversal filter to perform an arbitrary file write → overwrite a Jinja2 template with an SSTI payload → access the rendered template to gain RCE → obtain the final Level 3 checkpoint and Level 4 handoff.

Primary skills: Local File Inclusion (LFI), Source Code Review, Filter Bypass, Server-Side Template Injection (SSTI), Remote Code Execution (RCE). 
Difficulty: approximately 4/5 (Intermediate/Advanced). The challenge is intended to feel like a white-box code review and exploit chain.

3. Intended Player Flow
1. Access the /logistics portal on port 5000 (or assigned port).
2. Inspect the HTTP response headers to find FLAG3_01.
3. Interact with the file download feature (/download?document=manifest.txt).
4. Trigger a verbose error by requesting a non-existent file to find FLAG3_02.
5. Identify the LFI vulnerability in the document parameter.
6. Exploit the LFI to read app.py (e.g., /download?document=../app.py) to find FLAG3_03 (in the config) and FLAG3_04 (in the source code comment).
7. Analyze app.py to understand the /upload_report endpoint and its basic filter (../).
8. Trigger the basic filter block message to get FLAG3_05.
9. Bypass the filter using ....// or similar to write a file outside the uploads/ directory.
10. Overwrite the test.txt file in the application root to trigger a specific success message containing FLAG3_06.
11. Construct an SSTI payload and upload it, bypassing the filter to overwrite templates/maintenance.html.
12. Access /maintenance to execute the SSTI payload.
13. Extract FLAG3_07 from the application's environment variables via the SSTI execution.
14. Use the SSTI RCE to read the final FLAG3_08 from /home/l3app/flag.txt and discover the Level 4 handoff.

4. Organizer Credentials
| Purpose | Username | Password |
|---|---|---|
| Application Execution Role | l3app | N/A (Service Account) |
| Simulated API Key | N/A | FLAG3_03{c0nf1g_r34d_v14_lf1} |

5. Flag / Checkpoint Answer Sheet
| Checkpoint | Flag | Location | Discovery |
|---|---|---|---|
| FLAG3_01 | FLAG3_01{h1dd3n_l0g1st1cs_p0rt4l} | HTTP Response Header X-LPH-Logistics-ID | Found by inspecting the headers on the main portal page. |
| FLAG3_02 | FLAG3_02{v3rb0s3_3rr0r_d1scl0sur3} | Verbose error message | Triggered by requesting a missing document via the download endpoint. |
| FLAG3_03 | FLAG3_03{c0nf1g_r34d_v14_lf1} | config.json | Read using the LFI vulnerability in the download endpoint. |
| FLAG3_04 | FLAG3_04{s0urc3_c0d3_r3v34l3d} | app.py source code | Read using the LFI vulnerability. Found as a comment in the code. |
| FLAG3_05 | FLAG3_05{b4s1c_f1lt3r_tr1gg3r3d} | WAF block message | Returned when attempting a basic ../ traversal in the upload filename. |
| FLAG3_06 | FLAG3_06{4rb1tr4ry_f1l3_wr1t3_c0nf1rm3d} | Upload success message | Returned when successfully overwriting test.txt in the app root using filter bypass. |
| FLAG3_07 | FLAG3_07{sst1_r3c0v3ry_v14_3nv} | Environment variables | Recovered by executing an SSTI payload (e.g., {{ self.__init__.__globals__.__builtins__.__import__('os').environ }}). |
| FLAG3_08 | FLAG3_08{l0w_pr1v_sh3ll_4ch13v3d} | /home/l3app/flag.txt | Recovered using the SSTI RCE to read the file from the user's home directory. |

6. Arbitrary File Write / SSTI Mechanic
The arbitrary file write is possible because the application weakly filters ../ but uses os.path.join() with user-controlled input. Normalizing ....// yields ../, allowing the user to escape the uploads/ directory. The templates/ directory is intentionally made writable by the l3app user, allowing the attacker to replace the maintenance.html template with one containing Jinja2 execution payloads.

7. Infrastructure
- Level 3 service: level3-logistics.service
- Application: webapp/app.py
- Runtime user: l3app
- Web Framework: Python Flask (Port 5000)
- The templates/ directory is chowned to l3app to permit the required overwrite.

8. Deployment / Verification
Expected deployment:
sudo bash deploy.sh
sudo ./verify_level3.sh

Expected verification result: Level 3 verification: PASS.
IMPORTANT FINAL-PACKAGE CHECK: The verification script ensures that the templates/ directory is writable by l3app. If the script fails, ensure that chown -R l3app:l3app /var/www/level3-logistics/templates was successfully executed.

9. Participant-Facing Documentation
- README.md and LEVEL3_PLAYER.md should remain spoiler-free.
- Do not distribute flags, exact SSTI payloads, or the complete solve path.
- Do not expose organizer-only documents or secrets.

10. Publication / Repository Security
Keep this organizer document private. The deploy.sh script contains challenge flags and secrets. Use a private organizer/deployment repository or restrict access.

11. Level 4 Handoff
The low-privileged shell achieved at the end of Level 3 hands off to Level 4 (Privilege Escalation / Lateral Movement) with:
- Access Context: Low-privileged execution as user `l3app` on the logistics server.
- Found Evidence: A reference in the `l3app` environment pointing to the Superlab Industrial Control Systems.
- Reference: PROJECT-METHYLAMINE / V-W-GALE-01

12. Quick Organizer Reference
| Start | Level 2 Handoff (LOT-74B-SUPERLAB) |
|---|---|
| Target Service | Logistics Portal (Port 5000) |
| Initial Vulnerability | LFI via /download?document= |
| Key Code Discovered | app.py and config.json |
| Upload Filter Bypass | ....// |
| Template Overwrite Target | ../templates/maintenance.html |
| Execution Trigger | /maintenance |
| Final Account | l3app |
| Final Handoff | PROJECT-METHYLAMINE / V-W-GALE-01 |

13. Final Submission Checklist
- Use the logistics-portal build as the submitted Level 3 build.
- Deploy the package on the target Ubuntu environment.
- Run sudo ./verify_level3.sh and confirm Level 3 verification: PASS.
- Keep this document and organizer secrets private.
- Ensure participant-facing README material does not reveal flags or payloads.
