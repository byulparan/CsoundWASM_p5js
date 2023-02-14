<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 10
nchnls = 2
0dbfs = 1.0
seed 0


gkBPM init 140
gkBPM chnexport "gkBPM", 3, 2, i(gkBPM), 30, 180
gkRunning init 0
gkRunning chnexport "gkRunning", 3, 2, i(gkRunning), 0, 1
gkLimit init 27
gkLimit chnexport "gkLimit", 3, 2, i(gkLimit), 1, 32


gkMix chnexport "gkMix", 3, 3
gkKickMix chnexport "gkKickMix", 3, 3

gkTempo init (140 / 60) * 4



giSin ftgen 1, 0, 8192, 10, 1

schedule "clock", 0, -1
schedule "reverb", 0, -1
schedule "mix", 0, -1

instr clock
  gkTempo = (gkBPM / 60) * 4
  ktrig metro gkTempo
  kcount init 0
  if ktrig == 1 && gkRunning == 1 then
    if kcount % 32 < gkLimit then 
      schedulek "schedule", .0, .1, kcount
    endif
    kcount += 1
  endif
endin

instr schedule
  icount = p4
  if icount % 2 == 0 then
    schedule "_fm_beat", 0, 0.25 * int(random(1,4)), 140, 0.5 * int(random(1,3)), 1.2, 0.5, 0.0
    if random(0,1) > 0.7 then
      schedule "_fm_beat", (1/i(gkTempo)) * 1 , .125, 240, 1 * int(random(1,6)), 1.4, 0.5 + random(-0.5,0.5), random(0, 0.3)
    endif
  endif
  iKickStep[] fillarray 1, 0, 0, 1, 0, 0, 1, 0
  if iKickStep[icount % 8] == 1 || random(0,1) > 0.8 then
    schedule "_kick", 0, .1
  endif
  iSnareStep[] fillarray 0, 0, 0, 0, 1, 0, 0, .5
  if iSnareStep[icount % 8] > random(0.3, 1.0) then
    schedule "_snare", 0, .1
  endif
  if (icount % 32 == 0) then
    schedule "_fm_pad", 0, (1/i(gkTempo) * 40)
  endif
endin


instr _kick
  aenv line .24, p3, .0
  asig oscil aenv, line:k(210, p3, 40)
  outs asig, asig
  chnmix asig, "KickMix"
endin

instr _snare
  aenv line .2, p3, .0
  asig foscil aenv, 340, .5, 1.3, 4.1
  outs asig, asig
endin

instr _fm_beat
  kenv linseg 0.2, p3*0.9,0.2, p3*0.1, 0.0
  kcps linseg p4, p3*0.2, 80
  asig foscili kenv, kcps, 1, p5, p6, -1
  al,ar pan2 asig*0.5, p7
  outs al, ar
  chnmix al * p8, "reverbL"
  chnmix ar * p8, "reverbR"
  chnmix al + ar, "mix"
endin


instr _fm_pad
  ifreq1 = 50
  ifreq2 = random(0,1) > .5 ? 55 : 58
  ifreq3 = random(0,1) > .5 ? 60 : 63
  iTopNote[] fillarray 66, 69, 71
  ifreq4 = iTopNote[random(0, lenarray(iTopNote))]
  kenv linseg 0.0, p3*0.2, 0.2, p3*0.6, 0.2, p3*0.2, 0.0
  klfo oscil  .4, 1.3
  klfo2 oscil .4, 1.6

  iratio = int(random(2,4))
  indx = 4
  a1 foscil kenv, cpsmidinn(ifreq1), 1, iratio, kenv*indx+klfo, -1
  a2 foscil kenv, cpsmidinn(ifreq2), 1, iratio, kenv*indx+klfo, -1
  a3 foscil kenv, cpsmidinn(ifreq3), 1, iratio, kenv*indx+klfo, -1
  a4 foscil kenv, cpsmidinn(ifreq4), 1, iratio, kenv*indx+klfo, -1
  a5 foscil kenv, cpsmidinn(ifreq1)+4, 1, iratio, kenv*indx+klfo2, -1
  a6 foscil kenv, cpsmidinn(ifreq2)+4, 1, iratio, kenv*indx+klfo2, -1
  a7 foscil kenv, cpsmidinn(ifreq3)+4, 1, iratio, kenv*indx+klfo2, -1
  a8 foscil kenv, cpsmidinn(ifreq4)+4, 1, iratio, kenv*indx+klfo2, -1

  al = (a1 + a2 + a3 + a4)*0.1
  ar = (a5 + a6 + a7 + a8)*0.1
  
  outs al, ar
  chnmix al*0.2, "reverbL"
  chnmix ar*0.2, "reverbR"
endin



instr reverb
  al, ar reverbsc chnget:a("reverbL"), chnget:a("reverbR"), .9, 12000
  outs al, ar
  chnclear "reverbL", "reverbR"
  chnmix al + ar, "mix"
endin

instr mix
  gkMix = follow(chnget:a("mix"), 0.00125)
  gkKickMix = follow(chnget:a("KickMix"), 0.00125)
  chnclear "mix", "KickMix"
endin

</CsInstruments>
<CsScore>


</CsScore>
</CsoundSynthesizer>
