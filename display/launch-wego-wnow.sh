while true
do
  clear
  echo -e "Last update:\r\n   $(date +%Y-%m-%d\ %H:%M:%S)\r\nCurrent weather:"
  echo -e "$(~/display/wego/wego -d 0 | grep -v "Weather for")"
  echo -e -n "  ──────────────────────────"
  sleep 1500
done

