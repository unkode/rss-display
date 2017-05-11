while true
do
  clear
  echo "Getting lastest meteorological data..."	
  #echo -n -e "$(~/display/wego/wego -d 1)"
  echo -n -e "$(curl -s  -l "http://wttr.in/montreal?1&lang=fr&Q" | head -n -3 | 
  sed "s/             Matin            /          8h+ Matin           /g" |
  sed "s/          Après-midi   /     12h+ Après-midi   /g" |
  sed "s/      Soir            /   19h+ Soir          /g" |
  sed "s/             Nuit             /          23h+ Nuit           /g")"
  sleep 2520
done
