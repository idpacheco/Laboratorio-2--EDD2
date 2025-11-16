extends Line2D

var origen
var destino
var costo

func inicializar(origen_est, destino_est, p_costo):
	origen = origen_est
	destino = destino_est
	costo = p_costo
	points = [origen.position, destino.position]
	
	# Mueve el label perpendicularmente
	var vec = destino.position - origen.position
	var normal = Vector2(-vec.y, vec.x).normalized()
	# Puedes cambiar 18 por 22, 24... según el zoom/escala
	$PesoLabel.position = to_local((origen.position +destino.position  + normal * 8)/2)
	$PesoLabel.text = str(costo)
