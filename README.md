<<<<<<< HEAD
# L3V3L3_BUG4TH0N
=======
# BUGATHON 2026 — Level 3

## Behind the Application

**Difficulty:** Intermediate/Advanced  
**Primary Skill:** File-Handling Weaknesses, LFI, SSTI, RCE

---

## Scenario

The investigation reveals that the application connects to other internal services and accepts user-controlled content. Forensic records show commands were executed on the server even though there is no evidence of an administrator logging in.

Your job is to exploit the application's file-handling weakness and obtain controlled low-privileged access.

This challenge focuses on how seemingly minor configuration issues and input validation failures can be chained together.

---

## Your Mission

Starting from the logistics portal, investigate the application and:

- Enumerate the application's endpoints and features.
- Identify the Local File Inclusion (LFI) vulnerability.
- Exploit the LFI to read the application's source code.
- Analyze the source code for file upload mechanisms and weaknesses.
- Bypass the upload filters to perform an arbitrary file write.
- Leverage the arbitrary file write to overwrite a vulnerable template.
- Execute a Server-Side Template Injection (SSTI) payload.
- Gain Remote Code Execution (RCE) on the server.
- Recover the final checkpoint flag from the server's filesystem.

There are multiple checkpoints throughout the level. Pay close attention to error messages, HTTP headers, and the application's responses.
>>>>>>> 0d8a3e9 (hello)
