extends Resource

class_name Item

export(String) var name = ""
export(Texture) var texture 
var amount = 1

export(int) var heal = 0 #stat for foods to heal player
export(int) var dmg = 0  #stat for weapons
export(int) var durability = 0 #stat for armor and shield
