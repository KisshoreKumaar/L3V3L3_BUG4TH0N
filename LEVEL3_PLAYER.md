# BUGATHON 2026 — Level 3

## Behind the Application

Welcome to Level 3.

**Scenario:** The forensic timeline records commands being executed on the server, yet there is no evidence that an administrator ever authenticated to the host. The application routinely accepts user-controlled content and stores it somewhere on the same system.

**Objective:** Exploit the application's file-handling weakness and obtain controlled low-privileged access.

**Expected Progression:**
Application Enumeration -> User-Controlled Content -> Server-Side Weakness -> Controlled Execution -> Low-Privileged Access -> FLAG 3

**Attack Surfaces:**
File upload, File validation, MIME validation, Filename handling, Upload location, Server-side execution, Path traversal, Application configuration, Debug functionality, Exposed credentials, Writable application files.

**Hint:**
"The forensic timeline records commands being executed on the server, yet there is no evidence that an administrator ever authenticated to the host. The application routinely accepts user-controlled content and stores it somewhere on the same system."
