extends Node

var number_of_disks : int = 5
var min_number_of_disks : int = 4

var starting_rod : int = 0
var number_of_rods : int = 3

var hanoi = []
var hanoi_moves = []

func set_up_hanoi():
	hanoi = []
	hanoi_moves = []
	for x in number_of_rods:
		hanoi.append([])

	for x in number_of_disks:
		hanoi[starting_rod].append(x)

	print_debug(hanoi)


func move_it(from: int, to: int) -> void:
	#print("Přesun ", from, " --> ", to)
	hanoi_moves.append([from, to])
	
	
	hanoi[to].push_back(hanoi[from].pop_back())
	print_debug(hanoi)


func do_hanoi(n: int, from: int, to: int, using: int) -> void:
	if n == 0:
		return
	# Přesuneme n-1 kotoučů z frm na using za použití to
	do_hanoi(n - 1, from, using, to)
	# Přesuneme největší kotouč z frm na to
	move_it(from, to)
	# Přesuneme zbytek z using na to za použití frm
	do_hanoi(n - 1, using, to, from)


func start_hanoi() -> void:
	set_up_hanoi()
	var n = 0
	while n <= 0:
		n = number_of_disks
		if n <= 0:
			print("Počet kotoučů musí být kladné celé číslo.")
	# Spuštění rekurzivního řešení
	do_hanoi(n, 0, 1, 2)
