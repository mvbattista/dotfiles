# Shared by sync.sh (pull, scan) and hooks/pre-commit. Sourced, not executed.
# CRED_RE: credentials; refused in every layer, public or private.
CRED_RE='AKIA[0-9A-Z]{16}|gh[pou]_[A-Za-z0-9]{20,}|github_pat_|xox[baprs]-|-----BEGIN [A-Z ]*PRIVATE KEY|[A-Za-z_]*(TOKEN|_KEY|SECRET)[A-Za-z_]*=[^ ]|[Pp]assword *=|https?://[^/ ]*:[^@ ]+@'
# PUBLIC_RE: machine and internal details; refused everywhere except the private work layer.
PUBLIC_RE='([0-9]{1,3}\.){3}[0-9]{1,3}|/Users/[A-Za-z0-9._-]+'
