.data
	setDesc: .asciiz "Min set: "
	blankLine: .asciiz " "
	filename: .asciiz "text.txt"
	buffer: .space 1
.text
	main:
		li $v0, 13 #open file in read mode
		la $a0, filename
		li $a1, 0
		syscall
		move $s2, $v0 #file descriptor
		jal readFile
		move $s0, $v0 #starting address
		move $s1, $v1 #setNum
		#jal printSets
		#li $a0, 2
		#jal getSet
		#move $s3, $v0
		#li $a0, 0x12
		#jal search
		#move $s4, $v0
		#jal intersection
		jal findMinSet
		li $v0, 10
		syscall
		
	findMinSet:
		addi $sp, $sp, -4
		sw $ra, 0($sp) #stack pointer adjustment
		la $a0, setDesc
		li $v0, 4
		syscall
		whileMainNotEmpty:
			jal isMainEmpty
			beq $v0, 1, MainEmpty #repeat until main empty
			jal intersection #get most intersectioned set
			move $a0, $v0
			li $v0, 1
			syscall
			jal findAndDelete #delete all occurrences
			la $a0, blankLine
			li $v0, 4
			syscall
			j whileMainNotEmpty
		MainEmpty:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
	isMainEmpty:
		addi $sp, $sp, -8
		sw $s0, 0($sp)#take starting adress
		sw $t1, 4($sp)
		lookForEmpty:
			lw $t1, ($s0)
			beq $t1, 10, Empty#If we not end function until here, this implies that set is empty 
			bne $t1, -2, notEmpty#If there is a element different from -2, this set is not empty
			addi $s0, $s0, 4 #index increment
			j lookForEmpty
		notEmpty:
			li $v0, 0 #indicates that set is not empty
			lw $s0, 0($sp)
			lw $t1, 4($sp)
			addi $sp, $sp, 8
			jr $ra
		Empty:
			li $v0, 1 #indicates that set is empty
			lw $s0, 0($sp)
			lw $t1, 4($sp)
			addi $sp, $sp, 8
			jr $ra
	findAndDelete:
		addi $sp, $sp, -8
		sw $s0, 0($sp)
		sw $ra, 4($sp)
		li $t4, -1 #empty element for subset
		li $t5, -2 #empty element for main set

		jal getSet #get intersection set
		
		whileMainSet:
			move $t1, $v0 #getted set
			lw $t2, ($s0)
			beq $t2, 10, setEnd #if main set end stop searching
			findInSubset:
				lw $t3, ($t1)
				beq $t3, 10, endSubset#if subset ended search for new element in main set
				beq  $t3, $t2, match
				addi $t1, $t1, 4 #index increase
				j findInSubset
				
				endSubset:
					addi $s0, $s0, 4 #address increase
					j whileMainSet
				match:
					sw $t4, ($t1) #for matched in subset load -1
					sw $t5, ($s0) #for matched in main set load -2
					addi $s0, $s0, 4
					j whileMainSet
		setEnd:
			lw $s0, 0($sp) #stack pointer adjustment
			lw $ra, 4($sp)
			addi $sp, $sp, 8
			jr $ra
	
	readFile:
		addi $sp, $sp, -4
		sw $s2, 0($sp)
		move $t6, $zero
		la $t8, buffer
		li $t9, 0
		read:
		li $v0, 14#take the char value to buffer
		la $a1, buffer
		li $a2, 1 #length
		move $a0, $s2 #file descriptor
		syscall
		
		la $t2, buffer
		addi $t2, $t2, -1# make the adress multiple of 4 for loading word
		lw $t1, ($t2)
		sra $t1, $t1, 8 #shift 
		beq $t1, 32, blank  #check is space
		beq $t1, 0, endFile  #check is endFile
		beq $t1, 10, addSet #new set
		andi $t1, $t1, 0xF #convert the string value to the integer
		sllv  $t5, $t5, $t9
		addi $t9, $t9, 4
		or $t5, $t5, $t1
		la $t2, buffer #reset buffer value for overwriting
		addi $t2, $t2, -1
		sw $zero, ($t2)
		j read #read next char
		
		addSet: #if there is new line this is new set
			andi $t1, $t1, 0xF 
			addi $t7, $t7, 4
			add $t3, $t2, $t7
			sw $t5, ($t3)
			addi $t7, $t7, 4
			add $t3, $t2, $t7
			sw $t1, ($t3)
			la $t2, buffer
			li $t9, 0
			li $t5, 0
			addi $t6, $t6, 1 #store total set number
			addi $t2, $t2, -1
			sw $zero, ($t2) #reset buffer
			j read
		blank:
		addi $t7, $t7, 4##unutma
		add $t3, $t2, $t7
		sw $t5, ($t3)
		li $t9, 0
		li $t5, 0
		la $t2, buffer #ignore spaces
		addi $t2, $t2, -1
		sw $zero, ($t2)
		j read
		
		endFile:
		addi $t6, $t6, -1
		move $v1, $t6 #return the total set number
		addi $t8, $t8, 3 #make the adress word
		move $v0, $t8 #return set sequence starting adress
		lw $s2, 0($sp)
		addi $sp, $sp, 4
	 	jr $ra
	
	getSet:
		addi $sp, $sp,-8
		sw $s0, 0($sp)#stack pointer adjustment
		sw $s1, 4($sp)
		
		whileSet:
		beq $a0, 0,exitSet #repeat until get set starting adress
		lw $s1, ($s0) #load value of sets
		beq $s1, 10, newSet #if there is new set
		addi $s0, $s0, 4 #increment the index of memory addresses of sets
		j whileSet
		
		newSet:
		addi $s0, $s0, 4
		addi $a0, $a0, -1 #decrease set num for stop condition
		j whileSet
		
		exitSet:
		move $v0, $s0 #save the founded set adress
		lw $s0, 0($sp)#load values of stack pointer
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
	
	search:
		addi $sp, $sp,-8
		sw $s0, 0($sp)#stack pointer adjustment
		sw $s1, 4($sp)
		move $v0, $zero#assume that searcing element hadn't found in main set
		
		whileSearch:
			lw $s1, ($s0)#load the values from main set
			beq $s1, $a0, found #if loaded value is equal argument, this is the value
			beq $s1, 10, notFound#if we encounter with new set symbol we didnt find searching elemnt
			addi $s0, $s0, 4 #increment searching index
			j whileSearch
			
		found:
			addi $v0, $v0, 1 #flag for element founded
			lw $s0, 0($sp)
			lw $s1, 4($sp)#load stack pointer
			addi $sp, $sp, 8
			jr $ra
		
		notFound:#don't change $v0, didn't find
			lw $s0, 0($sp)
			lw $s1, 4($sp)#load stack pointer
			addi $sp, $sp, 8
			jr $ra
	
	intersection:
		addi $sp, $sp, -8
		sw $s1, 0($sp)#stack adjustment
		sw $ra, 4($sp)
		move $t4, $zero #compare 
		li $t5, 1 #starting set
		whileNotEnd:
			bgt $t5, $s1,exitInter #exit if all sets covered
			move $t1, $zero #make zero for founded counter
			move $a0, $t5 #get nth set address
			jal getSet
			move $t2, $v0 #store address
			whileSetNotEnd:
				lw $a0, ($t2) #look elements of that set
				beq $a0, 10, exitSetEnd #if set covered exit
				addi $t2, $t2, 4 #next element
				jal search #search in main set
				beq $v0, 1, founded #if it's founded increment founded counter
				j whileSetNotEnd
				founded:
					addi $t1, $t1, 1
					j whileSetNotEnd
			exitSetEnd: #if a set covered ready for next set and look for previous set has better founded counter
				addi $t5, $t5, 1
				bgt $t1, $t4, greater
				j whileNotEnd
			greater:
				addi $t5, $t5, -1 #turn back previous set
				move $t9, $t5 #store value of bigger occurance set
				move $t4, $t1 #change the compare number
				j whileNotEnd
		exitInter:
			move $v0, $t9 #return
			lw $s1, 0($sp) #load back stack
			lw $ra, 4($sp)
			addi $sp, $sp, 8
			jr $ra
	
