IF EXIST DKC_Practice_Rom.sfc (del DKC_Practice_Rom.sfc)

copy rom\"Donkey Kong Country (V1.0) (U).smc" "Donkey Kong Country (V1.0) (U).smc"
ren  "Donkey Kong Country (V1.0) (U).smc" DKC_Practice_Rom.sfc

asar\asar.exe main.asm DKC_Practice_Rom.sfc
timeout 3
