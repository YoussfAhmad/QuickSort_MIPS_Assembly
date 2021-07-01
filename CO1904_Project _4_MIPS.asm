.data
SizePrompt: .asciiz "Enter the array size:" 
InputPrompt:.asciiz "\nEnter array element :"
ChoicePrompt:.asciiz "\nPress 1 for Insertion Sort\nPress 2 for Quick Sort\n"
Line: .asciiz "\n"
choice_input:.word 0
InputChoice:.asciiz "To Enter Characters Press 1 , To Enter Numbers Press 2\n"
sorted : .asciiz "array sorted "
comma:.asciiz ","
searchMessage:.asciiz "\nPress 1 for Binary Search\nPress 0 to Exit the Program\n"
valMsg:  .asciiz "Enter the value you search for : \n"
val_int:     .word 0
notfound:.asciiz "the value doesn't exist in the array !! \n"
posMsg:  .asciiz "\n This value exist in the array and its position is "
.text
main:

li   $v0,4                #Printing the size Prompt.  
la   $a0,SizePrompt       #Loading $a0 with address of SizePrompt
syscall
               
li   $v0,5                #Takin/g Integer  Input from User(Size).        
syscall

move $t0,$v0              #Saving Size in Register ($t0).
     
li   $v0,4
la   $a0,InputChoice      #Print InputChoice Message to choose between char and int
syscall
 
li $v0,5                    # Enter 1 for char,Enter 2 for int
syscall
     
move $s0,$v0                #saving user choice in register $s0
sw   $s0,choice_input       #saving user choice in var choice_input
    
beq  $s0,1,input1           # if s0==1 -->input1 is for taking char elements
beq  $s0,2,input2           # if s0==2 -->input2 is for taking int  elements
#Input function for char     
input1: 
move $a0,$t0
li   $v0,9            #Allocating memory Space for the array.
syscall       
   
move $t1,$v0          #Saving array address in Register($t1).
move $a1,$t1          #Set $a1 to the Value of Array Address to be used in Sub_Functions.
jal Input_Char        # call char input function
j done                #after calling complete rest of program by jump uncondintionally to done
 #Input Function For Integers#    
input2:
sll  $a0,$t0,2        #Shift by 2 to save space for integers[Integer(4bytes)].      
li   $v0,9            #Allocating memory Space for the array.
syscall
     
move $t1,$v0          #Saving array address in Register($t1).
move $a1,$t1          #Set $a1 to the Value of Array Address to be used in Sub_Functions.
jal  Input_Int
########################################################################
done:
li   $a2,0            #Set $a2 to low (low=0)in the first call.
addi $a3,$t0,-1       #Set $a3 to Size-1 (High) in the first call.

#Switch case for quick sort and insertion sort
li $v0,4
la $a0,ChoicePrompt
syscall
     
li $v0,5           #Scanning number of choice from user
syscall

move $s0,$v0 
     
lw   $s4 , choice_input        #Switch($s4)
beq  $s4,1,case1_char          #case1
beq  $s4,2,case2_int           #case2
     
case1_char:
beq $s0,1,internal_char_fun1   #if input =1 insertion sort will be applied  
beq $s0,2,internal_char_fun2   #if input =2 quicksort will be applied

internal_char_fun1:
jal  insertionSort_char
j done2                     #after calling complete rest of program by jump uncondintionally to done2
  
internal_char_fun2:
jal  QuickSort_char 
j done2                   #after calling complete rest of program by jump uncondintionally to done

