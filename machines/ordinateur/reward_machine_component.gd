# reward_machine_component.gd
class_name RewardMachineComponent
extends Node

signal progress_updated(current_progress, required_amount)

# L'item qui sert de carburant
@export var fuel_item: ItemData
# La liste ordonnée des paliers de récompense
@export var reward_tiers: Array[CumulativeReward]

# --- Variables de sauvegarde ---
var current_tier_index: int = 0
var current_fuel_progress: int = 0

# Fonction pour ajouter du carburant
func add_fuel(quantity_to_add: int):
	if current_tier_index >= reward_tiers.size():
		print("Tous les paliers de récompense ont été atteints.")
		return

	var fuel_in_inventory = InventoryManager.get_item_count(fuel_item)
	var actual_quantity_added = min(quantity_to_add, fuel_in_inventory)

	if actual_quantity_added > 0:
		InventoryManager.remove_item(fuel_item, actual_quantity_added)
		current_fuel_progress += actual_quantity_added

		check_for_reward()
		progress_updated.emit(current_fuel_progress, get_current_fuel_required())

# Vérifie si le palier actuel est atteint
func check_for_reward():
	var required = get_current_fuel_required()
	if required > 0 and current_fuel_progress >= required:
		_grant_rewards()

func _grant_rewards():
	var current_tier = reward_tiers[current_tier_index]

	# Donner les items
	for item_reward in current_tier.reward_items:
		InventoryManager.add_item(item_reward.item, item_reward.quantity)
		print("Récompense obtenue : ", item_reward.item.item_name)

	# Débloquer les recettes de craft
	for recipe_reward in current_tier.reward_crafting_recipes:
		CraftingManager.discover_recipe(recipe_reward.recipe_id)
		print("Recette apprise : ", recipe_reward.recipe_id)
		
	for machine_recipe_reward in current_tier.reward_machine_recipes:
		MachineRecipeManager.discover_recipe(machine_recipe_reward)

	# Passer au palier suivant
	current_fuel_progress -= current_tier.fuel_required
	current_tier_index += 1

	# S'il reste du carburant, on revérifie pour le nouveau palier
	check_for_reward()

func get_current_fuel_required() -> int:
	if current_tier_index < reward_tiers.size():
		return reward_tiers[current_tier_index].fuel_required
	return 0
