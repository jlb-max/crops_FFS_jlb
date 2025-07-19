# CollectableComponent.gd (mis à jour)
class_name CollectableComponent
extends Area2D

# On remplace le nom par une référence directe à la ressource ItemData
@export var item_data: ItemData

func _ready() -> void:
	# On connecte le signal ici pour être sûr que tout est prêt
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# On vérifie qu'un item a bien été assigné dans l'éditeur
		if not item_data:
			print("ERREUR: Aucun ItemData n'est assigné à ce CollectableComponent.")
			return

		# On utilise la nouvelle fonction de l'inventaire
		InventoryManager.add_item(item_data, 1)
		
		# La suite ne change pas : l'objet parent est détruit
		get_parent().queue_free()