case2_int:
beq $s0,1,internal_int_fun1   #if input =1 insertion sort will be applied  
beq $s0,2,internal_int_fun2   #if input =2 quicksort will be applied
    
     internal_int_fun1:
     jal  insertionSort_int
     j done2
     
     internal_int_fun2:
     jal  QuickSort_int
     j done2

     done2:
     li   $s0,0
     li   $s1,0
     li   $s2,0
     li   $s3,0
     move $s1,$t0
     #Choose the proper Printing Function According to user choice
     done3_printing:
        lw   $s4 , choice_input     
        beq  $s4,1,print_char
        beq  $s4,2,print_int
     
     print_char:
     jal PrintArray_char 
     j binary              #branch to the next step in program binary_search
     
     print_int:
     jal PrintArray_int
     j binary             ##branch to the next step in program binary_search
     
     #Binary Search Conditions
     binary:
     li $v0,4
     la $a0,searchMessage       #Choose 1 to search or 0 to Exit
     syscall
     
     li $v0,5
     syscall
     
     move $s3,$v0             # Save the value in $t3 to switch on it
     beq $s3,0,final          #branch to end of program
     beq $s3,1,search         #branch to binary_search Section
     
    #Choose the proper datatype of Searching Function According to user choice
     search:
     lw   $s4 , choice_input     #load value of choice_input from memory

     beq  $s4,2,search_int
     
     search_int:
     # print value message
    li $v0, 4
    la $a0, valMsg
    syscall

    # read the value from the user
    li $v0, 5
    syscall

    # store the value in the val variable
    sw $v0, val_int
   
    ################################################
    ## put $s0 = start , $s1 = middle , $s2 = end ##
    ################################################
    
      li $s0, 0
      move $s2, $t0  
      
      jal BinarySearch_int
      
    
      j final                  # branch to end of program
      
       
     final:
     #End of program
     li $v0,10
     syscall

#------------------------------------------------------------------------------------------------------------------#
#SUB Functions#
Input_Char:
           li   $s0,0                           #initialize loop counter with zero i=0
           move $s1,$t0                         #s1=size
           move $s2,$a1                         #s2=array_address
Input_Char_Loop:
               beq  $s0,$s1,EndInput_Char    #If s0<Size go to the next instruction.  
                                             #else branch to the end and return to caller.
               li   $v0,4
               la   $a0,InputPrompt          #Print Input Prompt.     
               syscall
          
               li   $v0,12                    #Taking Input from User(Element).
               syscall 
   
               sb   $v0,($s2)                 #Store element in the Memorey.
      
               addi $s2,$s2,1 	                #address++(To move to the next address in the stack).
               addi $s0,$s0,1                 #$s0++ (Increment Loop Counter)
     
              j Input_Char_Loop
EndInput_Char:       
              jr $ra                              #Return Back To the caller (main function).
##############################################################################################################
Input_Int:
       li   $s0,0            #Initialize the loop counter to zero
       move $s1,$t0          #$s1=Size(Used in Input Loop)
       move $s2,$t1          #$s2=$t1=Array_Address.
Input_Int_Loop:
              beq  $s0,$s1,EndInput_Int    #If s0<Size go to the next instruction.  
                                           #else branch to the end and return to caller.
              li   $v0,4
              la   $a0,InputPrompt         #Print Input Prompt.     
              syscall
          
              li   $v0,5                  #Taking Input from User(Element).
              syscall
   
              sw   $v0,($s2)             #Store element in the Memory.
      
              addi $s2,$s2,4            #address++(To move to the next address in the stack).
              addi $s0,$s0,1            #$s0++
     
              j Input_Int_Loop
EndInput_Int:       
             jr $ra                #Return Back To the caller (main function).
#---------------------------------------------------------------------------------------------------------------#        
Swap_int:   
     sll  $t2,$a2,2          #Allocate Space for integer in $t2.
     add  $t2,$t2,$a1        #Go to the given index to get the element.    
     lw   $s3,0($t2)         #load element arr[a2] in $s3.
     
     sll  $t3,$a3,2          #Allocate Space for integer in $t3.
     add  $t3,$t3,$a1        #Go to the given index to get the element.    
     lw   $s4,0($t3)         #load element arr[a3] in $s4.
     
     sw   $s3,0($t3)         #arr[a2]=arr[a3].       
     sw   $s4,0($t2)         #arr[a3]=arr[a2].
        
     jr $ra                  #jump back to the caller.  
#--------------------------------------------------------------------------------------------------------------#         
Partition_int:
          addi $sp,$sp,-4
          sw   $ra,0($sp)
   
          addi   $s0,$zero,0
          addi   $s1,$zero,0
          addi   $s2,$zero,0
          
          move $s0,$a2       #Save $a2  in $s0 
          move $s1,$a3       #Save $a3  in $s1
           
          sll  $s2,$a3,2     #high*4
          
          add  $s2,$a1,$s2   #load the address of pivot element in $s2
          lw   $t4,0($s2)    #$t4 = Pivot = Arr[high] = Arr[a3]
                                               
          addi $t5,$a2,-1    #$t5 = i = low-1 = $a2-1      
          move $t6,$s0       #$t6=j=low
          addi $t7,$s1,1     #$t7=high-1         
