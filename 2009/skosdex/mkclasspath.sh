for thing in ./lib/*
do
    if [ -f $thing ]; then
        CP="${CP}:$thing"
    else if [ -d $thing ]; then

        CP="$CP:$PWD/$thing"
     fi
    fi
done
CP="$CP:."

echo export CLASSPATH=$CP
