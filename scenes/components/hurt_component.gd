# hurt_component.gd (mis à jour)
class_name HurtComponent
extends Area2D

# On définit quelle action est nécessaire pour blesser cet objet.
# Vous pourrez régler ça dans l'inspecteur pour chaque objet (CHOP pour un arbre, etc.)
@export var required_action: ItemData.ActionType = ItemData.ActionType.NONE

signal hurt(hit_damage: int)

func _ready() -> void:
	# On se connecte au signal d'entrée d'une autre zone (la hitbox du joueur)
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# On vérifie si la zone qui nous a touché est bien la hitbox du joueur
	if area is HitComponent:
		# On demande au ToolManager quelle est l'action en cours
		var action_performed = ToolManager.get_selected_action()

		# Si l'action effectuée est bien celle requise par ce composant...
		if action_performed == required_action:
			print("Objet touché avec le bon outil !")
			# On peut maintenant émettre le signal de "blessure"
			# et y ajouter des données sur les dégâts si l'item en a.
			var item_used: ItemData = ToolManager.get_selected_item()
			# hurt.emit(item_used.damage) # Exemple
			
			# Pour un arbre, par exemple, on peut le détruire
			get_parent().queue_free()