MainLoop_int:
         beq   $t6,$t7,EndLoop_int     #if low<=high-1
               
         sll  $s5,$t6,2                #Allocate Space for integer in $t2.
         add  $s5,$a1,$s5              #Go to the given index to get the element
         lw   $t8,0($s5)               #a[j]
         
         bge   $t8,$t4,EndIf_int
         addi  $t5,$t5,1               #i++    
         
         move $a2,$t5
         move $a3,$t6
         jal  Swap_int
         
         addi $t6,$t6,1              #j++
         
         j MainLoop_int
         
EndIf_int:
      addi $t6,$t6,1   #j++
      j MainLoop_int   #jump back to the loop
EndLoop_int:
        addi $a2,$t5,1        #i=i+1
        move $a3,$s1          #high=$a3
        add  $v1,$zero,$a2    #pass the return value to $v1 (i+1)                                
        jal Swap_int          #swap(a[i+1],a[h])

        lw $ra ,0($sp)        #load the return address back

        addi $sp,$sp,4
        jr $ra			
QuickSort_int:
          addi $sp, $sp, -16		        # Make room for 4
	  sw   $a1, 0($sp)			# a1
	  sw   $a2, 4($sp)			# low
	  sw   $a3, 8($sp)			# high
	  sw   $ra, 12($sp)			# return address
          li   $s5,0
          li   $s6,0
          li   $s7,0
          move $s6,$a2
          move $s7,$a3
         
          
          slt  $s5,$s6,$s7                     #$s5=0 ,if(l<h) 
          beq  $s5,$zero,ENND_int              #if $s5=0 ,branch to end of function
          
          jal Partition_int                   #if  $s5!=0 , call partition function
          move $t9,$v1                        #save the returned value in $t9
          
          
          lw   $a2,4($sp)
     
          addi $a3,$t9,-1                 
          jal QuickSort_int
          
          addi $a2, $t9, 1		#a2 = pi + 1
          lw   $a3, 8($sp)	        #a3 = high
	  jal  QuickSort_int	        #call quicksort

ENND_int:
        lw $a1, 0($sp)			#restore a0
 	lw $a2, 4($sp)			#restore a1
 	lw $a3, 8($sp)			#restore a2
 	lw $ra, 12($sp)			#restore return address
 	addi $sp, $sp, 16		#restore the stack
 	jr $ra				#return to caller    
Swap_char:
     move $t2,$a2
     add  $t2,$t2,$a1        #Go to the given index to get the element.    
     lb   $s3,0($t2)         #load element arr[a2] in $s3.
     move $t3,$a3
     #sll  $t3,$a3,2          #Allocate Space for integer in $t3.
     add  $t3,$t3,$a1        #Go to the given index to get the element.    
     lb   $s4,0($t3)         #load element arr[a3] in $s4.
     
     sb   $s3,0($t3)         #arr[a2]=arr[a3].       
     sb   $s4,0($t2)         #arr[a3]=arr[a2].
     
     #addi $sp, $sp, 12	     #Restoring the stack size         
     jr $ra                  #jump back to the caller.  
#--------------------------------------------------------------------------------------------------------------#         
Partition_char:
          addi $sp,$sp,-4
          sw   $ra,0($sp)
      
          addi   $s0,$zero,0
          addi   $s1,$zero,0
          addi   $s2,$zero,0
          
          move $s0,$a2       #Save $a2  in $s0 
          move $s1,$a3       #Save $a3  in $s1
          
          move $s2,$a3
          add  $s2,$a1,$s2   #load the address of pivot element in $s2
          lb   $t4,0($s2)    #$t4 = Pivot = Arr[high] = Arr[a3]
                                               
          addi $t5,$a2,-1    #$t5 = i = low-1 = $a2-1      
          move $t6,$s0       #$t6=j=low
          addi $t7,$s1,1     #$t7=high-1         
MainLoop_char:
         beq   $t6,$t7,EndLoop_char
               

         move $s5,$t6
         add  $s5,$a1,$s5
         lb   $t8,0($s5)    #a[j]
         
         bge   $t8,$t4,EndIf_char
         addi $t5,$t5,1     #i++    
         
         move $a2,$t5
         move $a3,$t6
         jal  Swap_char
         
         addi $t6,$t6,1   #j++
         
         j MainLoop_char
         
