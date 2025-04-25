# TMW Automated Build Scripts

This repository contains **three helper scripts** that automate a local build of the Tuner Middleware (TMW) components on an Ubuntu virtual machine.

| Script                           | Purpose                                                                                                                                            |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tmw_build_libtuner.sh`          | Downloads and builds the **libtuner** libraries.                                                                                                   |
| `tmw_install_aosp13.sh`          | Fetches a *fast* AOSP 13 tree (branch `android‑13.0.0_r82`) with minimal history using partial‑clone, then prepares the Android build environment. |
| `tmw_build_broadcastradiohal.sh` | Packages the BroadcastRadio HAL, vendor dependencies and build artefacts, then launches the component build.                                       |
| `tmw_repack_eso.sh`              | Re‑packs the ESO framework and copies the resulting artefacts into the expected exchange directories.                                              |

> **Supported TMW release:** `243.6` (newer releases have not yet been validated).

---

## When to use the scripts

The scripts collapse many manual steps described in the official guide into a single command sequence. They are most useful when you want to spin up a fresh VM and reach a working HAL/LibTuner build as quickly as possible.

*Full manual reference:* [https://devstack.vwgroup.com/confluence/display/C1INF/Howto+%3A+Build+tuner+middleware+locally](https://devstack.vwgroup.com/confluence/display/C1INF/Howto+%3A+Build+tuner+middleware+locally)

---

## Prerequisites

### 1 · Virtual Machine

1. Create an **Ubuntu 24.04 LTS** VM in **VirtualBox** (or VMware/Hyper‑V).
2. **Network adapter → Bridged Adapter** (“Netzwerkbrücke”) so the guest bypasses the host VPN.
3. First boot into Ubuntu.

### 2 · SSH file transfer

On the Ubuntu guest install OpenSSH and copy the three scripts from Windows:

```bash
sudo apt update && sudo apt install openssh-server
# from Windows (PowerShell):
scp -P <port> tmw_build_libtuner.sh ubuntu@<guest-ip>:/home/ubuntu/
scp ...                               # repeat for all scripts
```



---

## Quick‑start (Ubuntu terminal)

1. **Build libtuner**

   ```bash
   chmod +x tmw_build_libtuner.sh
   ./tmw_build_libtuner.sh
   ```

2. **Fetch & install AOSP 13**

   ```bash
   chmod +x tmw_install_aosp13.sh
   ./tmw_install_aosp13.sh
   ```

   *If the script stops with “Please tell me who you are”:*

   ```bash
   git config --global user.name  "USERNAME"
   git config --global user.email "USERNAME@example.com"
   ./tmw_install_aosp13.sh       # restart
   ```

   *ERRORS WHILE INSTALLING?* Close Outlook / Teams and insert the PKI smart‑cards, then re‑run.

3. **Re‑pack ESO framework**

   ```bash
   chmod +x tmw_repack_eso.sh
   ./tmw_repack_eso.sh
   ```

4. **Build BroadcastRadio HAL**

   ```bash
   chmod +x tmw_build_broadcastradiohal.sh
   ./tmw_build_broadcastradiohal.sh
   ```

When the final script prints **“computed build environment”**, the HAL build is complete.

---

## Troubleshooting

| Issue                                    | Hint                                                                     |
| ---------------------------------------- | ------------------------------------------------------------------------ |
| AOSP cannot download correctly?          | shutdown your teams/outlook, insert the pki card, try to restart the vpn |
| Build interrupted by Git identity prompt | Configure name/email as shown above and re‑run the script.               |
| “Cannot checkout …” during AOSP sync     | Delete the failing repo directory and restart `tmw_install_aosp13.sh`.   |

---

## License

Internal VW Group use only.


