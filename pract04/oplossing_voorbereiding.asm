;; zet onderbrekingen aan
push  eax
in    al, 0x21
and   al, 1111110b
out   0x21, al
pop   %eax