EndIf_char:
      addi $t6,$t6,1   #j++
      j MainLoop_char
EndLoop_char:
        addi $a2,$t5,1  #i=i+1
        move $a3,$s1    #high=$a3
        add  $v1,$zero,$a2     #pass the return value to $v1 (i+1)                                      
        jal Swap_char                        #swap(a[i+1],a[h])

        lw $ra ,0($sp)        #load the return address back
        addi $sp,$sp,4
        jr $ra			
QuickSort_char:
          addi $sp, $sp, -16		        # Make room for 4
	  sw   $a1, 0($sp)			# a1
	  sw   $a2, 4($sp)			# low
	  sw   $a3, 8($sp)			# high
	  sw   $ra, 12($sp)			# return address
          li $s5,0
          li $s6,0
          li $s7,0
          move $s6,$a2
          move $s7,$a3
         
          
          slt  $s5,$s6,$s7                   #$s5=0 ,if(l<h) 
          beq  $s5,$zero,ENND_char          #if $s5=0 ,branch to end of function
          jal Partition_char                  #if  $s5!=0 , call partition function
          move $t9,$v1                       #save the returned value in $t9
          
          
          lw   $a2,4($sp)                 #load the saved value of $a2 from stack
    
          addi $a3,$t9,-1                
          jal QuickSort_char
          
          addi $a2, $t9, 1		    #a2 = pi + 1
    
	  lw   $a3, 8($sp)	              #a3 = high
	  jal QuickSort_char			#call quicksort

ENND_char:
        lw $a1, 0($sp)			#restore a0
 	lw $a2, 4($sp)			#restore a1
 	lw $a3, 8($sp)			#restore a2
 	lw $ra, 12($sp)			#restore return address
 	addi $sp, $sp, 16		#restore the stack
 
 	jr $ra				#return to caller     	                         
PrintArray_int:
           beq  $s0,$s1,endprint_int
           move $s2,$s0
           
           sll $s2,$s2,2         #multiply $s2 which holds low index by 4
           add $s2,$s2,$a1       
           lw $s3,($s2)          #load element from this index
          
           li $v0,1
           move $a0,$s3
           syscall
           
        
           addi $s0,$s0,1
           
           li $v0,4
           la $a0,comma
           syscall
           
           j   PrintArray_int
           jr $ra                    
endprint_int:

PrintArray_char:
           beq  $s0,$s1,endprint_char
      
            move $s2,$s0
           
           #sll $s2,$s2,2
           add $s2,$s2,$a1
           lb $s3,($s2)
          
           li $v0,11
           move $a0,$s3
           syscall
     
           
           addi $s0,$s0,1
              li $v0,4
           la $a0,comma
           syscall
           j   PrintArray_char
           jr $ra                    
endprint_char:

insertionSort_int : 
		addi $s2 , $zero , 1  # initialize i = 1
		addi $s3 , $zero , 0  # intitialize value = 0 
		addi $s4 , $zero , 0  #initialize t1 = 0 , j=0
	        j firstloop_int
	
firstloop_int : 
	bgt  $s2 , $a3 , exit_int	#here ask if i> length branch else continue
	mul  $t3 , $s2 , 4
	add $t3 , $a1 , $t3	#here t0 has address of array + address of i 
	lw  $s3 , 0($t3)	#here value = a[i]
	subi $s4 , $s2 , 1	#here making j = i -1
	j secondloop_int
	
secondloop_int:
	  bltz  $s4,exitsecondloop_int       #if (j >= 0 ) continue else branch to exit second loop a[j+1] = value
	  mul $t3 , $s4 , 4		# get address of j and put it into t3
	  add $t3 , $a1 , $t3		# here add address of array + address of j to get a[j]
	  lw $t3 , 0($t3)			# load value of a[j] to $t1
	  blt $t3 , $s3 , exitsecondloop_int #if a[j] < value branch else continue
	  addi $t4 , $s4 , 0		# j
	  mul $t4 , $t4 , 4		# get address of j
	  add $t4 , $t4 , $a1		# t1 now have address of (j) + address of array
	  lw $t4 , 0($t4)			# get value at a[j]
	
	  addi $t2 , $s4 , 1		# j = j+1
	  mul $t2 , $t2 , 4		# get address of j+1
	  add $t2 , $t2 , $a1		# having now address of (j+1) + address of array
	  sw $t4 , 0($t2)			# a[j+1] = a[j]
	  subi $s4 , $s4 , 1		# making j--     if error occured see this condition 
	  j secondloop_int
	
	
