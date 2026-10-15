#!/bin/bash
echo 'Mouse Fixing......'
./gloryctl/target/release/gloryctl button \
           1:mouse:left \
           2:mouse:right \
           3:mouse:middle \
           4:keyboard::104 \
           5:media:mute \
           6:media:playpause

echo "Process Successfully Completed"
