#!/bin/bash
# Change Aranym config file to match memory offset
# reported by fixedmem option for JIT mode
# fixedmem is extracted from aranym-jit --fixedmem command which outputs:
# suggested --fixedmem setting 0x9a000000 (1567MB TT-RAM)
#memoffset=$(/usr/bin/aranym-jit --probe-fixed | grep "suggested --fixedmem" | awk '{print $4}')
# Let's do this a couple of times as return value might change and keep biggest value
# As we should have plenty of RAM after, not risking a process coming and take some
# memory at low offset
max_memoffset=0x00000000
for (( c=1; c<=5; c++ ))
do
  /usr/bin/aranym-jit --probe-fixed &> tmp.txt
  memoffset=$(cat tmp.txt | grep "suggested --fixedmem" | awk '{print $4}')
  echo '(loop)JIT memoffset found:' $memoffset 'max:' $max_memoffset
  if [[ "$memoffset" > "$max_memoffset" ]]; then
    max_memoffset=$memoffset
  fi
done
rm tmp.txt
echo 'JIT memoffset found:' $max_memoffset
echo 'Replacing memoffset in config file...'
sed -i "/FixedMemoryOffset =/c\FixedMemoryOffset = $memoffset" /aranym/config
