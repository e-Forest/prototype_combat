extends Node

func angle_dif(from : float, to : float)->float:
	var ret = fposmod(to - from, TAU)
	if ret > PI:
		ret -= TAU
	return ret
