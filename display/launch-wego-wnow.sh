while true
do
  clear
  echo -e "Dernière mise-à-jour:\r\n   $(date +%Y-%m-%d\ %H:%M:%S)\r\nMétéo actuelle:\r\n"
  #echo -e "$(~/display/wego/wego -d 0 | grep -v "Weather for")"
  echo -e "$(curl -s  -l "http://wttr.in/montreal?0&lang=fr&Q")"
  echo -e -n "  ──────────────────────────"
  sleep 1200
done

