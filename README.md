# WSL → PhpStorm Xdebug Setup (Windows Hosts Update)

This project includes the **update-hosts-win.ps1** script, which allows Xdebug running in WSL to connect to PhpStorm on Windows.

---

## 📌 Prerequisites

1. **PowerShell** with Administrator privileges on Windows.
2. **WSL2** installed, with your PHP project running in WSL.
3. **PhpStorm** configured with Xdebug.

---

## ⚡ Running `update-hosts-win.ps1`

1. **Open PowerShell as Administrator**
    - Press Windows key → search for "PowerShell" → Right-click → Run as Administrator

2. **Navigate to the script directory**
   ```powershell
   cd C:\path\to\project
   ```

3. **Run the script**
   ```powershell
   .\update-hosts-win.ps1
   ```

4. **Outcome**
    - Detects your Windows IP and updates the `hosts` file.
    - Adds the following entries:
      ```
      host.docker.internal
      gateway.docker.internal
      kubernetes.docker.internal
      ```

---

## 🔧 How It Works

- The script:
    - Creates a **backup** of the current hosts file.
    - Removes old entries related to `host.docker.internal` and `gateway.docker.internal`.
    - Automatically detects your Windows IP and inserts it into the hosts file.
    - Cleans up extra blank lines to keep the file tidy.

- If the script cannot modify the hosts file, you will see:
  ```
  ERROR: Cannot write to HOSTS file or create backup. Run PowerShell as Administrator.
  ```

---

## ✅ Important Notes

- Always **backup your hosts file** before running the script.
- After execution, Xdebug in WSL should be able to connect to PhpStorm on Windows.
- If the Windows IP cannot be detected automatically, you can specify it manually:
  ```powershell
  .\update-hosts-win.ps1 -ManualIP <ip>
  ```
