MEMORY {
  PROG : ORIGIN = 0x0, LENGTH = 0x1024
  DATA : ORIGIN = 0x1024, LENGTH = 0x800
  STACK : ORIGIN = 0x1824, LENGTH = 4K
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
   } > DATA

   .bss : ALIGN(16) {
     *(.bss)
     *(.bss.*)
   }

   .stack : ALIGN(16) {
     _estack = .;
   } > STACK

   _sstack = _estack + __stack_size;
 }