exitsecondloop_int:	
		addi $t3 ,$s4 , 1	# j+1
		mul $t3 , $t3 , 4	# address of j+1
		add $t3 , $t3 , $a1	#address of j+1 + address of array
		sw $s3 , 0($t3)		# a[j+1] = value
		addi $s2 , $s2 , 1	# i++
		j firstloop_int
	      
exit_int: 
	li $v0 , 4
	la $a0 , sorted
	syscall
	addi $t3 , $zero , 0 
	jr $ra
   

insertionSort_char: 
		   addi $s2 , $zero , 1  # initialize i = 1
		   addi $s3 , $zero , 0  # intitialize value = 0 
		   addi $s4 , $zero , 0  #initialize t1 = 0 , j=0
	           j firstloop_char
	
firstloop_char: 
	      	bgt  $s2 , $a3 , exit_char	#here ask if i> length branch else continue
	        move $t3,$s2
	        add $t3 , $a1 , $t3	#here t3 has address of array + address of i 
	        lb  $s3 ,0($t3)	          #here value = a[i]
	        subi $s4 , $s2 , 1	#here making j = i -1
	       j secondloop_char

secondloop_char:
	       bltz  $s4,exitsecondloop_char       #if (j >= 0 ) continue else branch to exit second loop a[j+1] = value
	       
	       move $t3,$s4
	       add $t3 , $a1 , $t3		# here add address of array + address of j to get a[j]
	       lb $t3 , 0($t3)			# load value of a[j] to $t3
	       blt $t3 , $s3 , exitsecondloop_char #if a[j] < value branch else continue
	       addi $t4 , $s4 , 0		# j
	 
	      add $t4 , $t4 , $a1		# t1 now have address of (j) + address of array
	      lb $t4 , 0($t4)			# get value at a[j]
	
	     addi $t2 , $s4 , 1		# j = j+1
	  
	  add $t2 , $t2 , $a1		# having now address of (j+1) + address of array
	  sb $t4 , 0($t2)			# a[j+1] = a[j]
	  subi $s4 , $s4 , 1		# making j--     if error occured see this condition 
	  j secondloop_char
	
exitsecondloop_char:	
		addi $t3 ,$s4 , 1	# j+1
		add  $t3 , $t3 , $a1	#address of j+1 + address of array
		sb   $s3 , 0($t3)		# a[j+1] = value
		addi $s2 , $s2 , 1	# i++
		j firstloop_char
exit_char : 
        li $v0 , 4
	la $a0 , sorted
	syscall
	addi $t3 , $zero , 0 
	jr $ra                       
	                  
BinarySearch_int:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # middle = (start + end ) / 2
    
    
loooop:
    # base case
    ble  $s2,$s0 returnNegative1_int       # if (end <= start) 
    add  $t4, $s0, $s2                   # $t4 = start + end
    sra  $t4, $t4, 1                    # $s1 = $t4 / 2
                     
    move $s1,$t4
    sll $s3,$t4,2
    add $s3,$s3,$a1

    lw  $t5, 0($s3)                           # $t5 = arr[middle]
    lw  $t2, val_int                          # $t2 = val_int

    beq $t5, $t2, returnMiddle_int          # if (arr[middle] == val)
    bgt $t2, $t5, returnLastPart_int        # if (val > arr[middle])  
    blt $t2, $t5, returnFirstPart_int       # if (val < arr[middle])

j loooop

    returnNegative1_int:
         li $v1, -1
         li $v0,4
         la $a0,notfound
         syscall
         
       j Exit_int       
    returnMiddle_int:
      move $v1, $s1                    # return middle
       li $v0,4
       la $a0,posMsg
       syscall
       
       li $v0,1
       move $a0,$v1
       syscall
       
       j Exit_int   

    returnFirstPart_int:

           move $t3, $s1                # temp = middle     
           #addi $t3, $t3, -1            # temp --
           
           move $s2, $t3                # end = temp
          j loooop

    returnLastPart_int:                             
       move $t3, $s1                    # temp = middle
       addi $t3, $t3, 1                 # temp++
       move $s0, $t3                    # start = temp
       j loooop

Exit_int:   
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra        
                    
                        
         
