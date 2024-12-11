MEMORY {
  PROG: ORIGIN = 0x0, LENGTH = 0x1024
  
}
__stack_size = 4K;

ENTRY(_start)

SECTIONS {
   .text : ALIGN(16) {
     *(.text)
   } > PROG

   .data : ALIGN(16) {
     *(.rodata)
     *(.rodata.*)
     *(.data)
     *(.data.*)
   }

   .bss : ALIGN(16) {
     *(.bss)
     *(.bss.*)
   }

   .stack : ALIGN(16) {
     _estack = .;
   }

   _sstack = _estack + __stack_size;
 }
