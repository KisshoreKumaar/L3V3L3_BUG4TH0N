# BUGATHON 2026 — Level 3 (Behind the Application)

## MISSION
The investigation reveals that the application connects to other internal services and accepts user-controlled content. Forensic records show commands were executed on the server even though there is no evidence of an administrator logging in.

Your objective is to exploit the application's file-handling weaknesses to chain together multiple vulnerabilities, ultimately gaining Server-Side Template Injection (SSTI) and obtaining controlled low-privileged execution on the server.

---

## ALL THE FLAGS

| Checkpoint | Flag | Discovery |
|---|---|---|
| **FLAG3_01** | `FLAG3_01{h1dd3n_l0g1st1cs_p0rt4l}` | Found by inspecting the HTTP response headers on the main portal page (`X-LPH-Logistics-ID`). |
| **FLAG3_02** | `FLAG3_02{v3rb0s3_3rr0r_d1scl0sur3}` | Triggered by requesting a non-existent document via the download endpoint. |
| **FLAG3_03** | `FLAG3_03{c0nf1g_r34d_v14_lf1}` | Read from `config.json` using the Local File Inclusion (LFI) vulnerability. |
| **FLAG3_04** | `FLAG3_04{s0urc3_c0d3_r3v34l3d}` | Read from `app.py` source code using the LFI vulnerability. Found as a comment. |
| **FLAG3_05** | `FLAG3_05{b4s1c_f1lt3r_tr1gg3r3d}` | Returned in a WAF block message when attempting a basic `../` traversal in the upload filename. |
| **FLAG3_06** | `FLAG3_06{4rb1tr4ry_f1l3_wr1t3_c0nf1rm3d}` | Returned when successfully overwriting `test.txt` in the app root using filter bypass. |
| **FLAG3_07** | `FLAG3_07{sst1_r3c0v3ry_v14_3nv}` | Recovered by executing an SSTI payload to read the application's environment variables. |
| **FLAG3_08** | `FLAG3_08{l0w_pr1v_sh3ll_4ch13v3d}` | The final flag, recovered using the SSTI RCE to read `/home/l3app/flag.txt`. |

---

## HINTS
<details>
<summary>Hint 1: Reconnaissance</summary>
Always check the HTTP response headers on new endpoints. The developers might have left debugging headers behind.
</details>
<details>
<summary>Hint 2: Error Handling</summary>
The download endpoint doesn't seem to validate files properly. What happens if you request a file that doesn't exist? What if you use path traversal characters?
</details>
<details>
<summary>Hint 3: Code Review</summary>
Use the file read vulnerability to retrieve the application's source code (`app.py`). It will reveal exactly how the upload filter works.
</details>
<details>
<summary>Hint 4: Filter Bypass</summary>
The upload filter prevents `../`, but how does it sanitize the string? What happens if you nest traversal characters like `....//`?
</details>
<details>
<summary>Hint 5: Escalation</summary>
You can write files anywhere the application has permissions. Is there an existing HTML template you could overwrite with a malicious Jinja2 payload?
</details>

---

## STEP-BY-STEP SOLVE

> ⚠️ **SPOILER WARNING**: The complete intended solve path is detailed below.

### 1. Initial Recon & Information Disclosure
- Navigate to the portal `http://<TARGET_IP>:5000/`.
- Inspect the HTTP response headers (using Burp Suite, DevTools, or `curl -I`). You will find `X-LPH-Logistics-ID: FLAG3_01{h1dd3n_l0g1st1cs_p0rt4l}`.

### 2. Local File Inclusion (LFI)
- Interact with the "Download Document" feature which points to `/download?document=manifest.txt`.
- Request a missing file (e.g., `/download?document=doesnotexist.txt`) to trigger an error and reveal **FLAG3_02**.
- Exploit the LFI by requesting `/download?document=config.json` to recover the API key and **FLAG3_03**.
- Request `/download?document=app.py` to download the application's source code. Inside the source code comments, you will find **FLAG3_04**.

### 3. File Upload Filter Bypass
- Analyze `app.py` to understand the `/upload_report` endpoint. You'll see it checks for `../` in the filename.
- Submit a POST request to `/upload_report` with the filename `../test.txt`. The application will block it and return **FLAG3_05**.
- Look closely at the sanitization logic in the source code: `filename = filename.replace('....//', '../')`.
- Bypass the filter by submitting a filename like `....//test.txt`. The application will replace `....//` with `../`, performing a path traversal and successfully overwriting the test file, returning **FLAG3_06**.

### 4. Server-Side Template Injection (SSTI) & RCE
- The application serves a system status page at `/maintenance`, rendered from `templates/maintenance.html`.
- Create a file containing a Jinja2 Server-Side Template Injection payload to read environment variables (e.g., `{{ self.__init__.__globals__.__builtins__.__import__('os').environ }}`).
- Upload this file using the bypass trick with the filename: `....//templates/maintenance.html`. This overwrites the legitimate template.
- Navigate to `/maintenance`. The template will execute your payload, dumping the environment variables to the screen and revealing **FLAG3_07**.
- Update your SSTI payload to execute system commands (e.g., `{{ self.__init__.__globals__.__builtins__.__import__('os').popen('cat /home/l3app/flag.txt').read() }}`) and overwrite the template again.
- Navigate to `/maintenance` one last time to execute the command and retrieve the final checkpoint, **FLAG3_08**. This completes Level 3.
