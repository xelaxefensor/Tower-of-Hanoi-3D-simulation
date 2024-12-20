extends Node

var number_of_disks : int = 5
var min_number_of_disks : int = 4

var starting_rod : int = 0
var number_of_rods : int = 3

var hanoi_moves : PackedVector2Array = []

var calculated : bool = false

signal hanoi_calculated


func set_up_hanoi() -> void:
	calculated = false
	hanoi_moves = []


func move_it(from: int, to: int) -> void:
	#print("Přesun ", from, " --> ", to)
	hanoi_moves.append(Vector2i(from, to))
	

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
 
	# Spuštění rekurzivního řešení
	do_hanoi(number_of_disks, 0, 1, 2)
	calculated = true
	hanoi_calculated.emit()
