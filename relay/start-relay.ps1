$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
python .\lookscope_relay.py
