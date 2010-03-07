What is this?

A subset of OpenStreetMap data, exported for central/southern Amsterdam area.  Idea is to take the streets and match them to Wikipedia or Cultural Heritage data.
Many streets in this city are named after writers, artists or other public figures. People walking the streets, whether locals or visitors, typically see little more
than the name. By matching geographic info to historical data, we open up possibilities for keeping alive the memory of people whose names have been given to streets.

SQLite Database ams.db is created from XML export, using http://osmlib.rubyforge.org/ tools 
 
./bin/osmsqlite import map.osm ams.db


select nodes.lon, nodes.lat, way_tags.value from way_tags, nodes, way_nodes where way_nodes.node = nodes.id and way_nodes.way = way_tags.ref and  way_tags.value like "%straat%";

Please note that OSM data is http://creativecommons.org/licenses/by-sa/2.0/ licensed; use accordingly (Attribution-Share Alike 2.0 Generic).

Examples:

4.8760456,52.3474221,"Albrecht Durerstraat"
4.87595,52.34832,"Albrecht Durerstraat"
4.8759124,52.3489164,"Albrecht Durerstraat"
4.8759124,52.3489164,"Albrecht Durerstraat"
4.8758437,52.3498601,"Albrecht Durerstraat"

-> http://en.wikipedia.org/wiki/Albrecht_D%C3%BCrer
"Albrecht Dürer (German pronunciation: [ˈalbʀɛçt ˈdyʀɐ]) (21 May 1471 – 6 April 1528)[1]  was a German  painter, printmaker and theorist from Nuremberg. His prints established his reputation across Europe when he was still in his twenties, and he has been conventionally regarded as the greatest artist of the Northern Renaissance ever since."




4.8646163,52.3666922,"Nicolaas Beetsstraat"
4.8650454,52.3659271,"Nicolaas Beetsstraat"

-> http://en.wikipedia.org/wiki/Nicolaas_Beets
Nicolaas Beets (13 September 1814 – 13 March 1903) was a Dutch  theologian, writer and poet. He published under the pseudonym, Hildebrand.
--> http://www.gutenberg.org/browse/authors/b#a6404

4.9041795,52.3518048,"Jan Lievensstraat"
4.9044199,52.3512181,"Jan Lievensstraat"
4.9046451,52.3505981,"Jan Lievensstraat"
4.9048942,52.3499303,"Jan Lievensstraat"
4.9050714,52.3494152,"Jan Lievensstraat"
-> http://en.wikipedia.org/wiki/Jan_Lievens
"Jan Lievens (24 October 1607 – 4 June 1674) was a Dutch  painter, usually associated with Rembrandt, working in a similar style."

4.8976832,52.3516974,"Karel du Jardinstraat"
4.8947273,52.3512702,"Karel du Jardinstraat"
-> http://en.wikipedia.org/wiki/Karel_Dujardin
