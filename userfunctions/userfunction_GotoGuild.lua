--== GotoGuild userfunction
--==      By Rock5
--==     Version 1.21

--== http://www.solarstrike.net/phpBB3/viewtopic.php?p=52165#p52165

--== Usage: GotoGuild(destination)

--==   Where 'destination' can be;
--==     a point number (which you'll probably never use)
--==       eg. GotoGuild(27)

--==     one of the few labels (which you might use)
--==       eg. GotoGuild("Vault")

--==     or the name (or partial name) or id of a builing or structure (which you'll use most of the time)
--==     eg. GotoGuild("Library")

local GuildPoints = {
	[1]={ X=-408 , Z=342, Name="Square1", Links={[1]={Num=17},[2]={Num=2},}},
	[2]={ X=-458 , Z=342, Links={[1]={Num=1},[2]={Num=3},}},
	[3]={ X=-508 , Z=342, Links={[1]={Num=2},[2]={Num=4},[3]={Num=25},}},
	[4]={ X=-508 , Z=398, Links={[1]={Num=3},[2]={Num=6},}},
	[6]={ X=-508 , Z=454, Links={[1]={Num=4},[2]={Num=7},}},
	[7]={ X=-508 , Z=510, Links={[1]={Num=6},[2]={Num=8},}},
	[8]={ X=-508 , Z=566, Links={[1]={Num=9},[2]={Num=7},}},
	[9]={ X=-458 , Z=566, Links={[1]={Num=8},[2]={Num=10},}},
	[10]={ X=-408 , Z=566, Links={[1]={Num=9},[2]={Num=11},}},
	[11]={ X=-358 , Z=566, Links={[1]={Num=10},[2]={Num=12},}},
	[12]={ X=-308 , Z=566, Links={[1]={Num=11},[2]={Num=13},}},
	[13]={ X=-308 , Z=510, Links={[1]={Num=12},[2]={Num=14},}},
	[14]={ X=-308 , Z=454, Links={[1]={Num=13},[2]={Num=15},}},
	[15]={ X=-308 , Z=398, Links={[1]={Num=14},[2]={Num=16},}},
	[16]={ X=-308 , Z=342, Links={[1]={Num=15},[2]={Num=29},[3]={Num=17},}},
	[17]={ X=-358 , Z=342, Links={[1]={Num=16},[2]={Num=1},}},
	[18]={ X=-408 , Z=91, Name="Square2", Links={[1]={Num=34},[2]={Num=19},}},
	[19]={ X=-458 , Z=91, Links={[1]={Num=18},[2]={Num=20},}},
	[20]={ X=-508 , Z=91, Links={[1]={Num=19},[2]={Num=21},[3]={Num=42},[4]={Num=46},[5]={Num=143},}},
	[21]={ X=-508 , Z=147, Links={[1]={Num=20},[2]={Num=23},}},
	[23]={ X=-508 , Z=203, Links={[1]={Num=21},[2]={Num=24},}},
	[24]={ X=-508 , Z=259, Links={[1]={Num=23},[2]={Num=25},}},
	[25]={ X=-508 , Z=315, Links={[1]={Num=3},[2]={Num=26},[3]={Num=24},}},
	[26]={ X=-458 , Z=315, Links={[1]={Num=25},[2]={Num=27},}},
	[27]={ X=-408 , Z=315, Links={[1]={Num=26},[2]={Num=28},}},
	[28]={ X=-358 , Z=315, Links={[1]={Num=27},[2]={Num=29},}},
	[29]={ X=-308 , Z=315, Links={[1]={Num=28},[2]={Num=16},[3]={Num=30},}},
	[30]={ X=-308 , Z=259, Links={[1]={Num=29},[2]={Num=31},}},
	[31]={ X=-308 , Z=203, Links={[1]={Num=30},[2]={Num=32},}},
	[32]={ X=-308 , Z=147, Links={[1]={Num=31},[2]={Num=33},}},
	[33]={ X=-308 , Z=91, Links={[1]={Num=32},[2]={Num=34},[3]={Num=46},[4]={Num=42},}},
	[34]={ X=-358 , Z=91, Links={[1]={Num=33},[2]={Num=18},}},
	[35]={ X=-408 , Z=-335, Name="Square3", Links={[1]={Num=51},[2]={Num=36},}},
	[36]={ X=-458 , Z=-335, Links={[1]={Num=35},[2]={Num=37},}},
	[37]={ X=-508 , Z=-335, Links={[1]={Num=36},[2]={Num=38},[3]={Num=54},}},
	[38]={ X=-508 , Z=-279, Links={[1]={Num=37},[2]={Num=40},}},
	[40]={ X=-508 , Z=-223, Links={[1]={Num=38},[2]={Num=41},}},
	[41]={ X=-508 , Z=-167, Links={[1]={Num=40},[2]={Num=42},}},
	[42]={ X=-508 , Z=-111, Links={[1]={Num=43},[2]={Num=41},[3]={Num=33},[4]={Num=20},[5]={Num=143},}},
	[43]={ X=-458 , Z=-111, Links={[1]={Num=42},[2]={Num=44},}},
	[44]={ X=-408 , Z=-111, Links={[1]={Num=43},[2]={Num=45},}},
	[45]={ X=-358 , Z=-111, Links={[1]={Num=44},[2]={Num=46},}},
	[46]={ X=-308 , Z=-111, Links={[1]={Num=45},[2]={Num=47},[3]={Num=33},[4]={Num=20},[5]={Num=63},}},
	[47]={ X=-308 , Z=-167, Links={[1]={Num=46},[2]={Num=48},}},
	[48]={ X=-308 , Z=-223, Links={[1]={Num=47},[2]={Num=49},}},
	[49]={ X=-308 , Z=-279, Links={[1]={Num=48},[2]={Num=50},[3]={Num=59},}},
	[50]={ X=-308 , Z=-335, Links={[1]={Num=49},[2]={Num=51},[3]={Num=58},[4]={Num=57},}},
	[51]={ X=-358 , Z=-335, Links={[1]={Num=50},[2]={Num=35},}},
	[52]={ X=-184 , Z=-493, Name="Square4", Links={[1]={Num=53},[2]={Num=68},}},
	[53]={ X=-234 , Z=-493, Links={[1]={Num=54},[2]={Num=52},}},
	[54]={ X=-284 , Z=-493, Links={[1]={Num=55},[2]={Num=53},[3]={Num=37},}},
	[55]={ X=-284 , Z=-437, Links={[1]={Num=57},[2]={Num=54},}},
	[57]={ X=-284 , Z=-381, Links={[1]={Num=58},[2]={Num=55},[3]={Num=50},}},
	[58]={ X=-284 , Z=-325, Links={[1]={Num=59},[2]={Num=57},[3]={Num=50},}},
	[59]={ X=-284 , Z=-269, Links={[1]={Num=58},[2]={Num=60},[3]={Num=49},}},
	[60]={ X=-234 , Z=-269, Links={[1]={Num=61},[2]={Num=59},}},
	[61]={ X=-184 , Z=-269, Links={[1]={Num=62},[2]={Num=60},}},
	[62]={ X=-134 , Z=-269, Links={[1]={Num=63},[2]={Num=61},}},
	[63]={ X=-84 , Z=-269, Links={[1]={Num=64},[2]={Num=62},[3]={Num=46},[4]={Num=76},[5]={Num=71},[6]={Num=137},[7]={Num=138},}},
	[64]={ X=-84 , Z=-325, Links={[1]={Num=65},[2]={Num=63},}},
	[65]={ X=-84 , Z=-381, Links={[1]={Num=66},[2]={Num=64},}},
	[66]={ X=-84 , Z=-437, Links={[1]={Num=67},[2]={Num=65},}},
	[67]={ X=-84 , Z=-493, Links={[1]={Num=68},[2]={Num=66},[3]={Num=137},[4]={Num=76},[5]={Num=217},}},
	[68]={ X=-134 , Z=-493, Links={[1]={Num=52},[2]={Num=67},}},
	[69]={ X=184 , Z=-493, Name="Square5", Links={[1]={Num=70},[2]={Num=85},}},
	[70]={ X=134 , Z=-493, Links={[1]={Num=71},[2]={Num=69},}},
	[71]={ X=84 , Z=-493, Links={[1]={Num=72},[2]={Num=70},[3]={Num=137},[4]={Num=63},[5]={Num=217},}},
	[72]={ X=84 , Z=-437, Links={[1]={Num=74},[2]={Num=71},}},
	[74]={ X=84 , Z=-381, Links={[1]={Num=75},[2]={Num=72},}},
	[75]={ X=84 , Z=-325, Links={[1]={Num=76},[2]={Num=74},}},
	[76]={ X=84 , Z=-269, Links={[1]={Num=77},[2]={Num=75},[3]={Num=63},[4]={Num=93},[5]={Num=137},[6]={Num=67},[7]={Num=138},}},
	[77]={ X=134 , Z=-269, Links={[1]={Num=78},[2]={Num=76},}},
	[78]={ X=184 , Z=-269, Links={[1]={Num=79},[2]={Num=77},}},
	[79]={ X=234 , Z=-269, Links={[1]={Num=80},[2]={Num=78},}},
	[80]={ X=284 , Z=-269, Links={[1]={Num=79},[2]={Num=89},[3]={Num=81},}},
	[81]={ X=284 , Z=-325, Links={[1]={Num=82},[2]={Num=80},[3]={Num=90},}},
	[82]={ X=284 , Z=-381, Links={[1]={Num=83},[2]={Num=81},[3]={Num=90},}},
	[83]={ X=284 , Z=-437, Links={[1]={Num=84},[2]={Num=82},}},
	[84]={ X=284 , Z=-493, Links={[1]={Num=85},[2]={Num=83},[3]={Num=101},}},
	[85]={ X=234 , Z=-493, Links={[1]={Num=69},[2]={Num=84},}},
	[86]={ X=408 , Z=-335, Name="Square6", Links={[1]={Num=102},[2]={Num=87},}},
	[87]={ X=358 , Z=-335, Links={[1]={Num=86},[2]={Num=90},}},
	[89]={ X=308 , Z=-279, Links={[1]={Num=90},[2]={Num=91},[3]={Num=80},}},
	[90]={ X=308 , Z=-335, Links={[1]={Num=87},[2]={Num=89},[3]={Num=81},[4]={Num=82},}},
	[91]={ X=308 , Z=-223, Links={[1]={Num=89},[2]={Num=92},}},
	[92]={ X=308 , Z=-167, Links={[1]={Num=91},[2]={Num=93},}},
	[93]={ X=308 , Z=-111, Links={[1]={Num=94},[2]={Num=92},[3]={Num=76},[4]={Num=122},[5]={Num=135},}},
	[94]={ X=358 , Z=-111, Links={[1]={Num=93},[2]={Num=95},}},
	[95]={ X=408 , Z=-111, Links={[1]={Num=94},[2]={Num=96},}},
	[96]={ X=458 , Z=-111, Links={[1]={Num=95},[2]={Num=97},}},
	[97]={ X=508 , Z=-111, Links={[1]={Num=96},[2]={Num=98},[3]={Num=135},[4]={Num=122},[5]={Num=180},}},
	[98]={ X=508 , Z=-167, Links={[1]={Num=97},[2]={Num=99},}},
	[99]={ X=508 , Z=-223, Links={[1]={Num=98},[2]={Num=100},}},
	[100]={ X=508 , Z=-279, Links={[1]={Num=99},[2]={Num=101},}},
	[101]={ X=508 , Z=-335, Links={[1]={Num=100},[2]={Num=102},[3]={Num=84},}},
	[102]={ X=458 , Z=-335, Links={[1]={Num=101},[2]={Num=86},}},
	[103]={ X=408 , Z=342, Name="Square8", Links={[1]={Num=119},[2]={Num=104},}},
	[104]={ X=358 , Z=342, Links={[1]={Num=103},[2]={Num=107},}},
	[106]={ X=308 , Z=398, Links={[1]={Num=107},[2]={Num=108},}},
	[107]={ X=308 , Z=342, Links={[1]={Num=104},[2]={Num=106},[3]={Num=127},}},
	[108]={ X=308 , Z=454, Links={[1]={Num=106},[2]={Num=109},}},
	[109]={ X=308 , Z=510, Links={[1]={Num=108},[2]={Num=110},}},
	[110]={ X=308 , Z=566, Links={[1]={Num=111},[2]={Num=109},}},
	[111]={ X=358 , Z=566, Links={[1]={Num=110},[2]={Num=112},}},
	[112]={ X=408 , Z=566, Links={[1]={Num=111},[2]={Num=113},}},
	[113]={ X=458 , Z=566, Links={[1]={Num=112},[2]={Num=114},}},
	[114]={ X=508 , Z=566, Links={[1]={Num=113},[2]={Num=115},}},
	[115]={ X=508 , Z=510, Links={[1]={Num=114},[2]={Num=116},}},
	[116]={ X=508 , Z=454, Links={[1]={Num=115},[2]={Num=117},}},
	[117]={ X=508 , Z=398, Links={[1]={Num=116},[2]={Num=118},}},
	[118]={ X=508 , Z=342, Links={[1]={Num=117},[2]={Num=119},[3]={Num=131},}},
	[119]={ X=458 , Z=342, Links={[1]={Num=118},[2]={Num=103},}},
	[120]={ X=408 , Z=91, Name="Square7", Links={[1]={Num=121},[2]={Num=136},}},
	[121]={ X=358 , Z=91, Links={[1]={Num=122},[2]={Num=120},}},
	[122]={ X=308 , Z=91, Links={[1]={Num=123},[2]={Num=121},[3]={Num=93},[4]={Num=135},[5]={Num=97},}},
	[123]={ X=308 , Z=147, Links={[1]={Num=125},[2]={Num=122},}},
	[125]={ X=308 , Z=203, Links={[1]={Num=126},[2]={Num=123},}},
	[126]={ X=308 , Z=259, Links={[1]={Num=127},[2]={Num=125},}},
	[127]={ X=308 , Z=315, Links={[1]={Num=107},[2]={Num=128},[3]={Num=126},}},
	[128]={ X=358 , Z=315, Links={[1]={Num=129},[2]={Num=127},}},
	[129]={ X=408 , Z=315, Links={[1]={Num=130},[2]={Num=128},}},
	[130]={ X=458 , Z=315, Links={[1]={Num=129},[2]={Num=131},}},
	[131]={ X=508 , Z=315, Links={[1]={Num=130},[2]={Num=118},[3]={Num=132},}},
	[132]={ X=508 , Z=259, Links={[1]={Num=133},[2]={Num=131},}},
	[133]={ X=508 , Z=203, Links={[1]={Num=134},[2]={Num=132},}},
	[134]={ X=508 , Z=147, Links={[1]={Num=135},[2]={Num=133},}},
	[135]={ X=508 , Z=91, Links={[1]={Num=136},[2]={Num=134},[3]={Num=122},[4]={Num=97},[5]={Num=93},[6]={Num=180},}},
	[136]={ X=458 , Z=91, Links={[1]={Num=120},[2]={Num=135},}},
	[137]={ X=0 , Z=-485, Name="Start", Links={[1]={Num=67},[2]={Num=71},[3]={Num=63},[4]={Num=76},[5]={Num=138},[6]={Num=217},}},
	[138]={ X=0 , Z=-106, Links={[1]={Num=63},[2]={Num=76},[3]={Num=137},[4]={Num=139, Action="castleGate"},}},
	[139]={ X=0 , Z=-66, Links={[1]={Num=142},[2]={Num=138, Action="castleGate"},}},
	[140]={ X=0 , Z=620, Name="Vault", Links={[1]={Num=142},}},
	[142]={ X=0 , Z=260, Links={[1]={Num=140},[2]={Num=139},}},
	[143]={ X=-633 , Z=0, Links={[1]={Num=20},[2]={Num=42},[3]={Num=144, Action="outerGate"},}},
	[144]={ X=-669 , Z=0, Links={[1]={Num=143, Action="outerGate"},[2]={Num=145},}},
	[145]={ X=-802 , Z=0, Links={[1]={Num=144},[2]={Num=163},[3]={Num=146},}},
	[146]={ X=-872 , Z=268, Links={[1]={Num=145},[2]={Num=161},[3]={Num=149},[4]={Num=147},}},
	[147]={ X=-950 , Z=434, Name="Square9", Links={[1]={Num=146},[2]={Num=162},[3]={Num=148},}},
	[148]={ X=-1000 , Z=434, Links={[1]={Num=147},[2]={Num=149},}},
	[149]={ X=-1050 , Z=434, Links={[1]={Num=150},[2]={Num=146},[3]={Num=148},}},
	[150]={ X=-1050 , Z=490, Links={[1]={Num=151},[2]={Num=149},}},
	[151]={ X=-1050 , Z=546, Links={[1]={Num=152},[2]={Num=150},}},
	[152]={ X=-1050 , Z=602, Links={[1]={Num=153},[2]={Num=151},}},
	[153]={ X=-1050 , Z=658, Links={[1]={Num=154},[2]={Num=152},}},
	[154]={ X=-1000 , Z=658, Links={[1]={Num=155},[2]={Num=153},}},
	[155]={ X=-950 , Z=658, Links={[1]={Num=156},[2]={Num=154},[3]={Num=225},}},
	[156]={ X=-900 , Z=658, Links={[1]={Num=157},[2]={Num=155},}},
	[157]={ X=-850 , Z=658, Links={[1]={Num=158},[2]={Num=156},[3]={Num=225},}},
	[158]={ X=-850 , Z=602, Links={[1]={Num=159},[2]={Num=157},}},
	[159]={ X=-850 , Z=546, Links={[1]={Num=160},[2]={Num=158},}},
	[160]={ X=-850 , Z=490, Links={[1]={Num=161},[2]={Num=159},}},
	[161]={ X=-850 , Z=434, Links={[1]={Num=146},[2]={Num=160},[3]={Num=162},}},
	[162]={ X=-900 , Z=434, Links={[1]={Num=147},[2]={Num=161},}},
	[163]={ X=-880 , Z=-280, Links={[1]={Num=145},[2]={Num=174},[3]={Num=170},[4]={Num=172},}},
	[164]={ X=-950 , Z=-659, Name="Square10", Links={[1]={Num=179},[2]={Num=165},[3]={Num=220},}},
	[165]={ X=-1000 , Z=-659, Links={[1]={Num=164},[2]={Num=166},}},
	[166]={ X=-1050 , Z=-659, Links={[1]={Num=165},[2]={Num=167},}},
	[167]={ X=-1050 , Z=-603, Links={[1]={Num=166},[2]={Num=168},}},
	[168]={ X=-1050 , Z=-547, Links={[1]={Num=167},[2]={Num=169},}},
	[169]={ X=-1050 , Z=-491, Links={[1]={Num=168},[2]={Num=170},}},
	[170]={ X=-1050 , Z=-435, Links={[1]={Num=169},[2]={Num=163},[3]={Num=171},}},
	[171]={ X=-1000 , Z=-435, Links={[1]={Num=172},[2]={Num=170},}},
	[172]={ X=-950 , Z=-435, Links={[1]={Num=163},[2]={Num=171},[3]={Num=173},}},
	[173]={ X=-900 , Z=-435, Links={[1]={Num=172},[2]={Num=174},}},
	[174]={ X=-850 , Z=-435, Links={[1]={Num=163},[2]={Num=175},[3]={Num=173},}},
	[175]={ X=-850 , Z=-491, Links={[1]={Num=174},[2]={Num=176},}},
	[176]={ X=-850 , Z=-547, Links={[1]={Num=175},[2]={Num=177},}},
	[177]={ X=-850 , Z=-603, Links={[1]={Num=176},[2]={Num=178},}},
	[178]={ X=-850 , Z=-659, Links={[1]={Num=177},[2]={Num=179},[3]={Num=220},}},
	[179]={ X=-900 , Z=-659, Links={[1]={Num=178},[2]={Num=164},}},
	[180]={ X=633 , Z=0, Links={[1]={Num=97},[2]={Num=181, Action="outerGate"},[3]={Num=135},}},
	[181]={ X=669 , Z=0, Links={[1]={Num=180, Action="outerGate"},[2]={Num=182},}},
	[182]={ X=802 , Z=0, Links={[1]={Num=181},[2]={Num=200},[3]={Num=183},}},
	[183]={ X=880 , Z=-280, Links={[1]={Num=182},[2]={Num=190},[3]={Num=192},[4]={Num=194},}},
	[184]={ X=952 , Z=-658, Name="Square11", Links={[1]={Num=185},[2]={Num=199},[3]={Num=222},}},
	[185]={ X=902 , Z=-658, Links={[1]={Num=186},[2]={Num=184},}},
	[186]={ X=852 , Z=-658, Links={[1]={Num=187},[2]={Num=185},[3]={Num=222},}},
	[187]={ X=852 , Z=-602, Links={[1]={Num=188},[2]={Num=186},}},
	[188]={ X=852 , Z=-546, Links={[1]={Num=189},[2]={Num=187},}},
	[189]={ X=852 , Z=-490, Links={[1]={Num=190},[2]={Num=188},}},
	[190]={ X=852 , Z=-434, Links={[1]={Num=183},[2]={Num=189},[3]={Num=191},}},
	[191]={ X=902 , Z=-434, Links={[1]={Num=190},[2]={Num=192},}},
	[192]={ X=952 , Z=-434, Links={[1]={Num=193},[2]={Num=183},[3]={Num=191},}},
	[193]={ X=1002 , Z=-434, Links={[1]={Num=194},[2]={Num=192},}},
	[194]={ X=1052 , Z=-434, Links={[1]={Num=195},[2]={Num=193},[3]={Num=183},}},
	[195]={ X=1052 , Z=-490, Links={[1]={Num=196},[2]={Num=194},}},
	[196]={ X=1052 , Z=-546, Links={[1]={Num=197},[2]={Num=195},}},
	[197]={ X=1052 , Z=-602, Links={[1]={Num=198},[2]={Num=196},}},
	[198]={ X=1052 , Z=-658, Links={[1]={Num=199},[2]={Num=197},}},
	[199]={ X=1002 , Z=-658, Links={[1]={Num=184},[2]={Num=198},}},
	[200]={ X=872 , Z=268, Links={[1]={Num=182},[2]={Num=203},[3]={Num=201},[4]={Num=215},}},
	[201]={ X=952 , Z=434, Name="Square12", Links={[1]={Num=216},[2]={Num=202},[3]={Num=200},}},
	[202]={ X=902 , Z=434, Links={[1]={Num=201},[2]={Num=203},}},
	[203]={ X=852 , Z=434, Links={[1]={Num=200},[2]={Num=204},[3]={Num=202},}},
	[204]={ X=852 , Z=490, Links={[1]={Num=203},[2]={Num=205},}},
	[205]={ X=852 , Z=546, Links={[1]={Num=204},[2]={Num=206},}},
	[206]={ X=852 , Z=602, Links={[1]={Num=205},[2]={Num=207},}},
	[207]={ X=852 , Z=658, Links={[1]={Num=206},[2]={Num=208},[3]={Num=229},}},
	[208]={ X=902 , Z=658, Links={[1]={Num=207},[2]={Num=209},}},
	[209]={ X=952 , Z=658, Links={[1]={Num=208},[2]={Num=210},[3]={Num=229},}},
	[210]={ X=1002 , Z=658, Links={[1]={Num=209},[2]={Num=211},}},
	[211]={ X=1052 , Z=658, Links={[1]={Num=210},[2]={Num=212},}},
	[212]={ X=1052 , Z=602, Links={[1]={Num=211},[2]={Num=213},}},
	[213]={ X=1052 , Z=546, Links={[1]={Num=212},[2]={Num=214},}},
	[214]={ X=1052 , Z=490, Links={[1]={Num=213},[2]={Num=215},}},
	[215]={ X=1052 , Z=434, Links={[1]={Num=214},[2]={Num=216},[3]={Num=200},}},
	[216]={ X=1002 , Z=434, Links={[1]={Num=215},[2]={Num=201},}},
	[217]={ X=0 , Z=-635, Links={[1]={Num=218, Action="outerGate"},[2]={Num=137},[3]={Num=67},[4]={Num=71},}},
	[218]={ X=0 , Z=-672, Links={[1]={Num=219},[2]={Num=221},[3]={Num=217, Action="outerGate"},}},
	[219]={ X=-75 , Z=-815, Links={[1]={Num=223},[2]={Num=218},[3]={Num=221},}},
	[220]={ X=-780 , Z=-815, Links={[1]={Num=178},[2]={Num=164},[3]={Num=223},}},
	[221]={ X=75 , Z=-815, Links={[1]={Num=218},[2]={Num=224},[3]={Num=219},}},
	[222]={ X=780 , Z=-815, Links={[1]={Num=224},[2]={Num=186},[3]={Num=184},}},
	[223]={ X=-430 , Z=-815, Links={[1]={Num=220},[2]={Num=219},}},
	[224]={ X=430 , Z=-815, Links={[1]={Num=221},[2]={Num=222},}},
	[225]={ X=-800 , Z=815, Links={[1]={Num=157},[2]={Num=226},[3]={Num=155},}},
	[226]={ X=-400 , Z=815, Links={[1]={Num=225},[2]={Num=227},}},
	[227]={ X=0 , Z=815, Links={[1]={Num=226},[2]={Num=228},}},
	[228]={ X=400 , Z=815, Links={[1]={Num=227},[2]={Num=229},}},
	[229]={ X=800 , Z=815, Links={[1]={Num=228},[2]={Num=207},[3]={Num=209},}},
}

-- Create Name-Num table
local NameNum = {}
for k,v in pairs(GuildPoints) do
	if v.Name then
		NameNum[v.Name] = k
	end
end

local Foundation_points = {
	Square1 = { X = -408, Z = 454, Links = {}},
	Square2 = { X = -408, Z = 203, Links = {}},
	Square3 = { X = -408, Z = -223, Links = {}},
	Square4 = { X = -184, Z = -381, Links = {}},
	Square5 = { X = 184, Z = -381, Links = {}},
	Square6 = { X = 408, Z = -223, Links = {}},
	Square7 = { X = 408, Z = 203, Links = {}},
	Square8 = { X = 408, Z = 454, Links = {}},
	Square9 = { X = -950, Z = 546, Links = {}},
	Square10= { X = -950, Z = -547, Links = {}},
	Square11= { X = 952, Z = -547, Links = {}},
	Square12= { X = 952, Z = 546, Links = {}},
}

-- These function are the functions that can be called for a link instead of just doing a moveto. Eg. Action="castleGate"
local functions = {
	castleGate = function(from, to)
		local success = player:moveTo(CWaypoint(GuildPoints[to].X,GuildPoints[to].Z),true)
		if success == false then
			player:target_NPC(GetIdName(111577))
			yrest(3000)
			success = player:moveTo(CWaypoint(GuildPoints[to].X,GuildPoints[to].Z),true)
		end
		return success
	end,

	outerGate = function(from, to)
		local success = player:moveTo(CWaypoint(GuildPoints[to].X,GuildPoints[to].Z),true)
		if success == false then
			player:target_NPC(GetIdName(112064))
			yrest(3000)
			success = player:moveTo(CWaypoint(GuildPoints[to].X,GuildPoints[to].Z),true)
		end
		return success
	end,
} -- end of functions

-- Returns table with shortest path.
local function Dijkstra(start, finish, nodes)
	--Create a closed and open set
	local open = {}
	local closed = {}

	--Attach data to all noded without modifying them
	local data = {}
	for node in pairs(nodes) do
		data[node] = {
			distance = math.huge,
			previous = nil
		}
	end

	--The start node has a distance of 0, and starts in the open set
	open[start] = true
	data[start].distance = 0

	while true do
		--pick the nearest open node
		local best = nil
		for node in pairs(open) do
			if not best or data[node].distance < data[best].distance then
				best = node
			end
		end
		--at the finish - stop looking
		if best == finish then break end

		--all nodes traversed - finish not found! No connection between start and finish
		if not best then return end

		--calculate a new score for each neighbors
		for from, node in pairs(nodes[best].Links) do
--			local neighbor = string.match(node,"[%a%d]*")
			local neighbor = node.Num
			--provided it's not already in the closed set
			if not closed[neighbor] then
				local newdist = data[best].distance + distance(nodes[best], nodes[neighbor])
				if newdist < data[neighbor].distance then
					data[neighbor].distance = newdist
					data[neighbor].previous = best
					open[neighbor] = true
				end
			end
		end

		--move the node to the closed set
		closed[best] = true
		open[best] = nil
	end

	--walk backwards to reconstruct the path
	local path = {}
	local at = finish
	while at ~= start do
		table.insert(path, 1, at)
		at = data[at].previous
	end

	return path
end

local function getNearestPoint(_obj, _points)
	if _obj == nil then -- Default to 'closest to player'.
		player:update()
		_x = player.X
		_z = player.Z
	else
		_z = _obj.Z
		_x = _obj.X
	end

	local closest
	for k,v in pairs(_points) do
		if closest == nil or distance(v.X, v.Z, _x, _z) < distance(_points[closest].X, _points[closest].Z,  _x, _z) then
			closest = k
		end
	end

	return closest
end

function GotoGuild(destination)
-- 'destination' can be point number, point Name or structure name
	destination = tonumber(destination) or destination

	-- Get start
	local start = getNearestPoint(nil, GuildPoints)

	-- Get finish
	local finish
	if not destination then
		error("Specify a destination for GuildGoto()")
	elseif type(destination) == "number" and 10000 > destination then
		if GuildPoints[destination] then
			finish = destination
		end
	elseif NameNum[destination] then
		finish = NameNum[destination]
	else -- Look for structure
		local structure = player:findNearestNameOrId(destination)
		if not structure then
			print("Structure not found")
			return false
		end

		-- Check if on large foundation
		local p = getNearestPoint(structure, Foundation_points)
		if 10 > distance(structure, Foundation_points[p]) then
			finish = NameNum[p]
		else
			finish = getNearestPoint(structure, GuildPoints)
		end
	end

	if not finish then
		print("Failed to find destination '"..tostring(destination).."'.")
		return false
	end

	-- Get path
	local path = Dijkstra(start, finish, GuildPoints)

	-- Travel path
	local from
	for k,to in ipairs(path) do
		print("Going to point #"..to)
		-- See if there is an 'action' associated with the link
		local actionUsed = false
		local success
		if from then
			for i,link in pairs(GuildPoints[from].Links) do
				if link.Num == to then -- link found
					-- Check for action
					if link.Action and type(functions[link.Action]) == "function" then
						success = functions[link.Action](from, to)
						actionUsed = true
					end
					break
				end
			end
		end
		if actionUsed == false then
			success = player:moveTo(CWaypoint(GuildPoints[to].X,GuildPoints[to].Z),true)
		end
		if not success then
			error("Failed to move to point #"..to)
		end
		from = to
	end
end


