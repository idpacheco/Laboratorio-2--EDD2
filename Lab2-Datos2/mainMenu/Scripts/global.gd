# Global.gd
extends Node

var arbol: ArbolBinario = ArbolBinario.new()
var index: int
var estado_des: bool

func _ready() -> void:
	
	arbol.agregar_nodo({"valor": 7, "nombre": "res://Map/scences/maps/level1_map.tscn", "activado":false, 
		"pregunta":"¿Qué es el phishing?", 
		"opciones":["Un tipo de antivirus","Un ataque que busca robar datos mediante engaños"]})

	arbol.agregar_nodo({"valor": 3, "nombre": "res://Map/scences/maps/level2_map.tscn", "activado":false,
		"pregunta":"¿Qué hace un firewall?", 
		"opciones":[" Protege la red filtrando el tráfico no deseado", " Acelera la conexión a Internet"]})
	
	arbol.agregar_nodo({"valor": 11, "nombre": "res://Map/scences/maps/level2_map.tscn", "activado":false,
		"pregunta":"¿Cuál de los siguientes es un tipo de malware?", 
		"opciones":["Firewall","Ransomware"]})
	
	arbol.agregar_nodo({"valor": 1, "nombre": "res://Map/scences/maps/level3_map.tscn", "activado":false,
		"pregunta":"¿Qué significa '2FA'?", 
		"opciones":[" Autenticación de dos factores", " Archivo de acceso seguro"]})
	
	arbol.agregar_nodo({"valor": 5, "nombre": "res://Map/scences/maps/level3_map.tscn", "activado":false,
		"pregunta":"¿Qué debes hacer si recibes un correo sospechoso?", 
		"opciones":[" Eliminarlo y reportarlo", " Abrirlo para revisarlo"]})
	
	arbol.agregar_nodo({"valor": 9, "nombre": "res://Map/scences/maps/level3_map.tscn", "activado":false,
		"pregunta":"¿Qué caracteriza a una contraseña segura?", 
		"opciones":[" Usa letras, números y símbolos", " Es fácil de recordar como '12345'"]})
	
	arbol.agregar_nodo({"valor": 13, "nombre": "res://Map/scences/maps/level3_map.tscn", "activado":false,
		"pregunta":"¿Qué valor tendria la primera puerta de este arbol?", 
		"opciones":["7", " 8"]})
	
	arbol.agregar_nodo({"valor": 0, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué función tiene el cifrado?", 
		"opciones":[" Proteger datos convirtiéndolos en código ilegible", " Borrar archivos dañados"]})
	
	arbol.agregar_nodo({"valor": 2, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué hace el ransomware?", 
		"opciones":[ "Secuestra archivos y pide dinero para liberarlos", " Protege tu información en línea"]})
	
	arbol.agregar_nodo({"valor": 4, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué es una copia de seguridad?", 
		"opciones":[" Un respaldo de tus datos para restaurarlos luego", " Un programa que acelera tu PC"]})
	
	arbol.agregar_nodo({"valor": 6, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué es una brecha de datos?", 
		"opciones":[" Robo o filtración de información confidencial", " Mejora en la seguridad del sistema"]})
	
	arbol.agregar_nodo({"valor": 8, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Cuál de estas acciones NO es segura?", 
		"opciones":[" Usar la misma contraseña en todos los sitios", " Actualizar tus programas con frecuencia"]})
	
	arbol.agregar_nodo({"valor": 10, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué herramienta detecta virus y malware?", 
		"opciones":[" Antivirus", " Router"]})
	
	arbol.agregar_nodo({"valor": 12, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué es una VPN?", 
		"opciones":[" Una red privada virtual que protege tu conexión", " Un virus que daña el sistema"]})
	
	arbol.agregar_nodo({"valor": 14, "nombre": "res://Level 4/scenes/level_4.tscn", "activado":false,
		"pregunta":"¿Qué debes hacer antes de descargar un archivo?", 
		"opciones":[" Escanearlo con un antivirus", " Abrirlo directamente"]})
