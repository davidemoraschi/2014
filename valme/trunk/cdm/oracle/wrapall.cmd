@echo off
del *.enc
for %%f in (*.PRC *.FNC *.PKB) do wrap iname=%%f oname=%%f.ENC
for %%f in (*.ENC) do echo quit | sqlplus CDM/iPaddellaSamsung@MTI @%%f
del *.enc
