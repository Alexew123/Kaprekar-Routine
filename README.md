# Kaprekar-Routine
Application to demonstrate Kaprekar's constant in x86 Assembly

This application is designed for a 16-bit DOSBox operating system with the use of TASM(Turbo Assembler)

The app has 2 running modes Interaction/Automatic. These modes are selected by the user at the start of the application.

Interaction:
-user manually picks a number to test the routine on
-every step of the routine is printed + number of iterations
-user can choose to repeat this process or exit

Automatic:
-user needs to wait for "Done!" message
-every integer from 0-9999 is tested in the Kaprekar's Routine and printed in the newly created output.txt file
-alongside each integer tested is the number of iterations needed to reach Kaprekar's constant or 0
