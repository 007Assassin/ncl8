set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(x) 500
set val(y) 500
set val(ifqlen) 50
set val(nn) 50
set val(stop) 100.0
set val(rp) AODV

set val(sc) "mobile"
set val(cp) "transfer"

set ns_ [new Simulator]

set tracefd [open 003.tr w]
$ns_ trace-all $tracefd

set namtrace [open 003.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop [new $val(prop)]
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON

for {set i 0} {$i < $val(nn)} {incr i} {

set node_($i) [$ns_ node]
$node_($i) random-motion 0
}

for {set i 0} {$i < $val(nn)} {incr i} {
set xx [expr rand() * $val(x)]
set yy [expr rand() * $val(y)]
$node_($i) set X_ $xx
$node_($i) set Y_ $yy
}

for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 40
}

puts "Loading connection file..."
source $val(cp)
source $val(sc)

for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ at $val(stop) "$node_($i) reset"
}
$ns_ at $val(stop) "puts \"NS EXITING...\" ; finish ;
$ns_ halt"
proc finish {} {
global ns_ tracefd namtrace
$ns_ flush-trace
close $tracefd
close $namtrace
exec nam 003.nam &
exit 0
}
puts "Starting Simulation..."
$ns_ run


AWK SCRIPT:
BEGIN {
recd =0
hdrsz =0
stoptime =0
starttime=0
}
{
time =$2
if($1=="s" && $4=="AGT" && $8>=512){
if(time > starttime || starttime ==0){
starttime = time
}
}
if($1=="r" && $4=="AGT" && $8 >= 512){
if(time > starttime){
stoptime = time
}
hdrsz =$8%512
$8-= hdrsz
recd += $8
}
}
END {
printf("Gooput = %f Kbps \n",(recd)/(stoptime-starttime)*8/1000)
}

