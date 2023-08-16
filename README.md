# project-templates
Programming language project templates for different usage scenarios.

## Download kickstart binary
This section shows how to download kickstart binaries via the CLI.
Alternatively if you don't trust this approach, you can download release binary from [releases page](https://github.com/Keats/kickstart/releases).

### Linux and macOS
Automatically detects the platform (Linux or Darwin) and downloads the latest version of the kickstart binary to the current directory.
```bash
curl -sSf https://raw.githubusercontent.com/yezhengkai/project-templates/main/scripts/download-kickstart.sh | bash
```
Download the kickstart binary for the specific platform (Linux, Darwin, or Windows) and version to the current directory.
```bash
curl -sSf https://raw.githubusercontent.com/yezhengkai/project-templates/main/scripts/download-kickstart.sh | bash -s -- -p windows -v v0.4.0
```

### Windows
Download the latest version of the kickstart binary for Windows to the current directory.
```powershell
# https://www.reddit.com/r/PowerShell/comments/10r5fds/how_to_run_powershell_scripts_directly_from/
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/yezhengkai/project-templates/main/scripts/download-kickstart.sh) }"
```
Download the kickstart binary for the specific platform (Linux, Darwin, or Windows) and version to the current directory.
```powershell
# ref: https://www.reddit.com/r/PowerShell/comments/10r5fds/how_to_run_powershell_scripts_directly_from/
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/yezhengkai/project-templates/main/scripts/download-kickstart.sh) } -platform linux -version v0.4.0"
```