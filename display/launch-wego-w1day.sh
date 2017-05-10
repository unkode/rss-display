while true
do
  clear
  echo "Getting lastest meteorological data..."	
  #echo -n -e "$(~/display/wego/wego -d 1)"
  echo -n -e "$(curl -s  -l "http://wttr.in/montreal?1&lang=fr&Q" | head -n -3)"
  sleep 2520
done
